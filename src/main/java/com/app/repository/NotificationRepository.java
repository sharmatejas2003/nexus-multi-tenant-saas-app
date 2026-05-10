package com.app.repository;

import java.util.List;

import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.repository.query.Param;
import org.springframework.transaction.annotation.Transactional;

import com.app.entity.Notification;

public interface NotificationRepository extends JpaRepository<Notification, Long> {

    List<Notification> findByForUsernameAndTenantIdOrderByCreatedAtDesc(String username, Long tenantId);

    /** All notifications for user across all workspaces */
    List<Notification> findByForUsernameOrderByCreatedAtDesc(String username);

    long countByForUsernameAndTenantIdAndRead(String username, Long tenantId, boolean read);

    /** Count unread across all workspaces */
    long countByForUsernameAndRead(String username, boolean read);

    @Modifying
    @Transactional
    @Query("UPDATE Notification n SET n.read = true WHERE n.forUsername = :username AND n.tenantId = :tenantId")
    void markAllReadForUser(@Param("username") String username, @Param("tenantId") Long tenantId);
}