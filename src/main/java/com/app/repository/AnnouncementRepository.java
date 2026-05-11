package com.app.repository;

import com.app.entity.Announcement;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import java.util.List;

public interface AnnouncementRepository extends JpaRepository<Announcement, Long> {

    @Query("SELECT a FROM Announcement a WHERE a.tenantId = :tenantId ORDER BY a.pinned DESC, a.createdAt DESC")
    List<Announcement> findByTenantIdOrderByPinnedDescCreatedAtDesc(Long tenantId);

    @Query("SELECT a FROM Announcement a WHERE a.tenantId = :tenantId AND a.pinned = true ORDER BY a.createdAt DESC")
    List<Announcement> findByTenantIdAndPinnedTrueOrderByCreatedAtDesc(Long tenantId);
}