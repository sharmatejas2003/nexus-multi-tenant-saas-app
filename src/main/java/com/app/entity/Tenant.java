package com.app.entity;

import jakarta.persistence.*;

@Entity
@Table(name = "tenant")
public class Tenant {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String name;

    @Column(unique = true)
    private String slug;

    private String status;
    private Long ownerId;
    private String planType;          // FREE, PRO

    @Column(name = "workspace_type")
    private String workspaceType;     // PERSONAL, ORGANIZATION

    /* ── getters / setters ── */

    public Long getId()                        { return id; }
    public void setId(Long id)                 { this.id = id; }

    public String getName()                    { return name; }
    public void setName(String name)           { this.name = name; }

    public String getSlug()                    { return slug; }
    public void setSlug(String slug)           { this.slug = slug; }

    public String getStatus()                  { return status; }
    public void setStatus(String status)       { this.status = status; }

    public Long getOwnerId()                   { return ownerId; }
    public void setOwnerId(Long ownerId)       { this.ownerId = ownerId; }

    public String getPlanType()                { return planType; }
    public void setPlanType(String planType)   { this.planType = planType; }

    public String getWorkspaceType()           { return workspaceType; }
    public void setWorkspaceType(String t)     { this.workspaceType = t; }

    /** Convenience helpers used in JSPs */
    public boolean isPersonal()    { return "PERSONAL".equalsIgnoreCase(workspaceType); }
    public boolean isOrganization(){ return "ORGANIZATION".equalsIgnoreCase(workspaceType); }
}