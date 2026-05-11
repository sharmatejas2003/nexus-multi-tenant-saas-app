package com.app.entity;
 
import jakarta.persistence.*;
import java.time.LocalDateTime;
 
@Entity
@Table(name = "time_entry")
public class TimeEntry {
 
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
 
    @Column(name = "tenant_id", nullable = false)
    private Long tenantId;
 
    @Column(name = "user_id")
    private Long userId;
 
    @Column(name = "username", nullable = false)
    private String username;
 
    @Column(name = "task_id")
    private Long taskId;
 
    @Column(name = "project_id")
    private String projectId;
 
    private String description;
 
    @Column(name = "start_time", nullable = false)
    private LocalDateTime startTime;
 
    @Column(name = "end_time")
    private LocalDateTime endTime;
 
    @Column(name = "duration_minutes")
    private Integer durationMinutes;
 
    @Column(name = "is_running")
    private boolean running = false;
 
    @Column(name = "created_at")
    private LocalDateTime createdAt;
 
    @PrePersist
    public void prePersist() {
        if (this.createdAt == null) this.createdAt = LocalDateTime.now();
    }
 
    public String getFormattedDuration() {
        if (durationMinutes == null) return "—";
        int h = durationMinutes / 60;
        int m = durationMinutes % 60;
        return h > 0 ? h + "h " + m + "m" : m + "m";
    }
 
    // getters/setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public Long getTenantId() { return tenantId; }
    public void setTenantId(Long tenantId) { this.tenantId = tenantId; }
    public Long getUserId() { return userId; }
    public void setUserId(Long userId) { this.userId = userId; }
    public String getUsername() { return username; }
    public void setUsername(String username) { this.username = username; }
    public Long getTaskId() { return taskId; }
    public void setTaskId(Long taskId) { this.taskId = taskId; }
    public String getProjectId() { return projectId; }
    public void setProjectId(String projectId) { this.projectId = projectId; }
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
    public LocalDateTime getStartTime() { return startTime; }
    public void setStartTime(LocalDateTime startTime) { this.startTime = startTime; }
    public LocalDateTime getEndTime() { return endTime; }
    public void setEndTime(LocalDateTime endTime) { this.endTime = endTime; }
    public Integer getDurationMinutes() { return durationMinutes; }
    public void setDurationMinutes(Integer durationMinutes) { this.durationMinutes = durationMinutes; }
    public boolean isRunning() { return running; }
    public void setRunning(boolean running) { this.running = running; }
    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
}