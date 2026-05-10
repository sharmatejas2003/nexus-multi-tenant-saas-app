package com.app.entity;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "file_attachment")
public class FileAttachment {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    private String originalName;
    private String storedName;
    private String contentType;
    private Long fileSize;
    private String entityType;
    private String entityId;
    private Long tenantId;
    private Long uploadedBy;
    private String uploadedByUsername;
    private LocalDateTime uploadedAt;
    @Column(columnDefinition = "TEXT")
    private String storagePath;

    @PrePersist
    public void prePersist() { if (this.uploadedAt == null) this.uploadedAt = LocalDateTime.now(); }

    public String getFormattedSize() {
        if (fileSize == null) return "0 B";
        if (fileSize < 1024) return fileSize + " B";
        if (fileSize < 1024 * 1024) return String.format("%.1f KB", fileSize / 1024.0);
        return String.format("%.1f MB", fileSize / (1024.0 * 1024));
    }

    public String getFileIcon() {
        if (contentType == null) return "📄";
        if (contentType.startsWith("image/")) return "🖼️";
        if (contentType.contains("pdf")) return "📕";
        if (contentType.contains("word") || contentType.contains("document")) return "📝";
        if (contentType.contains("excel") || contentType.contains("spreadsheet")) return "📊";
        if (contentType.contains("zip") || contentType.contains("archive")) return "🗜️";
        if (contentType.startsWith("video/")) return "🎬";
        if (contentType.startsWith("audio/")) return "🎵";
        return "📎";
    }

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public String getOriginalName() { return originalName; }
    public void setOriginalName(String originalName) { this.originalName = originalName; }
    public String getStoredName() { return storedName; }
    public void setStoredName(String storedName) { this.storedName = storedName; }
    public String getContentType() { return contentType; }
    public void setContentType(String contentType) { this.contentType = contentType; }
    public Long getFileSize() { return fileSize; }
    public void setFileSize(Long fileSize) { this.fileSize = fileSize; }
    public String getEntityType() { return entityType; }
    public void setEntityType(String entityType) { this.entityType = entityType; }
    public String getEntityId() { return entityId; }
    public void setEntityId(String entityId) { this.entityId = entityId; }
    public Long getTenantId() { return tenantId; }
    public void setTenantId(Long tenantId) { this.tenantId = tenantId; }
    public Long getUploadedBy() { return uploadedBy; }
    public void setUploadedBy(Long uploadedBy) { this.uploadedBy = uploadedBy; }
    public String getUploadedByUsername() { return uploadedByUsername; }
    public void setUploadedByUsername(String uploadedByUsername) { this.uploadedByUsername = uploadedByUsername; }
    public LocalDateTime getUploadedAt() { return uploadedAt; }
    public void setUploadedAt(LocalDateTime uploadedAt) { this.uploadedAt = uploadedAt; }
    public String getStoragePath() { return storagePath; }
    public void setStoragePath(String storagePath) { this.storagePath = storagePath; }
}