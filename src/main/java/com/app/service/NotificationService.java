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

    public void notify(String forUsername, String message, String link, String type) {
        try {
            Notification n = new Notification();
            n.setTenantId(TenantContext.getTenant());
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
        return repo.findByForUsernameAndTenantIdOrderByCreatedAtDesc(username, TenantContext.getTenant());
    }

    public long countUnread(String username) {
        try {
            return repo.countByForUsernameAndTenantIdAndRead(username, TenantContext.getTenant(), false);
        } catch (Exception e) { return 0; }
    }

    public void markAllRead(String username) {
        repo.markAllReadForUser(username, TenantContext.getTenant());
    }
}