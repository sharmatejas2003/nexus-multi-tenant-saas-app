package com.app.service;

import com.app.entity.ActivityLog;
import com.app.repository.ActivityLogRepository;
import com.app.tenant.TenantContext;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class ActivityService {

    private final ActivityLogRepository repo;

    public ActivityService(ActivityLogRepository repo) {
        this.repo = repo;
    }

    public void log(String action, String entityType, String entityId, String entityName, String details) {
        try {
            ActivityLog log = new ActivityLog();
            log.setTenantId(TenantContext.getTenant());
            log.setAction(action);
            log.setEntityType(entityType);
            log.setEntityId(entityId);
            log.setEntityName(entityName);
            log.setDetails(details);
            try {
                log.setUsername(SecurityContextHolder.getContext().getAuthentication().getName());
            } catch (Exception e) {
                log.setUsername("system");
            }
            repo.save(log);
        } catch (Exception e) {
            System.err.println("[ActivityService] Could not log activity: " + e.getMessage());
        }
    }

    public List<ActivityLog> getRecentActivity() {
        return repo.findTop20ByTenantIdOrderByCreatedAtDesc(TenantContext.getTenant());
    }

    public List<ActivityLog> getAllActivity() {
        return repo.findByTenantIdOrderByCreatedAtDesc(TenantContext.getTenant());
    }
}