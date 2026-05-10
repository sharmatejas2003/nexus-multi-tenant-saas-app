package com.app.repository;

import com.app.entity.Task;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import java.util.List;

public interface TaskRepository extends JpaRepository<Task, Long> {
	 List<Task> findByProjectId(String projectId);
	    List<Task> findByTenantId(Long tenantId);
	    List<Task> findByAssignedTo(Long userId);
	    long countByTenantIdAndStatus(Long tenantId, String status);
	    long countByProjectId(String projectId);
	    @Query("SELECT t FROM Task t WHERE t.tenantId = :tenantId ORDER BY t.createdAt DESC")
	    List<Task> findRecentByTenantId(Long tenantId);
	    @Query("SELECT t FROM Task t WHERE t.tenantId = :tenantId AND t.status != 'DONE' AND t.dueDate IS NOT NULL ORDER BY t.dueDate ASC")
	    List<Task> findUpcomingByTenantId(Long tenantId);
}