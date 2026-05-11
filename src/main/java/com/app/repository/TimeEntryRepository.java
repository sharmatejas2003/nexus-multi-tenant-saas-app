package com.app.repository;
 
import com.app.entity.TimeEntry;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import java.util.List;
import java.util.Optional;
 
public interface TimeEntryRepository extends JpaRepository<TimeEntry, Long> {
    List<TimeEntry> findByTenantIdOrderByCreatedAtDesc(Long tenantId);
    List<TimeEntry> findByUsernameAndTenantIdOrderByCreatedAtDesc(String username, Long tenantId);
    Optional<TimeEntry> findByUsernameAndRunningTrue(String username);
 
    @Query("SELECT COALESCE(SUM(t.durationMinutes),0) FROM TimeEntry t WHERE t.tenantId = :tenantId")
    Long sumDurationByTenant(Long tenantId);
 
    @Query("SELECT COALESCE(SUM(t.durationMinutes),0) FROM TimeEntry t WHERE t.username = :username AND t.tenantId = :tenantId")
    Long sumDurationByUser(String username, Long tenantId);
}