package com.app.controller;

import com.app.repository.*;
import com.app.service.ActivityService;
import com.app.tenant.TenantContext;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
@RequestMapping("/analytics")
public class AnalyticsController {

    private final TaskRepository taskRepo;
    private final ProjectRepository projectRepo;
    private final UserRepository userRepo;
    private final ActivityService activityService;
    private final FileAttachmentRepository fileRepo;

    public AnalyticsController(TaskRepository taskRepo, ProjectRepository projectRepo,
                                UserRepository userRepo, ActivityService activityService,
                                FileAttachmentRepository fileRepo) {
        this.taskRepo = taskRepo;
        this.projectRepo = projectRepo;
        this.userRepo = userRepo;
        this.activityService = activityService;
        this.fileRepo = fileRepo;
    }

    @GetMapping
    public String analytics(Model model) {
        Long tenantId = TenantContext.getTenant();
        if (tenantId == null) return "redirect:/login";

        // Task stats
        long totalTasks = taskRepo.findByTenantId(tenantId).size();
        long tasksDone = taskRepo.countByTenantIdAndStatus(tenantId, "DONE");
        long tasksInProgress = taskRepo.countByTenantIdAndStatus(tenantId, "IN_PROGRESS");
        long tasksTodo = taskRepo.countByTenantIdAndStatus(tenantId, "TODO");
        long tasksOverdue = taskRepo.countByTenantIdAndStatus(tenantId, "OVERDUE");

        // Project stats
        long totalProjects = projectRepo.countByTenantId(tenantId);
        long activeProjects = projectRepo.findByTenantIdAndStatus(tenantId, "ACTIVE").size();
        long completedProjects = projectRepo.findByTenantIdAndStatus(tenantId, "COMPLETED").size();

        // Members & files
        long totalMembers = userRepo.findByTenantId(tenantId).size();
        long totalFiles = fileRepo.countByTenantId(tenantId);

        // Completion rate
        int completionRate = totalTasks > 0 ? (int) (tasksDone * 100 / totalTasks) : 0;

        model.addAttribute("totalTasks", totalTasks);
        model.addAttribute("tasksDone", tasksDone);
        model.addAttribute("tasksInProgress", tasksInProgress);
        model.addAttribute("tasksTodo", tasksTodo);
        model.addAttribute("tasksOverdue", tasksOverdue);
        model.addAttribute("totalProjects", totalProjects);
        model.addAttribute("activeProjects", activeProjects);
        model.addAttribute("completedProjects", completedProjects);
        model.addAttribute("totalMembers", totalMembers);
        model.addAttribute("totalFiles", totalFiles);
        model.addAttribute("completionRate", completionRate);
        model.addAttribute("recentActivity", activityService.getAllActivity());
        model.addAttribute("members", userRepo.findByTenantId(tenantId));
        model.addAttribute("upcomingTasks", taskRepo.findUpcomingByTenantId(tenantId));

        return "analytics";
    }
}