package com.app.repository;

import com.app.entity.Notification;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

public interface NotificationRepository
        extends JpaRepository<Notification, Long> {

    // Tenant-based notifications
    List<Notification>
    findByForUsernameAndTenantIdOrderByCreatedAtDesc(
            String username,
            Long tenantId
    );

    long countByForUsernameAndTenantIdAndRead(
            String username,
            Long tenantId,
            boolean read
    );

    // Global notifications (ALL workspaces)
    List<Notification>
    findByForUsernameOrderByCreatedAtDesc(
            String username
    );

    long countByForUsernameAndRead(
            String username,
            boolean read
    );

    @Modifying
    @Transactional
    @Query("""
        UPDATE Notification n
        SET n.read = true
        WHERE n.forUsername = :username
        AND n.tenantId = :tenantId
    """)
    void markAllReadForUser(
            @Param("username") String username,
            @Param("tenantId") Long tenantId
    );
}