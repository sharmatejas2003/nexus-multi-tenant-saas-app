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

    public AuthController(
            PasswordEncoder passwordEncoder,
            TenantRepository tenantRepo,
            UserRepository userRepo,
            InvitationRepository invitationRepo,
            WorkspaceMemberRepository workspaceMemberRepo
    ) {
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
    public String registerPage(
            @RequestParam(required = false) String token,
            Model model
    ) {

        if (token != null && !token.isEmpty()) {

            Invitation invite =
                    invitationRepo.findByToken(token)
                            .orElse(null);

            if (invite == null
                    || invite.isAccepted()
                    || invite.isExpired()) {

                model.addAttribute(
                        "tokenError",
                        "This invitation link is invalid or expired."
                );

            } else {

                Tenant tenant =
                        tenantRepo.findById(
                                invite.getTenantId()
                        ).orElse(null);

                model.addAttribute("invite", invite);
                model.addAttribute(
                        "workspaceName",
                        tenant != null
                                ? tenant.getName()
                                : ""
                );

                model.addAttribute("token", token);
            }
        }

        return "register";
    }

    @PostMapping("/register")
    public String register(
            User user,
            @RequestParam(defaultValue = "PERSONAL")
            String mode,

            @RequestParam(defaultValue = "")
            String workspaceName,

            @RequestParam(required = false)
            String token
    ) {

        try {

            // ==========================
            // JOIN EXISTING WORKSPACE
            // ==========================
            if (token != null && !token.isEmpty()) {

                Invitation invite =
                        invitationRepo.findByToken(token)
                                .orElse(null);

                if (invite == null
                        || invite.isAccepted()
                        || invite.isExpired()) {

                    return "redirect:/register?error=invalid_token";
                }

                Tenant tenant =
                        tenantRepo.findById(
                                invite.getTenantId()
                        ).orElseThrow();

                // encode password
                user.setPassword(
                        passwordEncoder.encode(
                                user.getPassword()
                        )
                );

                user.setProvider("LOCAL");

                // compatibility with old system
                user.setTenantId(tenant.getId());
                user.setRole("MEMBER");

                userRepo.save(user);

                // create membership
                WorkspaceMember member =
                        new WorkspaceMember();

                member.setUserId(user.getId());
                member.setTenantId(tenant.getId());
                member.setRole("MEMBER");

                workspaceMemberRepo.save(member);

                invite.setAccepted(true);
                invitationRepo.save(invite);

                return "redirect:/login?registered=true";
            }

            // ==========================
            // CREATE NEW WORKSPACE
            // ==========================
            Tenant tenant = new Tenant();

            tenant.setName(
                    workspaceName.isEmpty()
                            ? user.getUsername()
                            + "'s Workspace"
                            : workspaceName
            );

            tenant.setSlug(
                    tenant.getName()
                            .toLowerCase()
                            .replaceAll(
                                    "[^a-z0-9]",
                                    "-"
                            )
            );

            tenant.setStatus("ACTIVE");
            tenant.setPlanType("FREE");

            tenantRepo.save(tenant);

            // owner user
            user.setTenantId(tenant.getId());
            user.setRole("OWNER");

            user.setPassword(
                    passwordEncoder.encode(
                            user.getPassword()
                    )
            );

            user.setProvider("LOCAL");

            userRepo.save(user);

            // workspace membership
            WorkspaceMember ownerMember =
                    new WorkspaceMember();

            ownerMember.setUserId(user.getId());
            ownerMember.setTenantId(tenant.getId());
            ownerMember.setRole("OWNER");

            workspaceMemberRepo.save(ownerMember);

            // set owner
            tenant.setOwnerId(user.getId());
            tenantRepo.save(tenant);

            return "redirect:/login?registered=true";

        } catch (Exception e) {

            e.printStackTrace();

            return "redirect:/register?error=true";
        }
    }
}