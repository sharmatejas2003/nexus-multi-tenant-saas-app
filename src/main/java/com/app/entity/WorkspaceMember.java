package com.app.entity;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "workspace_members")
public class WorkspaceMember {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "user_id", nullable = false)
    private Long userId;

    @Column(name = "tenant_id", nullable = false)
    private Long tenantId;

    @Column(name = "role", nullable = false)
    private String role = "MEMBER";

    @Column(name = "joined_at")
    private LocalDateTime joinedAt;

    @PrePersist
    public void prePersist() {
        if (this.joinedAt == null) this.joinedAt = LocalDateTime.now();
    }

    // ── Getters / Setters ──
    public Long getId()                        { return id; }
    public void setId(Long id)                 { this.id = id; }

    public Long getUserId()                    { return userId; }
    public void setUserId(Long userId)         { this.userId = userId; }

    public Long getTenantId()                  { return tenantId; }
    public void setTenantId(Long tenantId)     { this.tenantId = tenantId; }

    public String getRole()                    { return role; }
    public void setRole(String role)           { this.role = role; }

    public LocalDateTime getJoinedAt()         { return joinedAt; }
    public void setJoinedAt(LocalDateTime j)   { this.joinedAt = j; }
}