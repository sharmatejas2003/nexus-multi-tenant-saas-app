package com.app.service;
 
import com.app.entity.TimeEntry;
import com.app.repository.TimeEntryRepository;
import com.app.tenant.TenantContext;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.time.Duration;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
 
@Service
public class TimeTrackingService {
 
    private final TimeEntryRepository repo;
 
    public TimeTrackingService(TimeEntryRepository repo) {
        this.repo = repo;
    }
 
    @Transactional
    public TimeEntry start(String username, Long userId, String description, String projectId, Long taskId) {
        Long tenantId = TenantContext.getTenant();
        // Stop any running timer first
        repo.findFirstRunningByUsername(username).ifPresent(running -> {
            stop(running);
        });
 
        TimeEntry entry = new TimeEntry();
        entry.setTenantId(tenantId);
        entry.setUserId(userId);
        entry.setUsername(username);
        entry.setDescription(description);
        entry.setProjectId(projectId);
        entry.setTaskId(taskId);
        entry.setStartTime(LocalDateTime.now());
        entry.setRunning(true);
        return repo.save(entry);
    }
 
    @Transactional
    public TimeEntry stop(TimeEntry entry) {
        entry.setEndTime(LocalDateTime.now());
        entry.setRunning(false);
        long minutes = Duration.between(entry.getStartTime(), entry.getEndTime()).toMinutes();
        entry.setDurationMinutes((int) minutes);
        return repo.save(entry);
    }
 
    @Transactional
    public TimeEntry stopCurrent(String username) {
        Optional<TimeEntry> running = repo.findFirstRunningByUsername(username);
        if (running.isPresent()) {
            return stop(running.get());
        }
        return null;
    }
 
    public Optional<TimeEntry> getRunning(String username) {
        try {
            return repo.findFirstRunningByUsername(username);
        } catch (Exception e) { return Optional.empty(); }
    }
 
    public List<TimeEntry> getForUser(String username) {
        Long tenantId = TenantContext.getTenant();
        if (tenantId == null) return new ArrayList<>();
        try {
            return repo.findByUsernameAndTenantIdOrderByCreatedAtDesc(username, tenantId);
        } catch (Exception e) { return new ArrayList<>(); }
    }
 
    public List<TimeEntry> getForTenant() {
        Long tenantId = TenantContext.getTenant();
        if (tenantId == null) return new ArrayList<>();
        try {
            return repo.findByTenantIdOrderByCreatedAtDesc(tenantId);
        } catch (Exception e) { return new ArrayList<>(); }
    }
 
    public long getTotalMinutes() {
        Long tenantId = TenantContext.getTenant();
        if (tenantId == null) return 0;
        try {
            Long total = repo.sumDurationByTenant(tenantId);
            return total != null ? total : 0;
        } catch (Exception e) { return 0; }
    }
}