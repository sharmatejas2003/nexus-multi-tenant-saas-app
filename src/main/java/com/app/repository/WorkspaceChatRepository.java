package com.app.repository;

import com.app.entity.WorkspaceChat;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;

public interface WorkspaceChatRepository extends JpaRepository<WorkspaceChat, Long> {

    @Query("SELECT c FROM WorkspaceChat c WHERE c.tenantId = :tenantId AND c.deleted = false ORDER BY c.createdAt ASC")
    List<WorkspaceChat> findByTenantIdAndNotDeleted(@Param("tenantId") Long tenantId);

    // FIXED: removed invalid JPQL LIMIT — use Spring Data method naming instead
    List<WorkspaceChat> findTop50ByTenantIdAndDeletedFalseOrderByCreatedAtDesc(Long tenantId);

    long countByTenantId(Long tenantId);
}