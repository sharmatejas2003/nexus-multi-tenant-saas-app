package com.app.service;

import com.app.entity.Task;
import com.app.repository.TaskRepository;
import com.app.repository.UserRepository;
import com.app.tenant.TenantContext;
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
        if ("DONE".equals(task.getStatus()) && task.getCompletedAt() == null) {
            task.setCompletedAt(LocalDateTime.now());
        }
        Task saved = repo.save(task);

        if (isNew) {
            activityService.log("CREATED_TASK", "TASK", String.valueOf(saved.getId()),
                    saved.getTitle(), "Task created in project " + saved.getProjectId());

            // Notify assigned user
            if (saved.getAssignedUsername() != null && !saved.getAssignedUsername().isEmpty()) {
                notificationService.notify(
                    saved.getAssignedUsername(),
                    "You were assigned a new task: " + saved.getTitle(),
                    "/projects/view/" + saved.getProjectId(),
                    "TASK_ASSIGNED"
                );
            }
        } else if ("DONE".equals(saved.getStatus())) {
            activityService.log("COMPLETED_TASK", "TASK", String.valueOf(saved.getId()),
                    saved.getTitle(), "Task marked as done");
        }
        return saved;
    }

    @Transactional
    public void delete(Long id) {
        Task t = repo.findById(id).orElse(null);
        if (t != null) activityService.log("DELETED_TASK", "TASK", String.valueOf(id), t.getTitle(), "Task deleted");
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

    public List<Task> getByAssignedUser(Long userId) { return repo.findByAssignedTo(userId); }

    public long countByStatus(String status) {
        Long tenantId = TenantContext.getTenant();
        if (tenantId == null) return 0;
        return repo.countByTenantIdAndStatus(tenantId, status);
    }
}