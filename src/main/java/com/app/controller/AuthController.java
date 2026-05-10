package com.app.controller;

import com.app.entity.*;
import com.app.repository.*;
import com.app.service.NotificationService;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

@Controller
public class AuthController {

    private final PasswordEncoder passwordEncoder;
    private final TenantRepository tenantRepo;
    private final UserRepository userRepo;
    private final InvitationRepository invitationRepo;
    private final WorkspaceMemberRepository workspaceMemberRepo;
    private final NotificationService notificationService;

    public AuthController(PasswordEncoder passwordEncoder,
                          TenantRepository tenantRepo,
                          UserRepository userRepo,
                          InvitationRepository invitationRepo,
                          WorkspaceMemberRepository workspaceMemberRepo,
                          NotificationService notificationService) {
        this.passwordEncoder = passwordEncoder;
        this.tenantRepo = tenantRepo;
        this.userRepo = userRepo;
        this.invitationRepo = invitationRepo;
        this.workspaceMemberRepo = workspaceMemberRepo;
        this.notificationService = notificationService;
    }

    @GetMapping("/login")
    public String login() { return "login"; }

    @GetMapping("/register")
    public String registerPage(@RequestParam(required = false) String token, Model model) {
        if (token != null && !token.isEmpty()) {
            Invitation invite = invitationRepo.findByToken(token).orElse(null);
            if (invite == null || invite.isAccepted() || invite.isExpired()) {
                model.addAttribute("tokenError", "This invitation link is invalid or has expired.");
            } else {
                Tenant tenant = tenantRepo.findById(invite.getTenantId()).orElse(null);
                model.addAttribute("invite", invite);
                model.addAttribute("workspaceName", tenant != null ? tenant.getName() : "");
                model.addAttribute("token", token);
            }
        }
        return "register";
    }

    @PostMapping("/register")
    public String register(
            User user,
            @RequestParam(defaultValue = "PERSONAL") String mode,
            @RequestParam(defaultValue = "") String workspaceName,
            @RequestParam(required = false) String token
    ) {
        try {
            // ─── CASE 1: JOIN VIA INVITE LINK ───────────────────────
            if (token != null && !token.isEmpty()) {
                Invitation invite = invitationRepo.findByToken(token).orElse(null);
                if (invite == null || invite.isAccepted() || invite.isExpired()) {
                    return "redirect:/register?error=invalid_token";
                }

                Long tenantId = invite.getTenantId();
                Tenant tenant = tenantRepo.findById(tenantId).orElseThrow();

                User existingUser = userRepo.findByUsername(user.getUsername());
                if (existingUser != null) {
                    // Existing user — just add workspace membership
                    if (!workspaceMemberRepo.existsByUserIdAndTenantId(existingUser.getId(), tenantId)) {
                        WorkspaceMember m = new WorkspaceMember();
                        m.setUserId(existingUser.getId());
                        m.setTenantId(tenantId);
                        m.setRole("MEMBER");
                        workspaceMemberRepo.save(m);
                    }
                    invite.setAccepted(true);
                    invitationRepo.save(invite);
                    notifyWorkspaceOwners(tenantId, existingUser.getUsername(), tenant.getName());
                    return "redirect:/login?joined=true";
                }

                // New user joining via invite
                user.setPassword(passwordEncoder.encode(user.getPassword()));
                user.setProvider("LOCAL");
                user.setTenantId(tenantId);
                user.setRole("MEMBER");
                userRepo.save(user);

                WorkspaceMember member = new WorkspaceMember();
                member.setUserId(user.getId());
                member.setTenantId(tenantId);
                member.setRole("MEMBER");
                workspaceMemberRepo.save(member);

                invite.setAccepted(true);
                invitationRepo.save(invite);
                notifyWorkspaceOwners(tenantId, user.getUsername(), tenant.getName());
                return "redirect:/login?registered=true";
            }

            // ─── CASE 2: NEW ACCOUNT + NEW WORKSPACE ────────────────
            if (userRepo.findByUsername(user.getUsername()) != null) {
                return "redirect:/register?error=email_taken";
            }

            String wsName = workspaceName.isBlank()
                    ? user.getUsername() + "'s Workspace"
                    : workspaceName;

            Tenant tenant = new Tenant();
            tenant.setName(wsName);
            tenant.setSlug(wsName.toLowerCase().replaceAll("[^a-z0-9]", "-")
                    + "-" + (System.currentTimeMillis() % 100000));
            tenant.setStatus("ACTIVE");
            tenant.setPlanType("FREE");
            tenant.setWorkspaceType("ORGANIZATION".equalsIgnoreCase(mode) ? "ORGANIZATION" : "PERSONAL");
            tenantRepo.save(tenant);

            user.setTenantId(tenant.getId());
            user.setRole("OWNER");
            user.setPassword(passwordEncoder.encode(user.getPassword()));
            user.setProvider("LOCAL");
            userRepo.save(user);

            // CRITICAL: always create workspace_members row
            WorkspaceMember ownerMember = new WorkspaceMember();
            ownerMember.setUserId(user.getId());
            ownerMember.setTenantId(tenant.getId());
            ownerMember.setRole("OWNER");
            workspaceMemberRepo.save(ownerMember);

            tenant.setOwnerId(user.getId());
            tenantRepo.save(tenant);

            return "redirect:/login?registered=true";

        } catch (Exception e) {
            e.printStackTrace();
            return "redirect:/register?error=true";
        }
    }

    @PostMapping("/workspace/create-new")
    public String createAdditionalWorkspace(
            @RequestParam String workspaceName,
            @RequestParam(defaultValue = "PERSONAL") String workspaceType,
            org.springframework.security.core.Authentication auth,
            jakarta.servlet.http.HttpSession session) {
        try {
            User user = userRepo.findByUsername(auth.getName());
            if (user == null) return "redirect:/dashboard?error=not_found";

            String wsName = workspaceName.isBlank()
                    ? user.getUsername() + "'s Workspace"
                    : workspaceName;

            Tenant tenant = new Tenant();
            tenant.setName(wsName);
            tenant.setSlug(wsName.toLowerCase().replaceAll("[^a-z0-9]", "-")
                    + "-" + (System.currentTimeMillis() % 100000));
            tenant.setStatus("ACTIVE");
            tenant.setPlanType("FREE");
            tenant.setWorkspaceType("ORGANIZATION".equalsIgnoreCase(workspaceType) ? "ORGANIZATION" : "PERSONAL");
            tenantRepo.save(tenant);

            WorkspaceMember ownerMember = new WorkspaceMember();
            ownerMember.setUserId(user.getId());
            ownerMember.setTenantId(tenant.getId());
            ownerMember.setRole("OWNER");
            workspaceMemberRepo.save(ownerMember);

            tenant.setOwnerId(user.getId());
            tenantRepo.save(tenant);

            session.setAttribute("activeWorkspaceId", tenant.getId());
            return "redirect:/dashboard?created=true";
        } catch (Exception e) {
            e.printStackTrace();
            return "redirect:/dashboard?error=true";
        }
    }

    private void notifyWorkspaceOwners(Long tenantId, String newMemberUsername, String workspaceName) {
        try {
            var members = workspaceMemberRepo.findByTenantId(tenantId);
            for (WorkspaceMember wm : members) {
                if ("OWNER".equals(wm.getRole()) || "ADMIN".equals(wm.getRole())) {
                    User owner = userRepo.findById(wm.getUserId()).orElse(null);
                    if (owner != null && !owner.getUsername().equals(newMemberUsername)) {
                        notificationService.notifyWithTenant(
                            owner.getUsername(),
                            "👋 " + newMemberUsername + " just joined your workspace \"" + workspaceName + "\"",
                            "/workspace/members",
                            "MEMBER_INVITED",
                            tenantId
                        );
                    }
                }
            }
        } catch (Exception e) {
            System.err.println("[AuthController] Notify error: " + e.getMessage());
        }
    }
}