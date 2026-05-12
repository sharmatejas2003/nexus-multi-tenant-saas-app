package com.app.repository;

import com.app.entity.CalendarEvent;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.LocalDateTime;
import java.util.List;

public interface CalendarEventRepository extends JpaRepository<CalendarEvent, Long> {

    List<CalendarEvent> findByTenantIdOrderByStartDatetimeAsc(Long tenantId);

    @Query("SELECT e FROM CalendarEvent e WHERE e.tenantId = :tenantId AND e.startDatetime >= :start AND e.startDatetime <= :end ORDER BY e.startDatetime ASC")
    List<CalendarEvent> findByTenantIdAndRange(@Param("tenantId") Long tenantId,
                                               @Param("start") LocalDateTime start,
                                               @Param("end") LocalDateTime end);

    @Query("SELECT e FROM CalendarEvent e WHERE e.tenantId = :tenantId AND e.startDatetime >= :now ORDER BY e.startDatetime ASC")
    List<CalendarEvent> findUpcoming(@Param("tenantId") Long tenantId,
                                     @Param("now") LocalDateTime now);
}