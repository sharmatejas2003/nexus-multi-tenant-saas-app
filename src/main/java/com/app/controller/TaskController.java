package com.app.controller;

import com.app.entity.*;
import com.app.repository.*;
import com.app.service.*;
import com.app.tenant.TenantContext;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import java.util.List;

@Controller
@RequestMapping("/tasks")
public class TaskController {

    private final TaskService taskService;
    private final FileService fileService;
    private final UserRepository userRepository;
    private final TaskCommentRepository commentRepo;
    private final TaskRepository taskRepo;
    private final ActivityService activityService;

    public TaskController(TaskService taskService, FileService fileService,
                          UserRepository userRepository, TaskCommentRepository commentRepo,
                          TaskRepository taskRepo, ActivityService activityService) {
        this.taskService = taskService;
        this.fileService = fileService;
        this.userRepository = userRepository;
        this.commentRepo = commentRepo;
        this.taskRepo = taskRepo;
        this.activityService = activityService;
    }

    @PostMapping("/save")
    public String saveTask(Task task,
                            @RequestParam(value = "files", required = false) List<MultipartFile> files,
                            Authentication auth) {
        // Only ADMIN/OWNER can create tasks
        if (!TenantContext.isAdminOrOwner()) {
            return "redirect:/projects/view/" + task.getProjectId() + "?error=permission_denied";
        }

        task.setTenantId(TenantContext.getTenant());
        if (task.getStatus() == null) task.setStatus("TODO");
        if (task.getPriority() == null) task.setPriority("MEDIUM");

        if (task.getAssignedTo() != null) {
            userRepository.findById(task.getAssignedTo())
                    .ifPresent(u -> task.setAssignedUsername(u.getUsername()));
        }

        Task saved = taskService.save(task);

        if (files != null && auth != null) {
            var user = userRepository.findByUsername(auth.getName());
            Long userId = user != null ? user.getId() : null;
            for (MultipartFile file : files) {
                if (!file.isEmpty()) {
                    try {
                        fileService.upload(file, "TASK", String.valueOf(saved.getId()), auth.getName(), userId);
                    } catch (Exception e) {
                        System.err.println("[TaskController] File upload error: " + e.getMessage());
                    }
                }
            }
        }
        return "redirect:/projects/view/" + saved.getProjectId();
    }

    @PostMapping("/delete/{id}")
    public String deleteTask(@PathVariable Long id, @RequestParam String projectId) {
        // Only ADMIN/OWNER can delete tasks
        if (!TenantContext.isAdminOrOwner()) {
            return "redirect:/projects/view/" + projectId + "?error=permission_denied";
        }
        taskService.delete(id);
        return "redirect:/projects/view/" + projectId;
    }

    @PostMapping("/update")
    public String updateTask(Task task, Authentication auth) {
        task.setTenantId(TenantContext.getTenant());

        // Members can only update tasks assigned to them (status change only)
        if (!TenantContext.isAdminOrOwner()) {
            // Member: only allowed to update status of their own tasks
            Task existing = taskRepo.findById(task.getId()).orElse(null);
            if (existing == null) return "redirect:/projects/view/" + task.getProjectId();
            if (!auth.getName().equals(existing.getAssignedUsername())) {
                return "redirect:/projects/view/" + task.getProjectId() + "?error=permission_denied";
            }
            // Only allow status update for members
            existing.setStatus(task.getStatus());
            existing.setTenantId(TenantContext.getTenant());
            taskService.save(existing);
            return "redirect:/projects/view/" + task.getProjectId();
        }

        if (task.getAssignedTo() != null) {
            userRepository.findById(task.getAssignedTo())
                    .ifPresent(u -> task.setAssignedUsername(u.getUsername()));
        }
        taskService.save(task);
        return "redirect:/projects/view/" + task.getProjectId();
    }

    @GetMapping("/detail/{id}")
    public String taskDetail(@PathVariable Long id, Model model) {
        Task task = taskRepo.findById(id).orElse(null);
        if (task == null || !task.getTenantId().equals(TenantContext.getTenant())) {
            return "redirect:/projects";
        }
        List<TaskComment> comments = commentRepo.findByTaskIdOrderByCreatedAtAsc(id);
        List<FileAttachment> attachments = fileService.getAttachments("TASK", String.valueOf(id));
        model.addAttribute("task", task);
        model.addAttribute("comments", comments);
        model.addAttribute("attachments", attachments);
        model.addAttribute("isAdminOrOwner", TenantContext.isAdminOrOwner());
        return "task-detail";
    }

    @PostMapping("/comment")
    public String addComment(@RequestParam Long taskId,
                              @RequestParam String content,
                              @RequestParam String projectId,
                              Authentication auth) {
        Task task = taskRepo.findById(taskId).orElse(null);
        if (task == null) return "redirect:/projects";

        TaskComment c = new TaskComment();
        c.setTaskId(taskId);
        c.setContent(content);
        c.setUsername(auth.getName());
        c.setTenantId(TenantContext.getTenant());
        commentRepo.save(c);
        activityService.log("ADDED_COMMENT", "TASK", String.valueOf(taskId), task.getTitle(), "Comment added");
        return "redirect:/tasks/detail/" + taskId;
    }
}