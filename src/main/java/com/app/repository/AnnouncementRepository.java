package com.app.repository;
 
import com.app.entity.Announcement;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;
 
public interface AnnouncementRepository extends JpaRepository<Announcement, Long> {
    List<Announcement> findByTenantIdOrderByPinnedDescCreatedAtDesc(Long tenantId);
    List<Announcement> findByTenantIdAndPinnedTrueOrderByCreatedAtDesc(Long tenantId);
}