package com.app.service;

import com.app.annotation.TenantSecure;
import com.app.entity.Project;
import com.app.entity.Tenant;
import com.app.entity.User;
import com.app.repository.ProjectRepository;
import com.app.repository.TenantRepository;
import com.app.repository.UserRepository;
import com.app.tenant.TenantContext;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Collections;
import java.util.List;

@Service
public class ProjectService {
    private final ProjectRepository repo;
    private final TenantRepository tenantRepo;
    private final ActivityService activityService;
    private final UserRepository userRepository;
    private final NotificationService notificationService;

    public ProjectService(ProjectRepository repo, TenantRepository tenantRepo,
                          ActivityService activityService, UserRepository userRepository,
                          NotificationService notificationService) {
        this.repo = repo;
        this.tenantRepo = tenantRepo;
        this.activityService = activityService;
        this.userRepository = userRepository;
        this.notificationService = notificationService;
    }

    public List<Project> getAll() {
        Long tenantId = TenantContext.getTenant();
        if (tenantId == null) return Collections.emptyList();
        return repo.findByTenantId(tenantId);
    }

    public Project getById(String id) {
        return repo.findById(id).orElse(null);
    }

    @Transactional
    @TenantSecure
    public Project save(Project p) {
        Long tenantId = TenantContext.getTenant();
        if (tenantId == null) throw new RuntimeException("No tenant context. Please log in again.");

        boolean isNew = (p.getId() == null || p.getId().isEmpty());

        if (isNew) {
            Tenant tenant = tenantRepo.findById(tenantId).orElse(null);
            if (tenant != null && "FREE".equalsIgnoreCase(tenant.getPlanType())) {
                long count = repo.countByTenantId(tenantId);
                if (count >= 10) throw new RuntimeException("Free plan limit reached (10 projects). Upgrade to Pro.");
            }
        }

        p.setTenantId(tenantId);
        Project saved = repo.save(p);

        if (isNew) {
            activityService.log("CREATED_PROJECT", "PROJECT", saved.getId(), saved.getName(), "New project created");

            // Notify all members of the workspace
            String creator = getCurrentUsername();
            List<User> members = userRepository.findByTenantId(tenantId);
            for (User member : members) {
                if (!member.getUsername().equals(creator)) {
                    notificationService.notify(
                        member.getUsername(),
                        "🚀 New project created: \"" + saved.getName() + "\" by " + creator,
                        "/projects/view/" + saved.getId(),
                        "PROJECT_CREATED"
                    );
                }
            }
        }

        return saved;
    }

    @Transactional
    @TenantSecure
    public void delete(String id) {
        Project p = repo.findById(id).orElse(null);
        if (p != null) {
            activityService.log("DELETED_PROJECT", "PROJECT", id, p.getName(), "Project deleted");
        }
        repo.deleteById(id);
    }

    public long countByStatus(String status) {
        Long tenantId = TenantContext.getTenant();
        if (tenantId == null) return 0;
        return repo.findByTenantIdAndStatus(tenantId, status).size();
    }

    private String getCurrentUsername() {
        try {
            return SecurityContextHolder.getContext().getAuthentication().getName();
        } catch (Exception e) {
            return "system";
        }
    }
}