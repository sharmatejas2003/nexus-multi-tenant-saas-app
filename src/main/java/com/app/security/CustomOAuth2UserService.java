package com.app.security;

import com.app.entity.Tenant;
import com.app.entity.User;
import com.app.entity.WorkspaceMember;
import com.app.repository.TenantRepository;
import com.app.repository.UserRepository;
import com.app.repository.WorkspaceMemberRepository;
import org.springframework.security.oauth2.client.userinfo.*;
import org.springframework.security.oauth2.core.user.OAuth2User;
import org.springframework.stereotype.Service;

@Service
public class CustomOAuth2UserService extends DefaultOAuth2UserService {

    private final UserRepository repo;
    private final TenantRepository tenantRepo;
    private final WorkspaceMemberRepository workspaceMemberRepo;

    public CustomOAuth2UserService(UserRepository repo,
                                   TenantRepository tenantRepo,
                                   WorkspaceMemberRepository workspaceMemberRepo) {
        this.repo = repo;
        this.tenantRepo = tenantRepo;
        this.workspaceMemberRepo = workspaceMemberRepo;
    }

    @Override
    public OAuth2User loadUser(OAuth2UserRequest request) {
        OAuth2User oAuth2User = super.loadUser(request);
        String email = oAuth2User.getAttribute("email");
        User user = repo.findByUsername(email);

        if (user == null) {
            // Create tenant
            Tenant tenant = new Tenant();
            tenant.setName(email.split("@")[0] + "'s Workspace");
            tenant.setSlug(email.split("@")[0].toLowerCase().replaceAll("[^a-z0-9]", "-")
                    + "-" + System.currentTimeMillis() % 10000);
            tenant.setStatus("ACTIVE");
            tenant.setPlanType("FREE");
            tenant.setWorkspaceType("PERSONAL");
            tenantRepo.save(tenant);

            // Create user
            user = new User();
            user.setUsername(email);
            user.setPassword("GOOGLE_ONLY");
            user.setTenantId(tenant.getId());
            user.setRole("OWNER");
            user.setProvider("GOOGLE");
            repo.save(user);

            // Set owner
            tenant.setOwnerId(user.getId());
            tenantRepo.save(tenant);

            // CRITICAL: create workspace_members row
            WorkspaceMember member = new WorkspaceMember();
            member.setUserId(user.getId());
            member.setTenantId(tenant.getId());
            member.setRole("OWNER");
            workspaceMemberRepo.save(member);

        } else {
            // Existing OAuth user — ensure they have a workspace_members row
            // (handles migration of old accounts created before workspace_members was added)
            if (user.getTenantId() != null) {
                boolean hasMembership = workspaceMemberRepo
                        .existsByUserIdAndTenantId(user.getId(), user.getTenantId());
                if (!hasMembership) {
                    WorkspaceMember member = new WorkspaceMember();
                    member.setUserId(user.getId());
                    member.setTenantId(user.getTenantId());
                    member.setRole(user.getRole() != null ? user.getRole() : "OWNER");
                    workspaceMemberRepo.save(member);
                }
            }
        }
        return oAuth2User;
    }
}