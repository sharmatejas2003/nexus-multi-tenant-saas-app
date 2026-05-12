package com.app.repository;

import com.app.entity.TimeEntry;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;

public interface TimeEntryRepository extends JpaRepository<TimeEntry, Long> {

    List<TimeEntry> findByTenantIdOrderByCreatedAtDesc(Long tenantId);

    List<TimeEntry> findByUsernameAndTenantIdOrderByCreatedAtDesc(String username, Long tenantId);

    @Query("SELECT t FROM TimeEntry t WHERE t.username = :username AND t.running = true ORDER BY t.startTime DESC LIMIT 1")
    Optional<TimeEntry> findFirstRunningByUsername(@Param("username") String username);

    @Query("SELECT COALESCE(SUM(t.durationMinutes), 0) FROM TimeEntry t WHERE t.tenantId = :tenantId")
    Long sumDurationByTenant(@Param("tenantId") Long tenantId);

    @Query("SELECT COALESCE(SUM(t.durationMinutes), 0) FROM TimeEntry t WHERE t.username = :username AND t.tenantId = :tenantId")
    Long sumDurationByUser(@Param("username") String username, @Param("tenantId") Long tenantId);
}