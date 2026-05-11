package com.app.entity;
 
import jakarta.persistence.*;
import java.time.LocalDateTime;
 
@Entity
@Table(name = "workspace_chat")
public class WorkspaceChat {
 
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
 
    @Column(name = "tenant_id", nullable = false)
    private Long tenantId;
 
    @Column(name = "sender_username", nullable = false)
    private String senderUsername;
 
    @Column(columnDefinition = "TEXT", nullable = false)
    private String message;
 
    @Column(name = "message_type")
    private String messageType = "TEXT";
 
    @Column(name = "reply_to_id")
    private Long replyToId;
 
    @Column(name = "created_at")
    private LocalDateTime createdAt;
 
    @Column(name = "is_deleted")
    private boolean deleted = false;
 
    @PrePersist
    public void prePersist() {
        if (this.createdAt == null) this.createdAt = LocalDateTime.now();
    }
 
    public String getTimeAgo() {
        if (createdAt == null) return "just now";
        long diff = java.time.Duration.between(createdAt, LocalDateTime.now()).toMinutes();
        if (diff < 1) return "just now";
        if (diff < 60) return diff + "m ago";
        if (diff < 1440) return (diff / 60) + "h ago";
        return (diff / 1440) + "d ago";
    }
 
    public String getInitial() {
        return (senderUsername != null && !senderUsername.isEmpty())
                ? senderUsername.substring(0, 1).toUpperCase() : "?";
    }
 
    // getters/setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public Long getTenantId() { return tenantId; }
    public void setTenantId(Long tenantId) { this.tenantId = tenantId; }
    public String getSenderUsername() { return senderUsername; }
    public void setSenderUsername(String senderUsername) { this.senderUsername = senderUsername; }
    public String getMessage() { return message; }
    public void setMessage(String message) { this.message = message; }
    public String getMessageType() { return messageType; }
    public void setMessageType(String messageType) { this.messageType = messageType; }
    public Long getReplyToId() { return replyToId; }
    public void setReplyToId(Long replyToId) { this.replyToId = replyToId; }
    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
    public boolean isDeleted() { return deleted; }
    public void setDeleted(boolean deleted) { this.deleted = deleted; }
}