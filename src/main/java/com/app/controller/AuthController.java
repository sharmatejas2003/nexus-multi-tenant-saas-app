package com.app.controller;

import com.app.entity.*;
import com.app.repository.*;
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

    public AuthController(PasswordEncoder passwordEncoder,
                          TenantRepository tenantRepo,
                          UserRepository userRepo,
                          InvitationRepository invitationRepo,
                          WorkspaceMemberRepository workspaceMemberRepo) {
        this.passwordEncoder = passwordEncoder;
        this.tenantRepo = tenantRepo;
        this.userRepo = userRepo;
        this.invitationRepo = invitationRepo;
        this.workspaceMemberRepo = workspaceMemberRepo;
    }

    @GetMapping("/login")
    public String login() {
        return "login";
    }

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

            // ─────────────────────────────────────────────
            // CASE 1: JOIN EXISTING WORKSPACE VIA INVITE LINK
            // ─────────────────────────────────────────────
            if (token != null && !token.isEmpty()) {

                Invitation invite = invitationRepo.findByToken(token).orElse(null);

                if (invite == null || invite.isAccepted() || invite.isExpired()) {
                    return "redirect:/register?error=invalid_token";
                }

                // Check if user with this email already exists
                User existingUser = userRepo.findByUsername(user.getUsername());
                if (existingUser != null) {
                    // User already exists — just add them as member of the invited workspace
                    Long tenantId = invite.getTenantId();
                    if (!workspaceMemberRepo.existsByUserIdAndTenantId(existingUser.getId(), tenantId)) {
                        WorkspaceMember m = new WorkspaceMember();
                        m.setUserId(existingUser.getId());
                        m.setTenantId(tenantId);
                        m.setRole("MEMBER");
                        workspaceMemberRepo.save(m);
                        // Also update legacy tenantId if user has none
                        if (existingUser.getTenantId() == null) {
                            existingUser.setTenantId(tenantId);
                            existingUser.setRole("MEMBER");
                            userRepo.save(existingUser);
                        }
                    }
                    invite.setAccepted(true);
                    invitationRepo.save(invite);
                    return "redirect:/login?joined=true";
                }

                Tenant tenant = tenantRepo.findById(invite.getTenantId()).orElseThrow();

                user.setPassword(passwordEncoder.encode(user.getPassword()));
                user.setProvider("LOCAL");
                user.setTenantId(tenant.getId());   // primary workspace
                user.setRole("MEMBER");
                userRepo.save(user);

                WorkspaceMember member = new WorkspaceMember();
                member.setUserId(user.getId());
                member.setTenantId(tenant.getId());
                member.setRole("MEMBER");
                workspaceMemberRepo.save(member);

                invite.setAccepted(true);
                invitationRepo.save(invite);

                return "redirect:/login?registered=true";
            }

            // ─────────────────────────────────────────────
            // CASE 2: CREATE NEW WORKSPACE (personal or org)
            // ─────────────────────────────────────────────
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
}