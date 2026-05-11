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

        if ("DONE".equals(task.getStatus()) && task.getCompletedAt() == null) {
            task.setCompletedAt(LocalDateTime.now());
        }

        // Detect assignment change for existing tasks
        String previousAssignee = null;
        if (!isNew) {
            Task existing = repo.findById(task.getId()).orElse(null);
            if (existing != null) {
                previousAssignee = existing.getAssignedUsername();
            }
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

        Task saved = repo.save(task);

        if (isNew) {
            // Log activity
            try {
                activityService.log("CREATED_TASK", "TASK", String.valueOf(saved.getId()),
                        saved.getTitle(), "Task created in project " + saved.getProjectId());
            } catch (Exception e) {
                System.err.println("[TaskService] Activity log error: " + e.getMessage());
            }

            // CRITICAL: Notify the assigned user
            if (saved.getAssignedUsername() != null && !saved.getAssignedUsername().isEmpty()
                    && !saved.getAssignedUsername().equals(currentUser)) {
                try {
                    String message = "✅ You've been assigned a new task: \"" + saved.getTitle() + "\" by " + currentUser;
                    if (tenantId != null) {
                        notificationService.notifyWithTenant(
                            saved.getAssignedUsername(),
                            message,
                            "/tasks/detail/" + saved.getId(),
                            "TASK_ASSIGNED",
                            tenantId
                        );
                        System.out.println("[TaskService] Notification sent to: " + saved.getAssignedUsername());
                    } else {
                        notificationService.notify(
                            saved.getAssignedUsername(),
                            message,
                            "/tasks/detail/" + saved.getId(),
                            "TASK_ASSIGNED"
                        );
                    }
                } catch (Exception e) {
                    System.err.println("[TaskService] Notification error: " + e.getMessage());
                }
            }
        } else {
            // Task updated
            if ("DONE".equals(saved.getStatus())) {
                try {
                    activityService.log("COMPLETED_TASK", "TASK", String.valueOf(saved.getId()),
                            saved.getTitle(), "Task marked as done");
                } catch (Exception ignored) {}
            }

            // Notify if assignee changed
            String newAssignee = saved.getAssignedUsername();
            if (newAssignee != null && !newAssignee.isEmpty()
                    && !newAssignee.equals(previousAssignee)
                    && !newAssignee.equals(currentUser)) {
                try {
                    String message = "✅ You've been assigned task: \"" + saved.getTitle() + "\" by " + currentUser;
                    if (tenantId != null) {
                        notificationService.notifyWithTenant(
                            newAssignee,
                            message,
                            "/tasks/detail/" + saved.getId(),
                            "TASK_ASSIGNED",
                            tenantId
                        );
                    } else {
                        notificationService.notify(newAssignee, message, "/tasks/detail/" + saved.getId(), "TASK_ASSIGNED");
                    }
                } catch (Exception e) {
                    System.err.println("[TaskService] Notification error on update: " + e.getMessage());
                }
            }
        }
        return saved;
    }

    @Transactional
    public void delete(Long id) {
        Task t = repo.findById(id).orElse(null);
        if (t != null) {
            try { activityService.log("DELETED_TASK", "TASK", String.valueOf(id), t.getTitle(), "Task deleted"); }
            catch (Exception ignored) {}
        }
        repo.deleteById(id);
    }

    public List<Task> getByProject(String projectId) {
        List<Task> tasks = repo.findByProjectId(projectId);
        tasks.forEach(t -> {
            if (t.getDueDate() != null && t.getDueDate().isBefore(LocalDateTime.now()) && !"DONE".equals(t.getStatus())) {
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