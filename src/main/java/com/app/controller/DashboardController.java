package com.app.controller;

import com.app.repository.*;
import com.app.service.*;
import com.app.tenant.TenantContext;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class DashboardController {

    private final ProjectService projectService;
    private final UserRepository userRepository;
    private final TaskRepository taskRepository;
    private final ActivityService activityService;
    private final FileAttachmentRepository fileRepo;
    private final NotificationService notificationService;
    private final TenantRepository tenantRepository;

    public DashboardController(ProjectService projectService,
                                UserRepository userRepository,
                                TaskRepository taskRepository,
                                ActivityService activityService,
                                FileAttachmentRepository fileRepo,
                                NotificationService notificationService,
                                TenantRepository tenantRepository) {
        this.projectService = projectService;
        this.userRepository = userRepository;
        this.taskRepository = taskRepository;
        this.activityService = activityService;
        this.fileRepo = fileRepo;
        this.notificationService = notificationService;
        this.tenantRepository = tenantRepository;
    }

    @GetMapping("/dashboard")
    public String dashboard(Model model, Authentication auth) {
        Long tenantId = TenantContext.getTenant();
        if (tenantId == null) return "redirect:/login";

        var projects      = projectService.getAll();
        var members       = userRepository.findByTenantId(tenantId);
        var recentActivity = activityService.getRecentActivity();

        long tasksDone       = taskRepository.countByTenantIdAndStatus(tenantId, "DONE");
        long tasksInProgress = taskRepository.countByTenantIdAndStatus(tenantId, "IN_PROGRESS");
        long tasksTodo       = taskRepository.countByTenantIdAndStatus(tenantId, "TODO");
        long tasksOverdue    = taskRepository.countByTenantIdAndStatus(tenantId, "OVERDUE");
        long totalFiles      = fileRepo.countByTenantId(tenantId);

        var recentTasks = taskRepository.findRecentByTenantId(tenantId);

        long unreadNotifications = 0;
        if (auth != null) unreadNotifications = notificationService.countUnread(auth.getName());

        model.addAttribute("projects",       projects);
        model.addAttribute("members",        members);
        model.addAttribute("recentActivity", recentActivity);
        model.addAttribute("tasksDone",      tasksDone);
        model.addAttribute("tasksInProgress",tasksInProgress);
        model.addAttribute("tasksTodo",      tasksTodo);
        model.addAttribute("tasksOverdue",   tasksOverdue);
        model.addAttribute("totalFiles",     totalFiles);
        model.addAttribute("unreadNotifications", unreadNotifications);
        model.addAttribute("recentTasks",
                recentTasks.size() > 5 ? recentTasks.subList(0, 5) : recentTasks);

        // Pass tenant so JSP can branch on workspace type
        tenantRepository.findById(tenantId)
                        .ifPresent(t -> model.addAttribute("tenant", t));

        return "dashboard";
    }
}