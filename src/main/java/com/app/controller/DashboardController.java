package com.app.controller;

import com.app.entity.Tenant;
import com.app.entity.User;
import com.app.entity.WorkspaceMember;
import com.app.repository.*;
import com.app.service.*;
import com.app.tenant.TenantContext;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;

import java.util.ArrayList;
import java.util.List;

@Controller
public class DashboardController {

    private final ProjectService projectService;
    private final UserRepository userRepository;
    private final TaskRepository taskRepository;
    private final ActivityService activityService;
    private final FileAttachmentRepository fileRepo;
    private final NotificationService notificationService;
    private final TenantRepository tenantRepository;
    private final NoteRepository noteRepository;
    private final WorkspaceMemberRepository workspaceMemberRepository;

    public DashboardController(ProjectService projectService,
                                UserRepository userRepository,
                                TaskRepository taskRepository,
                                ActivityService activityService,
                                FileAttachmentRepository fileRepo,
                                NotificationService notificationService,
                                TenantRepository tenantRepository,
                                NoteRepository noteRepository,
                                WorkspaceMemberRepository workspaceMemberRepository) {
        this.projectService = projectService;
        this.userRepository = userRepository;
        this.taskRepository = taskRepository;
        this.activityService = activityService;
        this.fileRepo = fileRepo;
        this.notificationService = notificationService;
        this.tenantRepository = tenantRepository;
        this.noteRepository = noteRepository;
        this.workspaceMemberRepository = workspaceMemberRepository;
    }

    @GetMapping("/dashboard")
    public String dashboard(Model model, Authentication auth) {
        Long tenantId = TenantContext.getTenant();
        if (tenantId == null) return "redirect:/login";

        User currentUser = userRepository.findByUsername(auth.getName());
        model.addAttribute("currentUser", currentUser);

        var projects       = projectService.getAll();
        var members        = userRepository.findByTenantId(tenantId);
        var recentActivity = activityService.getRecentActivity();

        long tasksDone       = taskRepository.countByTenantIdAndStatus(tenantId, "DONE");
        long tasksInProgress = taskRepository.countByTenantIdAndStatus(tenantId, "IN_PROGRESS");
        long tasksTodo       = taskRepository.countByTenantIdAndStatus(tenantId, "TODO");
        long tasksOverdue    = taskRepository.countByTenantIdAndStatus(tenantId, "OVERDUE");
        long totalFiles      = fileRepo.countByTenantId(tenantId);

        var recentTasks = taskRepository.findRecentByTenantId(tenantId);
        var recentNotes = noteRepository.findByTenantIdOrderByCreatedAtDesc(tenantId);

        long unreadNotifications = 0;
        if (auth != null) unreadNotifications = notificationService.countUnread(auth.getName());

        // Role
        String currentRole = TenantContext.getRole();
        boolean isAdminOrOwner = TenantContext.isAdminOrOwner();

        // ── All workspaces this user belongs to (for switcher) ──
        List<WorkspaceSwitcherController.WorkspaceInfo> allWorkspaces = buildWorkspaceList(currentUser, tenantId);

        model.addAttribute("projects",            projects);
        model.addAttribute("members",             members);
        model.addAttribute("recentActivity",      recentActivity);
        model.addAttribute("tasksDone",           tasksDone);
        model.addAttribute("tasksInProgress",     tasksInProgress);
        model.addAttribute("tasksTodo",           tasksTodo);
        model.addAttribute("tasksOverdue",        tasksOverdue);
        model.addAttribute("totalFiles",          totalFiles);
        model.addAttribute("unreadNotifications", unreadNotifications);
        model.addAttribute("recentNotes",         recentNotes);
        model.addAttribute("currentRole",         currentRole);
        model.addAttribute("isAdminOrOwner",      isAdminOrOwner);
        model.addAttribute("allWorkspaces",       allWorkspaces);
        model.addAttribute("recentTasks",
                recentTasks.size() > 5 ? recentTasks.subList(0, 5) : recentTasks);

        tenantRepository.findById(tenantId)
                        .ifPresent(t -> model.addAttribute("tenant", t));

        return "dashboard";
    }

    private List<WorkspaceSwitcherController.WorkspaceInfo> buildWorkspaceList(User user, Long activeId) {
        List<WorkspaceSwitcherController.WorkspaceInfo> list = new ArrayList<>();
        if (user == null) return list;
        List<WorkspaceMember> memberships = workspaceMemberRepository.findByUserId(user.getId());
        for (WorkspaceMember wm : memberships) {
            tenantRepository.findById(wm.getTenantId()).ifPresent(t -> {
                list.add(new WorkspaceSwitcherController.WorkspaceInfo(
                        t.getId(), t.getName(), wm.getRole(),
                        t.getId().equals(activeId), t.getWorkspaceType()
                ));
            });
        }
        return list;
    }
}