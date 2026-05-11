package com.app.service;

import com.app.entity.Notification;
import com.app.repository.NotificationRepository;
import com.app.tenant.TenantContext;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Collections;
import java.util.List;

@Service
public class NotificationService {

    private final NotificationRepository repo;

    public NotificationService(NotificationRepository repo) {
        this.repo = repo;
    }

    /** Notify using current TenantContext */
    @Transactional
    public void notify(String forUsername, String message, String link, String type) {
        try {
            Long tenantId = TenantContext.getTenant();
            if (tenantId == null) {
                System.err.println("[NotificationService] notify() skipped — no tenant context for: " + forUsername);
                return;
            }
            notifyWithTenant(forUsername, message, link, type, tenantId);
        } catch (Exception e) {
            System.err.println("[NotificationService] notify() failed: " + e.getMessage());
        }
    }

    /** Notify with explicit tenantId — ALWAYS use this when tenant context may not be set */
    @Transactional
    public void notifyWithTenant(String forUsername, String message, String link,
                                  String type, Long tenantId) {
        if (forUsername == null || forUsername.isBlank()) return;
        if (tenantId == null) return;
        try {
            Notification n = new Notification();
            n.setTenantId(tenantId);
            n.setForUsername(forUsername);
            n.setMessage(message != null ? message : "");
            n.setLink(link);
            n.setType(type);
            n.setRead(false);
            repo.save(n);
            System.out.println("[NotificationService] Saved notification for " + forUsername
                    + " | type=" + type + " | tenant=" + tenantId);
        } catch (Exception e) {
            System.err.println("[NotificationService] notifyWithTenant() failed for " + forUsername + ": " + e.getMessage());
            e.printStackTrace();
        }
    }

    public List<Notification> getForUser(String username) {
        try {
            Long tenantId = TenantContext.getTenant();
            if (tenantId == null) return Collections.emptyList();
            return repo.findByForUsernameAndTenantIdOrderByCreatedAtDesc(username, tenantId);
        } catch (Exception e) {
            System.err.println("[NotificationService] getForUser error: " + e.getMessage());
            return Collections.emptyList();
        }
    }

    public List<Notification> getAllForUser(String username) {
        try {
            return repo.findByForUsernameOrderByCreatedAtDesc(username);
        } catch (Exception e) {
            return Collections.emptyList();
        }
    }

    public long countUnread(String username) {
        try {
            Long tenantId = TenantContext.getTenant();
            if (tenantId == null) return 0;
            return repo.countByForUsernameAndTenantIdAndRead(username, tenantId, false);
        } catch (Exception e) {
            return 0;
        }
    }

    public long countUnreadAll(String username) {
        try {
            return repo.countByForUsernameAndRead(username, false);
        } catch (Exception e) {
            return 0;
        }
    }

    @Transactional
    public void markAllRead(String username) {
        try {
            Long tenantId = TenantContext.getTenant();
            if (tenantId != null) {
                repo.markAllReadForUser(username, tenantId);
            }
        } catch (Exception e) {
            System.err.println("[NotificationService] markAllRead error: " + e.getMessage());
        }
    }
}