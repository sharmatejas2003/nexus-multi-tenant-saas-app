package com.app.controller;

import com.app.annotation.AdminOnly;
import com.app.entity.*;
import com.app.repository.*;
import com.app.service.*;
import com.app.tenant.TenantContext;
import jakarta.servlet.http.*;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@Controller
@RequestMapping("/workspace")
public class WorkSpaceController {

    private final TenantRepository tenantRepo;
    private final UserRepository userRepository;
    private final InvitationService invitationService;
    private final InvitationRepository invitationRepo;

    public WorkSpaceController(TenantRepository tenantRepo, UserRepository userRepository,
                                InvitationService invitationService, InvitationRepository invitationRepo) {
        this.tenantRepo = tenantRepo;
        this.userRepository = userRepository;
        this.invitationService = invitationService;
        this.invitationRepo = invitationRepo;
    }

    @GetMapping("/invite")
    public String showInvitePage(Model model, Authentication auth) {
        Long tenantId = TenantContext.getTenant();
        if (tenantId == null) return "redirect:/login";
        // Show page without auto-generating a link
        model.addAttribute("inviteLink", "");
        model.addAttribute("pendingInvitations", invitationRepo.findByTenantIdAndAcceptedFalse(tenantId));
        return "workspace-invite";
    }

    @PostMapping("/invite/generate")
    @ResponseBody
    public String generateLink(@RequestParam String email, Authentication auth) {
        if (email == null || email.trim().isEmpty()) return "Error: email required";
        String link = invitationService.createInvitation(email.trim());
        return link;
    }

    @GetMapping("/members")
    public String viewMembers(Model model) {
        Long tenantId = TenantContext.getTenant();
        if (tenantId == null) return "redirect:/login";
        model.addAttribute("members", userRepository.findByTenantId(tenantId));
        return "workspace-members";
    }

    @PostMapping("/members/ban/{id}")
    @AdminOnly
    public String banUser(@PathVariable Long id) {
        Long tenantId = TenantContext.getTenant();
        // Safety: never let user delete themselves or someone in different tenant
        userRepository.findById(id).ifPresent(u -> {
            if (u.getTenantId().equals(tenantId) && !"OWNER".equals(u.getRole())) {
                userRepository.deleteById(id);
            }
        });
        return "redirect:/workspace/members";
    }

    @PostMapping("/members/promote/{userId}")
    @AdminOnly
    public String promoteToAdmin(@PathVariable Long userId) {
        Long tenantId = TenantContext.getTenant();
        User user = userRepository.findById(userId).orElseThrow();
        if (user.getTenantId().equals(tenantId) && !"OWNER".equals(user.getRole())) {
            user.setRole("ADMIN");
            userRepository.save(user);
        }
        return "redirect:/workspace/members";
    }

    @PostMapping("/members/demote/{userId}")
    @AdminOnly
    public String demoteToMember(@PathVariable Long userId) {
        Long tenantId = TenantContext.getTenant();
        User user = userRepository.findById(userId).orElseThrow();
        if (user.getTenantId().equals(tenantId) && "ADMIN".equals(user.getRole())) {
            user.setRole("MEMBER");
            userRepository.save(user);
        }
        return "redirect:/workspace/members";
    }

    @PostMapping("/transfer-ownership")
    public String transferOwnership(@RequestParam Long newOwnerId) {
        Long tenantId = TenantContext.getTenant();
        Tenant tenant = tenantRepo.findById(tenantId).orElseThrow();
        User newOwner = userRepository.findById(newOwnerId).orElseThrow();

        if (!newOwner.getTenantId().equals(tenantId)) return "redirect:/workspace/settings?error=invalid_user";

        userRepository.findByTenantId(tenantId).stream()
                .filter(u -> "OWNER".equals(u.getRole()) && !u.getId().equals(newOwnerId))
                .forEach(u -> { u.setRole("ADMIN"); userRepository.save(u); });

        newOwner.setRole("OWNER");
        userRepository.save(newOwner);
        tenant.setOwnerId(newOwnerId);
        tenantRepo.save(tenant);

        return "redirect:/workspace/settings?transferred=true";
    }

    @GetMapping("/settings")
    public String settings(Model model) {
        Long tenantId = TenantContext.getTenant();
        if (tenantId == null) return "redirect:/login";
        Tenant tenant = tenantRepo.findById(tenantId).orElse(new Tenant());
        List<User> members = userRepository.findByTenantId(tenantId);
        model.addAttribute("tenant", tenant);
        model.addAttribute("members", members);
        return "workspace-settings";
    }

    @PostMapping("/update")
    public String updateWorkspace(@RequestParam Long id, @RequestParam String name, @RequestParam String slug) {
        Tenant tenant = tenantRepo.findById(id).orElseThrow();
        Long tenantId = TenantContext.getTenant();
        if (!tenant.getId().equals(tenantId)) return "redirect:/workspace/settings?error=unauthorized";
        tenant.setName(name);
        tenant.setSlug(slug.toLowerCase().replaceAll("[^a-z0-9-]", "-"));
        tenantRepo.save(tenant);
        return "redirect:/workspace/settings?saved=true";
    }

    @PostMapping("/delete")
    public String deleteWorkspace(HttpSession session) {
        Long tenantId = TenantContext.getTenant();
        if (tenantId == null) return "redirect:/login";

        // Delete dependent data first
        try {
            userRepository.findByTenantId(tenantId).forEach(u -> userRepository.deleteById(u.getId()));
            tenantRepo.deleteById(tenantId);
        } catch (Exception e) {
            System.err.println("[WorkspaceController] Delete error: " + e.getMessage());
        }

        session.invalidate();
        return "redirect:/login?deleted=true";
    }

    @GetMapping("/profile")
    public String profile(Model model, Authentication auth) {
        User user = userRepository.findByUsername(auth.getName());
        model.addAttribute("user", user);
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
}