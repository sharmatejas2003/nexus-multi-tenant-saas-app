package com.app.repository;
import com.app.entity.ActivityLog;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;
public interface ActivityLogRepository extends JpaRepository<ActivityLog, Long> {
    List<ActivityLog> findByTenantIdOrderByCreatedAtDesc(Long tenantId);
    List<ActivityLog> findTop20ByTenantIdOrderByCreatedAtDesc(Long tenantId);
}