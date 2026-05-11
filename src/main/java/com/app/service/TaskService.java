package com.app.service;

import com.app.entity.Task;
import com.app.entity.User;
import com.app.repository.TaskRepository;
import com.app.repository.UserRepository;
import com.app.tenant.TenantContext;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;

@Service
public class TaskService {

    private final TaskRepository repo;
    private final ActivityService activityService;
    private final NotificationService notificationService;
    private final UserRepository userRepository;

    public TaskService(TaskRepository repo, ActivityService activityService,
                       NotificationService notificationService, UserRepository userRepository) {
        this.repo = repo;
        this.activityService = activityService;
        this.notificationService = notificationService;
        this.userRepository = userRepository;
    }

    @Transactional
    public Task save(Task task) {
        boolean isNew = (task.getId() == null);
        String currentUser = getCurrentUsername();
        Long tenantId = TenantContext.getTenant();

        if (tenantId == null) {
            throw new RuntimeException("No tenant context");
        }

        if ("DONE".equals(task.getStatus()) && task.getCompletedAt() == null) {
            task.setCompletedAt(LocalDateTime.now());
        }

        // Detect previous assignee (for update case)
        String previousAssignee = null;
        if (!isNew) {
            Task existing = repo.findById(task.getId()).orElse(null);
            if (existing != null) previousAssignee = existing.getAssignedUsername();
        }

        // Resolve assignedUsername from assignedTo ID
        if (task.getAssignedTo() != null) {
            try {
                userRepository.findById(task.getAssignedTo()).ifPresent(u ->
                    task.setAssignedUsername(u.getUsername())
                );
            } catch (Exception e) {
                System.err.println("[TaskService] Could not resolve assigned user: " + e.getMessage());
            }
        }

        // Ensure tenantId is set
        task.setTenantId(tenantId);

        Task saved = repo.save(task);

        if (isNew) {
            // Activity log
            safeLog("CREATED_TASK", "TASK", String.valueOf(saved.getId()),
                    saved.getTitle(), "Task created in project " + saved.getProjectId());

            // Notify assigned user
            sendAssignmentNotification(saved, currentUser, tenantId);

        } else {
            if ("DONE".equals(saved.getStatus())) {
                safeLog("COMPLETED_TASK", "TASK", String.valueOf(saved.getId()),
                        saved.getTitle(), "Task marked as done");
            }

            // Notify if assignee changed
            String newAssignee = saved.getAssignedUsername();
            if (newAssignee != null && !newAssignee.isBlank()
                    && !newAssignee.equals(previousAssignee)
                    && !newAssignee.equals(currentUser)) {
                sendAssignmentNotification(saved, currentUser, tenantId);
            }
        }

        return saved;
    }

    /**
     * Sends TASK_ASSIGNED notification.
     * Uses notifyWithTenant so it ALWAYS works even if TenantContext is somehow cleared.
     */
    private void sendAssignmentNotification(Task task, String assigner, Long tenantId) {
        String assignee = task.getAssignedUsername();
        if (assignee == null || assignee.isBlank()) return;
        if (assignee.equals(assigner)) return;

        try {
            String message = "✅ You've been assigned: \"" + task.getTitle() + "\" by " + assigner;
            String link = "/projects/view/" + task.getProjectId();
            notificationService.notifyWithTenant(assignee, message, link, "TASK_ASSIGNED", tenantId);
            System.out.println("[TaskService] Assignment notification sent to " + assignee);
        } catch (Exception e) {
            System.err.println("[TaskService] Failed to send notification: " + e.getMessage());
        }
    }

    private void safeLog(String action, String entityType, String entityId,
                          String entityName, String details) {
        try {
            activityService.log(action, entityType, entityId, entityName, details);
        } catch (Exception e) {
            System.err.println("[TaskService] Activity log failed: " + e.getMessage());
        }
    }

    @Transactional
    public void delete(Long id) {
        Task t = repo.findById(id).orElse(null);
        if (t != null) safeLog("DELETED_TASK", "TASK", String.valueOf(id), t.getTitle(), "Task deleted");
        repo.deleteById(id);
    }

    public List<Task> getByProject(String projectId) {
        List<Task> tasks = repo.findByProjectId(projectId);
        tasks.forEach(t -> {
            if (t.getDueDate() != null
                    && t.getDueDate().isBefore(LocalDateTime.now())
                    && !"DONE".equals(t.getStatus())) {
                t.setStatus("OVERDUE");
            }
        });
        return tasks;
    }

    public List<Task> getByAssignedUser(Long userId) {
        return repo.findByAssignedTo(userId);
    }

    public long countByStatus(String status) {
        Long tenantId = TenantContext.getTenant();
        if (tenantId == null) return 0;
        return repo.countByTenantIdAndStatus(tenantId, status);
    }

    private String getCurrentUsername() {
        try {
            return SecurityContextHolder.getContext().getAuthentication().getName();
        } catch (Exception e) {
            return "system";
        }
    }
}