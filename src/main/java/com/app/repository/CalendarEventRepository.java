package com.app.repository;

import java.time.LocalDateTime;
import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import com.app.entity.CalendarEvent;

public interface CalendarEventRepository extends JpaRepository<CalendarEvent, Long> {
	List<CalendarEvent> findByTenantIdOrderByStartDatetimeAsc(Long tenantId);
	 
    @Query("SELECT e FROM CalendarEvent e WHERE e.tenantId = :tenantId AND e.startDatetime >= :start AND e.startDatetime <= :end ORDER BY e.startDatetime ASC")
    List<CalendarEvent> findByTenantIdAndRange(Long tenantId, LocalDateTime start, LocalDateTime end);
 
    @Query("SELECT e FROM CalendarEvent e WHERE e.tenantId = :tenantId AND e.startDatetime >= :now ORDER BY e.startDatetime ASC")
    List<CalendarEvent> findUpcoming(Long tenantId, LocalDateTime now);

}