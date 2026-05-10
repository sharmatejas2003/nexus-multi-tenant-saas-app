package com.app.repository;

import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import com.app.entity.Project;

public interface ProjectRepository extends JpaRepository<Project,String>{
	@Query("SELECT p FROM Project p WHERE p.tenantId = :tenantId")
    List<Project> findByTenantId(Long tenantId);
    long countByTenantId(Long tenantId);
    @Query("SELECT p FROM Project p WHERE p.tenantId = :tenantId AND p.status = :status")
    List<Project> findByTenantIdAndStatus(Long tenantId, String status);

}
