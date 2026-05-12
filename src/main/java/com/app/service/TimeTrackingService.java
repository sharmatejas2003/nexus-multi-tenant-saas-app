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
        if (tenantId == null) throw new RuntimeException("No tenant context");

        // Stop any existing running timer
        repo.findTopByUsernameAndRunningTrueOrderByStartTimeDesc(username).ifPresent(this::stop);

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
        if (entry.getEndTime() == null) {
            entry.setEndTime(LocalDateTime.now());
        }
        entry.setRunning(false);
        long minutes = Duration.between(entry.getStartTime(), entry.getEndTime()).toMinutes();
        entry.setDurationMinutes((int) minutes);
        return repo.save(entry);
    }

    @Transactional
    public TimeEntry stopCurrent(String username) {
        Optional<TimeEntry> running = repo.findTopByUsernameAndRunningTrueOrderByStartTimeDesc(username);
        return running.map(this::stop).orElse(null);
    }

    public Optional<TimeEntry> getRunning(String username) {
        return repo.findTopByUsernameAndRunningTrueOrderByStartTimeDesc(username);
    }

    public List<TimeEntry> getForUser(String username) {
        Long tenantId = TenantContext.getTenant();
        if (tenantId == null) return new ArrayList<>();
        return repo.findByUsernameAndTenantIdOrderByCreatedAtDesc(username, tenantId);
    }

    public List<TimeEntry> getForTenant() {
        Long tenantId = TenantContext.getTenant();
        if (tenantId == null) return new ArrayList<>();
        return repo.findByTenantIdOrderByCreatedAtDesc(tenantId);
    }

    public long getTotalMinutes() {
        Long tenantId = TenantContext.getTenant();
        if (tenantId == null) return 0;
        Long total = repo.sumDurationByTenant(tenantId);
        return total != null ? total : 0;
    }
}