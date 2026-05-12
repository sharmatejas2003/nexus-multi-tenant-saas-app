package com.app.service;

import com.app.entity.CalendarEvent;
import com.app.repository.CalendarEventRepository;
import com.app.tenant.TenantContext;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Service
public class CalendarService {

    private final CalendarEventRepository repo;

    public CalendarService(CalendarEventRepository repo) {
        this.repo = repo;
    }

    public List<CalendarEvent> getAll() {
        Long tenantId = TenantContext.getTenant();
        if (tenantId == null) return new ArrayList<>();
        try {
            return repo.findByTenantIdOrderByStartDatetimeAsc(tenantId);
        } catch (Exception e) {
            System.err.println("[CalendarService] getAll error: " + e.getMessage());
            return new ArrayList<>();
        }
    }

    public List<CalendarEvent> getUpcoming() {
        Long tenantId = TenantContext.getTenant();
        if (tenantId == null) return new ArrayList<>();
        try {
            return repo.findUpcoming(tenantId, LocalDateTime.now());
        } catch (Exception e) {
            System.err.println("[CalendarService] getUpcoming error: " + e.getMessage());
            return new ArrayList<>();
        }
    }

    @Transactional
    public CalendarEvent save(CalendarEvent event, String createdBy) {
        event.setTenantId(TenantContext.getTenant());
        event.setCreatedBy(createdBy);
        return repo.save(event);
    }

    @Transactional
    public void delete(Long id) {
        repo.deleteById(id);
    }
}