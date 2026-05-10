package com.app.service;

import com.app.entity.Notification;
import com.app.repository.NotificationRepository;
import com.app.tenant.TenantContext;
import org.springframework.stereotype.Service;
import java.util.List;

@Service
public class NotificationService {
    private final NotificationRepository repo;

    public NotificationService(NotificationRepository repo) { this.repo = repo; }

    /** Notify using current TenantContext */
    public void notify(String forUsername, String message, String link, String type) {
        try {
            Long tenantId = TenantContext.getTenant();
            if (tenantId == null) return;
            notifyWithTenant(forUsername, message, link, type, tenantId);
        } catch (Exception e) {
            System.err.println("[NotificationService] Failed: " + e.getMessage());
        }
    }

    /** Notify with explicit tenantId (for use outside request context) */
    public void notifyWithTenant(String forUsername, String message, String link,
                                  String type, Long tenantId) {
        try {
            Notification n = new Notification();
            n.setTenantId(tenantId);
            n.setForUsername(forUsername);
            n.setMessage(message);
            n.setLink(link);
            n.setType(type);
            repo.save(n);
        } catch (Exception e) {
            System.err.println("[NotificationService] Failed: " + e.getMessage());
        }
    }

    public List<Notification> getForUser(String username) {
        Long tenantId = TenantContext.getTenant();
        if (tenantId == null) return List.of();
        return repo.findByForUsernameAndTenantIdOrderByCreatedAtDesc(username, tenantId);
    }

    /** Get ALL notifications for user across ALL their workspaces */
    public List<Notification> getAllForUser(String username) {
        return repo.findByForUsernameOrderByCreatedAtDesc(username);
    }

    public long countUnread(String username) {
        try {
            Long tenantId = TenantContext.getTenant();
            if (tenantId == null) return 0;
            return repo.countByForUsernameAndTenantIdAndRead(username, tenantId, false);
        } catch (Exception e) { return 0; }
    }

    /** Count unread across all workspaces */
    public long countUnreadAll(String username) {
        try {
            return repo.countByForUsernameAndRead(username, false);
        } catch (Exception e) { return 0; }
    }

    public void markAllRead(String username) {
        Long tenantId = TenantContext.getTenant();
        if (tenantId != null) {
            repo.markAllReadForUser(username, tenantId);
        }
    }
}