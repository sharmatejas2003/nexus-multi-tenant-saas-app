package com.app.repository;
 
import com.app.entity.WorkspaceChat;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
 
public interface WorkspaceChatRepository extends JpaRepository<WorkspaceChat, Long> {
    @Query("SELECT c FROM WorkspaceChat c WHERE c.tenantId = :tenantId AND c.deleted = false ORDER BY c.createdAt ASC")
    List<WorkspaceChat> findByTenantIdAndNotDeleted(@Param("tenantId") Long tenantId);
 
    @Query("SELECT c FROM WorkspaceChat c WHERE c.tenantId = :tenantId AND c.deleted = false ORDER BY c.createdAt DESC LIMIT 50")
    List<WorkspaceChat> findTop50ByTenantIdOrderByCreatedAtDesc(@Param("tenantId") Long tenantId);
 
    long countByTenantId(Long tenantId);
}