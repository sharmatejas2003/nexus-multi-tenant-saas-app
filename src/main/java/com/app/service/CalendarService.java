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
    private final NotificationService notificationService;
 
    public CalendarService(CalendarEventRepository repo, NotificationService notificationService) {
        this.repo = repo;
        this.notificationService = notificationService;
    }
 
    public List<CalendarEvent> getAll() {
        Long tenantId = TenantContext.getTenant();
        if (tenantId == null) return new ArrayList<>();
        try {
            return repo.findByTenantIdOrderByStartDatetimeAsc(tenantId);
        } catch (Exception e) { return new ArrayList<>(); }
    }
 
    public List<CalendarEvent> getUpcoming() {
        Long tenantId = TenantContext.getTenant();
        if (tenantId == null) return new ArrayList<>();
        try {
            return repo.findUpcoming(tenantId, LocalDateTime.now());
        } catch (Exception e) { return new ArrayList<>(); }
    }
 
    @Transactional
    public CalendarEvent save(CalendarEvent event, String createdBy) {
        Long tenantId = TenantContext.getTenant();
        event.setTenantId(tenantId);
        event.setCreatedBy(createdBy);
        return repo.save(event);
    }
 
    @Transactional
    public void delete(Long id) {
        repo.deleteById(id);
    }
}
 