package com.app.entity;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "notification")
public class Notification {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    private Long tenantId;
    private String forUsername;
    private String message;
    private String link;

    @Column(name = "is_read")
    private boolean read = false;

    @Column(name = "type")
    private String type; // TASK_ASSIGNED, COMMENT_ADDED, MEMBER_INVITED, PROJECT_CREATED, MEMBER_JOINED

    @Column(name = "created_at")
    private LocalDateTime createdAt;

    @PrePersist
    public void prePersist() { if (createdAt == null) createdAt = LocalDateTime.now(); }

    public String getTimeAgo() {
        if (createdAt == null) return "just now";
        long diff = java.time.Duration.between(createdAt, LocalDateTime.now()).toMinutes();
        if (diff < 1) return "just now";
        if (diff < 60) return diff + "m ago";
        if (diff < 1440) return (diff / 60) + "h ago";
        return (diff / 1440) + "d ago";
    }

    public String getTypeIcon() {
        if (type == null) return "🔔";
        return switch (type) {
            case "TASK_ASSIGNED"    -> "✅";
            case "COMMENT_ADDED"    -> "💬";
            case "MEMBER_INVITED"   -> "✉️";
            case "MEMBER_JOINED"    -> "👋";
            case "PROJECT_CREATED"  -> "🚀";
            default -> "🔔";
        };
    }

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public Long getTenantId() { return tenantId; }
    public void setTenantId(Long tenantId) { this.tenantId = tenantId; }
    public String getForUsername() { return forUsername; }
    public void setForUsername(String forUsername) { this.forUsername = forUsername; }
    public String getMessage() { return message; }
    public void setMessage(String message) { this.message = message; }
    public String getLink() { return link; }
    public void setLink(String link) { this.link = link; }
    public boolean isRead() { return read; }
    public void setRead(boolean read) { this.read = read; }
    public String getType() { return type; }
    public void setType(String type) { this.type = type; }
    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
}