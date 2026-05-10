package com.app.dto;

public class ProjectSummaryDTO {
    private String projectName;
    private String ownerName;
    private String tenantName;

    public ProjectSummaryDTO(String projectName, String ownerName, String tenantName) {
        this.projectName = projectName;
        this.ownerName = ownerName;
        this.tenantName = tenantName;
    }
    // Getters
    public String getProjectName() { return projectName; }
    public String getOwnerName() { return ownerName; }
    public String getTenantName() { return tenantName; }
}