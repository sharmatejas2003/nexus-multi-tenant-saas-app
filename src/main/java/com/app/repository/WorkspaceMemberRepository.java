package com.app.repository;

import com.app.entity.WorkspaceMember;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;

public interface WorkspaceMemberRepository extends JpaRepository<WorkspaceMember, Long> {

    List<WorkspaceMember> findByUserId(Long userId);
    List<WorkspaceMember> findByTenantId(Long tenantId);

    Optional<WorkspaceMember> findByUserIdAndTenantId(Long userId, Long tenantId);

    boolean existsByUserIdAndTenantId(Long userId, Long tenantId);

    // ✅ Correct method for finding by username
    List<WorkspaceMember> findByUserUsername(String username);

    @Query("""
       SELECT wm 
       FROM WorkspaceMember wm 
       WHERE wm.tenantId = :tenantId 
       AND wm.role IN ('OWNER', 'ADMIN')
    """)
    List<WorkspaceMember> findAdminsAndOwnersByTenantId(@Param("tenantId") Long tenantId);

    List<WorkspaceMember> findByTenantIdAndRole(Long tenantId, String role);
}