package com.app.controller;

import com.app.entity.User;
import com.app.entity.WorkspaceMember;
import com.app.repository.*;
import com.app.service.ActivityService;
import com.app.service.NotificationService;
import com.app.tenant.TenantContext;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

import java.util.ArrayList;
import java.util.List;

@Controller
@RequestMapping("/analytics")
public class AnalyticsController {

    private final TaskRepository taskRepo;
    private final ProjectRepository projectRepo;
    private final UserRepository userRepo;
    private final ActivityService activityService;
    private final FileAttachmentRepository fileRepo;
    private final NotificationService notificationService;
    private final TenantRepository tenantRepository;
    private final WorkspaceMemberRepository workspaceMemberRepository;

    public AnalyticsController(TaskRepository taskRepo, ProjectRepository projectRepo,
                                UserRepository userRepo, ActivityService activityService,
                                FileAttachmentRepository fileRepo,
                                NotificationService notificationService,
                                TenantRepository tenantRepository,
                                WorkspaceMemberRepository workspaceMemberRepository) {
        this.taskRepo = taskRepo;
        this.projectRepo = projectRepo;
        this.userRepo = userRepo;
        this.activityService = activityService;
        this.fileRepo = fileRepo;
        this.notificationService = notificationService;
        this.tenantRepository = tenantRepository;
        this.workspaceMemberRepository = workspaceMemberRepository;
    }

    @GetMapping
    public String analytics(Model model, Authentication auth) {
        Long tenantId = TenantContext.getTenant();
        if (tenantId == null) return "redirect:/login";

        // Only ADMIN/OWNER can view analytics
        if (!TenantContext.isAdminOrOwner()) {
            return "redirect:/dashboard?error=access_denied";
        }

        // ── Sidebar required attributes ──
        User currentUser = userRepo.findByUsername(auth.getName());
        model.addAttribute("currentUser", currentUser);
        model.addAttribute("currentRole", TenantContext.getRole() != null ? TenantContext.getRole() : "MEMBER");
        model.addAttribute("isAdminOrOwner", TenantContext.isAdminOrOwner());

        long unreadNotifications = 0;
        try { unreadNotifications = notificationService.countUnread(auth.getName()); } catch (Exception ignored) {}
        model.addAttribute("unreadNotifications", unreadNotifications);

        tenantRepository.findById(tenantId).ifPresent(t -> model.addAttribute("tenant", t));

        // Workspace switcher
        List<com.app.controller.WorkspaceSwitcherController.WorkspaceInfo> allWorkspaces = new ArrayList<>();
        try {
            List<WorkspaceMember> memberships = workspaceMemberRepository.findByUserId(currentUser.getId());
            for (WorkspaceMember wm : memberships) {
                tenantRepository.findById(wm.getTenantId()).ifPresent(t ->
                    allWorkspaces.add(new com.app.controller.WorkspaceSwitcherController.WorkspaceInfo(
                        t.getId(), t.getName(), wm.getRole(), t.getId().equals(tenantId), t.getWorkspaceType()
                    ))
                );
            }
        } catch (Exception ignored) {}
        model.addAttribute("allWorkspaces", allWorkspaces);

        // ── Task stats ──
        long totalTasks = 0;
        try { totalTasks = taskRepo.findByTenantId(tenantId).size(); } catch (Exception ignored) {}
        long tasksDone = 0;
        try { tasksDone = taskRepo.countByTenantIdAndStatus(tenantId, "DONE"); } catch (Exception ignored) {}
        long tasksInProgress = 0;
        try { tasksInProgress = taskRepo.countByTenantIdAndStatus(tenantId, "IN_PROGRESS"); } catch (Exception ignored) {}
        long tasksTodo = 0;
        try { tasksTodo = taskRepo.countByTenantIdAndStatus(tenantId, "TODO"); } catch (Exception ignored) {}
        long tasksOverdue = 0;
        try { tasksOverdue = taskRepo.countByTenantIdAndStatus(tenantId, "OVERDUE"); } catch (Exception ignored) {}

        // ── Project stats ──
        long totalProjects = 0;
        try { totalProjects = projectRepo.countByTenantId(tenantId); } catch (Exception ignored) {}
        long activeProjects = 0;
        try { activeProjects = projectRepo.findByTenantIdAndStatus(tenantId, "ACTIVE").size(); } catch (Exception ignored) {}
        long completedProjects = 0;
        try { completedProjects = projectRepo.findByTenantIdAndStatus(tenantId, "COMPLETED").size(); } catch (Exception ignored) {}

        // ── Members & files ──
        long totalMembers = 0;
        try { totalMembers = userRepo.findByTenantId(tenantId).size(); } catch (Exception ignored) {}
        long totalFiles = 0;
        try { totalFiles = fileRepo.countByTenantId(tenantId); } catch (Exception ignored) {}

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

        try { model.addAttribute("recentActivity", activityService.getAllActivity()); }
        catch (Exception ignored) { model.addAttribute("recentActivity", List.of()); }

        try { model.addAttribute("members", userRepo.findByTenantId(tenantId)); }
        catch (Exception ignored) { model.addAttribute("members", List.of()); }

        try { model.addAttribute("upcomingTasks", taskRepo.findUpcomingByTenantId(tenantId)); }
        catch (Exception ignored) { model.addAttribute("upcomingTasks", List.of()); }

        return "analytics";
    }
}