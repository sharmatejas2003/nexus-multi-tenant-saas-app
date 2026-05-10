package com.app.entity;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "activity_log")
public class ActivityLog {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    private Long tenantId;
    private String username;
    private String action;
    private String entityType;
    private String entityId;
    private String entityName;
    private String details;
    private LocalDateTime createdAt;

    @PrePersist
    public void prePersist() { if (this.createdAt == null) this.createdAt = LocalDateTime.now(); }

    public String getActionEmoji() {
        if (action == null) return "📌";
        return switch (action) {
            case "CREATED_PROJECT" -> "🚀";
            case "DELETED_PROJECT" -> "🗑️";
            case "CREATED_TASK"    -> "✅";
            case "COMPLETED_TASK"  -> "🎯";
            case "DELETED_TASK"    -> "❌";
            case "UPLOADED_FILE"   -> "📎";
            case "CREATED_NOTE"    -> "📝";
            case "INVITED_MEMBER"  -> "✉️";
            case "PROMOTED_MEMBER" -> "⬆️";
            case "REMOVED_MEMBER"  -> "👋";
            case "ADDED_COMMENT"   -> "💬";
            default -> "📌";
        };
    }

    public String getTimeAgo() {
        if (createdAt == null) return "just now";
        long diff = java.time.Duration.between(createdAt, LocalDateTime.now()).toMinutes();
        if (diff < 1) return "just now";
        if (diff < 60) return diff + "m ago";
        if (diff < 1440) return (diff / 60) + "h ago";
        return (diff / 1440) + "d ago";
    }

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public Long getTenantId() { return tenantId; }
    public void setTenantId(Long tenantId) { this.tenantId = tenantId; }
    public String getUsername() { return username; }
    public void setUsername(String username) { this.username = username; }
    public String getAction() { return action; }
    public void setAction(String action) { this.action = action; }
    public String getEntityType() { return entityType; }
    public void setEntityType(String entityType) { this.entityType = entityType; }
    public String getEntityId() { return entityId; }
    public void setEntityId(String entityId) { this.entityId = entityId; }
    public String getEntityName() { return entityName; }
    public void setEntityName(String entityName) { this.entityName = entityName; }
    public String getDetails() { return details; }
    public void setDetails(String details) { this.details = details; }
    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
}