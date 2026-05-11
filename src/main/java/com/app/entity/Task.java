package com.app.entity;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "task")
public class Task {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String title;

    @Column(columnDefinition = "TEXT")
    private String description;

    private String projectId;
    private Long tenantId;
    private String status; // TODO, IN_PROGRESS, IN_REVIEW, DONE, OVERDUE
    private String priority; // LOW, MEDIUM, HIGH, CRITICAL
    private Long assignedTo;
    private String assignedUsername;
    private LocalDateTime dueDate;
    private LocalDateTime createdAt;
    private LocalDateTime completedAt;

    // Used to store comment count (repurposed field)
    @Transient
    private String attachments;

    @PrePersist
    public void prePersist() {
        if (this.createdAt == null) this.createdAt = LocalDateTime.now();
        if (this.status == null) this.status = "TODO";
        if (this.priority == null) this.priority = "MEDIUM";
    }

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
    public String getProjectId() { return projectId; }
    public void setProjectId(String projectId) { this.projectId = projectId; }
    public Long getTenantId() { return tenantId; }
    public void setTenantId(Long tenantId) { this.tenantId = tenantId; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public String getPriority() { return priority; }
    public void setPriority(String priority) { this.priority = priority; }
    public Long getAssignedTo() { return assignedTo; }
    public void setAssignedTo(Long assignedTo) { this.assignedTo = assignedTo; }
    public String getAssignedUsername() { return assignedUsername; }
    public void setAssignedUsername(String assignedUsername) { this.assignedUsername = assignedUsername; }
    public LocalDateTime getDueDate() { return dueDate; }
    public void setDueDate(LocalDateTime dueDate) { this.dueDate = dueDate; }
    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
    public LocalDateTime getCompletedAt() { return completedAt; }
    public void setCompletedAt(LocalDateTime completedAt) { this.completedAt = completedAt; }
    public String getAttachments() { return attachments; }
    public void setAttachments(String attachments) { this.attachments = attachments; }

    public boolean isOverdue() {
        return dueDate != null && dueDate.isBefore(LocalDateTime.now()) && !"DONE".equals(status);
    }

    public String getPriorityColor() {
        if (priority == null) return "#8888aa";
        return switch (priority) {
            case "LOW" -> "#43e97b";
            case "MEDIUM" -> "#f9ca24";
            case "HIGH" -> "#ff6584";
            case "CRITICAL" -> "#ff0000";
            default -> "#8888aa";
        };
    }

    public String getStatusColor() {
        if (status == null) return "#8888aa";
        return switch (status) {
            case "DONE" -> "#43e97b";
            case "IN_PROGRESS" -> "#6c63ff";
            case "IN_REVIEW" -> "#38bdf8";
            case "OVERDUE" -> "#ff6584";
            default -> "#8888aa";
        };
    }
}