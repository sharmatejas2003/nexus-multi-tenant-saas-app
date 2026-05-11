package com.app.controller;

import com.app.annotation.AdminOnly;
import com.app.entity.*;
import com.app.repository.*;
import com.app.service.*;
import com.app.tenant.TenantContext;
import jakarta.servlet.http.*;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import java.util.ArrayList;
import java.util.List;

@Controller
@RequestMapping("/workspace")
public class WorkSpaceController {

    private final TenantRepository tenantRepo;
    private final UserRepository userRepository;
    private final InvitationService invitationService;
    private final InvitationRepository invitationRepo;
    private final WorkspaceMemberRepository workspaceMemberRepo;
    private final NotificationService notificationService;

    @Value("${app.base-url:http://localhost:8080}")
    private String appBaseUrl;

    public WorkSpaceController(TenantRepository tenantRepo,
                                UserRepository userRepository,
                                InvitationService invitationService,
                                InvitationRepository invitationRepo,
                                WorkspaceMemberRepository workspaceMemberRepo,
                                NotificationService notificationService) {
        this.tenantRepo = tenantRepo;
        this.userRepository = userRepository;
        this.invitationService = invitationService;
        this.invitationRepo = invitationRepo;
        this.workspaceMemberRepo = workspaceMemberRepo;
        this.notificationService = notificationService;
    }

    /* ── INVITE PAGE ────────────────────────────────────────── */
    @GetMapping("/invite")
    public String showInvitePage(Model model, Authentication auth) {
        Long tenantId = TenantContext.getTenant();
        if (tenantId == null) return "redirect:/login";

        model.addAttribute("currentUser", userRepository.findByUsername(auth.getName()));
        model.addAttribute("currentRole", TenantContext.getRole());
        model.addAttribute("isAdminOrOwner", TenantContext.isAdminOrOwner());

        String token = invitationService.createInvitation("");
        String inviteLink = appBaseUrl + "/register?token=" + token;
        model.addAttribute("inviteLink", inviteLink);
        model.addAttribute("pendingInvitations", invitationRepo.findByTenantIdAndAcceptedFalse(tenantId));
        tenantRepo.findById(tenantId).ifPresent(t -> model.addAttribute("tenant", t));

        return "workspace-invite";
    }

    @PostMapping("/invite/generate")
    @ResponseBody
    public String generateLink(@RequestParam String email) {
        if (email == null || email.trim().isEmpty()) return "Error: email required";
        String token = invitationService.createInvitation(email.trim());
        return appBaseUrl + "/register?token=" + token;
    }

    /* ── MEMBERS ────────────────────────────────────────────── */
    @GetMapping("/members")
    public String viewMembers(Model model, Authentication auth) {
        Long tenantId = TenantContext.getTenant();
        if (tenantId == null) return "redirect:/login";

        User currentUser = userRepository.findByUsername(auth.getName());
        model.addAttribute("currentUser", currentUser);
        model.addAttribute("loggedInUsername", auth.getName());
        model.addAttribute("currentRole", TenantContext.getRole());
        model.addAttribute("isAdminOrOwner", TenantContext.isAdminOrOwner());

        long unread = 0;
        try { unread = notificationService.countUnread(auth.getName()); } catch (Exception ignored) {}
        model.addAttribute("unreadNotifications", unread);

        // Get the role from workspace_members (the authoritative source)
        String loggedInRole = TenantContext.getRole() != null ? TenantContext.getRole() : "MEMBER";
        model.addAttribute("loggedInRole", loggedInRole);

        tenantRepo.findById(tenantId).ifPresent(t -> model.addAttribute("tenant", t));

        // Build member list from workspace_members joined with users - this ensures correct roles
        List<MemberInfo> memberInfoList = new ArrayList<>();
        try {
            List<WorkspaceMember> wms = workspaceMemberRepo.findByTenantId(tenantId);
            for (WorkspaceMember wm : wms) {
                try {
                    userRepository.findById(wm.getUserId()).ifPresent(u -> {
                        memberInfoList.add(new MemberInfo(
                            u.getId(),
                            u.getUsername(),
                            wm.getRole(), // Use workspace_members role, NOT users.role
                            u.getBio(),
                            u.getAvatarUrl(),
                            wm.getJoinedAt()
                        ));
                    });
                } catch (Exception ignored) {}
            }
        } catch (Exception e) {
            System.err.println("[WorkSpaceController] Error loading members: " + e.getMessage());
        }

        model.addAttribute("memberInfoList", memberInfoList);
        // Keep backward compat
        model.addAttribute("members", userRepository.findByTenantId(tenantId));

        // Workspace switcher
        List<WorkspaceSwitcherController.WorkspaceInfo> allWorkspaces = new ArrayList<>();
        try {
            if (currentUser != null) {
                List<WorkspaceMember> memberships = workspaceMemberRepo.findByUserId(currentUser.getId());
                for (WorkspaceMember wm : memberships) {
                    tenantRepository_findById_safe(wm.getTenantId(), tenantId, allWorkspaces, wm);
                }
            }
        } catch (Exception ignored) {}
        model.addAttribute("allWorkspaces", allWorkspaces);

        return "workspace-members";
    }

    private void tenantRepository_findById_safe(Long tid, Long activeTenantId,
            List<WorkspaceSwitcherController.WorkspaceInfo> list, WorkspaceMember wm) {
        try {
            tenantRepo.findById(tid).ifPresent(t ->
                list.add(new WorkspaceSwitcherController.WorkspaceInfo(
                    t.getId(), t.getName(), wm.getRole(), t.getId().equals(activeTenantId), t.getWorkspaceType()
                ))
            );
        } catch (Exception ignored) {}
    }

    @PostMapping("/members/ban/{id}")
    @AdminOnly
    public String banUser(@PathVariable Long id) {
        Long tenantId = TenantContext.getTenant();
        try {
            // Remove from workspace_members (don't delete user)
            workspaceMemberRepo.findByUserIdAndTenantId(id, tenantId).ifPresent(wm -> {
                // Check not owner
                if (!"OWNER".equals(wm.getRole())) {
                    workspaceMemberRepo.delete(wm);
                }
            });
        } catch (Exception e) {
            System.err.println("[WorkSpaceController] Ban error: " + e.getMessage());
        }
        return "redirect:/workspace/members";
    }

    @PostMapping("/members/promote/{userId}")
    @AdminOnly
    public String promoteToAdmin(@PathVariable Long userId) {
        Long tenantId = TenantContext.getTenant();
        try {
            workspaceMemberRepo.findByUserIdAndTenantId(userId, tenantId).ifPresent(wm -> {
                if (!"OWNER".equals(wm.getRole())) {
                    wm.setRole("ADMIN");
                    workspaceMemberRepo.save(wm);
                    // Also update users table for consistency
                    userRepository.findById(userId).ifPresent(u -> {
                        if (!"OWNER".equals(u.getRole())) { u.setRole("ADMIN"); userRepository.save(u); }
                    });
                }
            });
        } catch (Exception e) {
            System.err.println("[WorkSpaceController] Promote error: " + e.getMessage());
        }
        return "redirect:/workspace/members";
    }

    @PostMapping("/members/demote/{userId}")
    @AdminOnly
    public String demoteToMember(@PathVariable Long userId) {
        Long tenantId = TenantContext.getTenant();
        try {
            workspaceMemberRepo.findByUserIdAndTenantId(userId, tenantId).ifPresent(wm -> {
                if ("ADMIN".equals(wm.getRole())) {
                    wm.setRole("MEMBER");
                    workspaceMemberRepo.save(wm);
                    userRepository.findById(userId).ifPresent(u -> {
                        if ("ADMIN".equals(u.getRole())) { u.setRole("MEMBER"); userRepository.save(u); }
                    });
                }
            });
        } catch (Exception e) {
            System.err.println("[WorkSpaceController] Demote error: " + e.getMessage());
        }
        return "redirect:/workspace/members";
    }

    /* ── OWNERSHIP TRANSFER ─────────────────────────────────── */
    @PostMapping("/transfer-ownership")
    public String transferOwnership(@RequestParam Long newOwnerId) {
        Long tenantId = TenantContext.getTenant();
        Tenant tenant = tenantRepo.findById(tenantId).orElseThrow();
        User newOwner = userRepository.findById(newOwnerId).orElseThrow();

        // Update workspace_members
        workspaceMemberRepo.findByTenantId(tenantId).forEach(wm -> {
            if ("OWNER".equals(wm.getRole()) && !wm.getUserId().equals(newOwnerId)) {
                wm.setRole("ADMIN"); workspaceMemberRepo.save(wm);
            }
        });
        workspaceMemberRepo.findByUserIdAndTenantId(newOwnerId, tenantId).ifPresent(wm -> {
            wm.setRole("OWNER"); workspaceMemberRepo.save(wm);
        });

        // Update users table
        userRepository.findByTenantId(tenantId).stream()
            .filter(u -> "OWNER".equals(u.getRole()) && !u.getId().equals(newOwnerId))
            .forEach(u -> { u.setRole("ADMIN"); userRepository.save(u); });
        newOwner.setRole("OWNER"); userRepository.save(newOwner);
        tenant.setOwnerId(newOwnerId); tenantRepo.save(tenant);

        return "redirect:/workspace/settings?transferred=true";
    }

    /* ── SETTINGS ────────────────────────────────────────────── */
    @GetMapping("/settings")
    public String settings(Model model, Authentication auth) {
        Long tenantId = TenantContext.getTenant();
        if (tenantId == null) return "redirect:/login";
        model.addAttribute("currentUser", userRepository.findByUsername(auth.getName()));
        model.addAttribute("currentRole", TenantContext.getRole());
        model.addAttribute("isAdminOrOwner", TenantContext.isAdminOrOwner());
        Tenant tenant = tenantRepo.findById(tenantId).orElse(new Tenant());
        List<User> members = userRepository.findByTenantId(tenantId);
        model.addAttribute("tenant", tenant);
        model.addAttribute("members", members);

        long unread = 0;
        try { unread = notificationService.countUnread(auth.getName()); } catch (Exception ignored) {}
        model.addAttribute("unreadNotifications", unread);

        return "workspace-settings";
    }

    @PostMapping("/update")
    public String updateWorkspace(@RequestParam Long id,
                                   @RequestParam String name,
                                   @RequestParam String slug,
                                   @RequestParam(required = false) String workspaceType) {
        Tenant tenant = tenantRepo.findById(id).orElseThrow();
        Long tenantId = TenantContext.getTenant();
        if (!tenant.getId().equals(tenantId)) return "redirect:/workspace/settings?error=unauthorized";
        tenant.setName(name);
        tenant.setSlug(slug.toLowerCase().replaceAll("[^a-z0-9-]", "-"));
        if (workspaceType != null) tenant.setWorkspaceType(workspaceType);
        tenantRepo.save(tenant);
        return "redirect:/workspace/settings?saved=true";
    }

    @PostMapping("/delete")
    public String deleteWorkspace(HttpSession session) {
        Long tenantId = TenantContext.getTenant();
        if (tenantId == null) return "redirect:/login";
        try {
            workspaceMemberRepo.findByTenantId(tenantId).forEach(wm -> workspaceMemberRepo.delete(wm));
            tenantRepo.deleteById(tenantId);
        } catch (Exception e) {
            System.err.println("[WorkspaceController] Delete error: " + e.getMessage());
        }
        session.invalidate();
        return "redirect:/login?deleted=true";
    }

    /* ── PROFILE ─────────────────────────────────────────────── */
    @GetMapping("/profile")
    public String profile(Model model, Authentication auth) {
        User user = userRepository.findByUsername(auth.getName());
        model.addAttribute("user", user);
        model.addAttribute("currentUser", user);
        model.addAttribute("currentRole", TenantContext.getRole());
        model.addAttribute("isAdminOrOwner", TenantContext.isAdminOrOwner());
        if (user != null && user.getTenantId() != null) {
            tenantRepo.findById(user.getTenantId()).ifPresent(t -> model.addAttribute("tenant", t));
        }
        long unread = 0;
        try { unread = notificationService.countUnread(auth.getName()); } catch (Exception ignored) {}
        model.addAttribute("unreadNotifications", unread);
        return "profile";
    }

    @PostMapping("/profile/update")
    public String updateProfile(@RequestParam(required = false) String bio,
                                 @RequestParam(required = false) String avatarUrl,
                                 Authentication auth) {
        User user = userRepository.findByUsername(auth.getName());
        if (user != null) {
            if (bio != null) user.setBio(bio);
            if (avatarUrl != null && !avatarUrl.isEmpty()) user.setAvatarUrl(avatarUrl);
            userRepository.save(user);
        }
        return "redirect:/workspace/profile?saved=true";
    }

    // ── MemberInfo DTO for the members page ──
    public static class MemberInfo {
        private final Long id;
        private final String username;
        private final String role;
        private final String bio;
        private final String avatarUrl;
        private final java.time.LocalDateTime joinedAt;

        public MemberInfo(Long id, String username, String role, String bio, String avatarUrl, java.time.LocalDateTime joinedAt) {
            this.id = id; this.username = username; this.role = role;
            this.bio = bio; this.avatarUrl = avatarUrl; this.joinedAt = joinedAt;
        }

        public Long getId() { return id; }
        public String getUsername() { return username; }
        public String getRole() { return role; }
        public String getBio() { return bio; }
        public String getAvatarUrl() { return avatarUrl; }
        public java.time.LocalDateTime getJoinedAt() { return joinedAt; }
        public String getInitial() { return (username != null && !username.isEmpty()) ? username.substring(0,1).toUpperCase() : "?"; }
        public String getDisplayName() {
            if (username == null) return "Unknown";
            // Extract name from email if it's an email
            if (username.contains("@")) {
                String part = username.split("@")[0];
                return part.substring(0,1).toUpperCase() + part.substring(1);
            }
            return username;
        }
    }
}