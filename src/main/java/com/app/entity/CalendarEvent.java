package com.app.entity;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "calendar_event")
public class CalendarEvent {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "tenant_id", nullable = false)
    private Long tenantId;

    private String title;

    @Column(columnDefinition = "TEXT")
    private String description;

    @Column(name = "start_datetime")
    private LocalDateTime startDatetime;

    @Column(name = "end_datetime")
    private LocalDateTime endDatetime;

    @Column(name = "all_day")
    private boolean allDay = false;

    @Column(name = "event_type")
    private String eventType = "EVENT";

    private String color = "#6c63ff";

    @Column(name = "linked_project_id")
    private String linkedProjectId;

    @Column(name = "linked_task_id")
    private Long linkedTaskId;

    @Column(name = "created_by")
    private String createdBy;

    @Column(name = "created_at")
    private LocalDateTime createdAt;

    @PrePersist
    public void prePersist() {
        if (this.createdAt == null) this.createdAt = LocalDateTime.now();
    }

    public String getTypeIcon() {
        if (eventType == null) return "📅";
        return switch (eventType) {
            case "DEADLINE" -> "⏰";
            case "MEETING"  -> "🤝";
            case "REMINDER" -> "🔔";
            default         -> "📅";
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

    // Getters and setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public Long getTenantId() { return tenantId; }
    public void setTenantId(Long tenantId) { this.tenantId = tenantId; }
    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
    public LocalDateTime getStartDatetime() { return startDatetime; }
    public void setStartDatetime(LocalDateTime startDatetime) { this.startDatetime = startDatetime; }
    public LocalDateTime getEndDatetime() { return endDatetime; }
    public void setEndDatetime(LocalDateTime endDatetime) { this.endDatetime = endDatetime; }
    public boolean isAllDay() { return allDay; }
    public void setAllDay(boolean allDay) { this.allDay = allDay; }
    public String getEventType() { return eventType; }
    public void setEventType(String eventType) { this.eventType = eventType; }
    public String getColor() { return color; }
    public void setColor(String color) { this.color = color; }
    public String getLinkedProjectId() { return linkedProjectId; }
    public void setLinkedProjectId(String linkedProjectId) { this.linkedProjectId = linkedProjectId; }
    public Long getLinkedTaskId() { return linkedTaskId; }
    public void setLinkedTaskId(Long linkedTaskId) { this.linkedTaskId = linkedTaskId; }
    public String getCreatedBy() { return createdBy; }
    public void setCreatedBy(String createdBy) { this.createdBy = createdBy; }
    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
}