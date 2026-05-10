package com.app.controller;


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
import java.util.Collections;
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

        // Safe defaults for all model attributes
        List<com.app.entity.Project> projects = Collections.emptyList();
        List<User> members = Collections.emptyList();
        List<com.app.entity.ActivityLog> recentActivity = Collections.emptyList();
        List<com.app.entity.Task> recentTasks = Collections.emptyList();
        List<com.app.entity.Note> recentNotes = Collections.emptyList();

        try { projects       = projectService.getAll(); }        catch (Exception e) { logError("projects", e); }
        try { members        = userRepository.findByTenantId(tenantId); } catch (Exception e) { logError("members", e); }
        try { recentActivity = activityService.getRecentActivity(); }    catch (Exception e) { logError("activity", e); }
        try { recentTasks    = taskRepository.findRecentByTenantId(tenantId); } catch (Exception e) { logError("tasks", e); }
        try { recentNotes    = noteRepository.findByTenantIdOrderByCreatedAtDesc(tenantId); } catch (Exception e) { logError("notes", e); }

        long tasksDone = 0, tasksInProgress = 0, tasksTodo = 0, tasksOverdue = 0, totalFiles = 0;
        try { tasksDone       = taskRepository.countByTenantIdAndStatus(tenantId, "DONE"); }        catch (Exception ignored) {}
        try { tasksInProgress = taskRepository.countByTenantIdAndStatus(tenantId, "IN_PROGRESS"); } catch (Exception ignored) {}
        try { tasksTodo       = taskRepository.countByTenantIdAndStatus(tenantId, "TODO"); }        catch (Exception ignored) {}
        try { tasksOverdue    = taskRepository.countByTenantIdAndStatus(tenantId, "OVERDUE"); }     catch (Exception ignored) {}
        try { totalFiles      = fileRepo.countByTenantId(tenantId); }                              catch (Exception ignored) {}

        long unreadNotifications = 0;
        try { unreadNotifications = notificationService.countUnread(auth.getName()); } catch (Exception ignored) {}

        // Role
        String currentRole   = TenantContext.getRole() != null ? TenantContext.getRole() : "MEMBER";
        boolean isAdminOrOwner = TenantContext.isAdminOrOwner();

        // All workspaces for switcher
        List<WorkspaceSwitcherController.WorkspaceInfo> allWorkspaces = buildWorkspaceList(currentUser, tenantId);

        // Trim recent tasks to max 5
        if (recentTasks.size() > 5) recentTasks = recentTasks.subList(0, 5);

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
        model.addAttribute("recentTasks",         recentTasks);

        tenantRepository.findById(tenantId)
                .ifPresent(t -> model.addAttribute("tenant", t));

        return "dashboard";
    }

    private List<WorkspaceSwitcherController.WorkspaceInfo> buildWorkspaceList(User user, Long activeId) {
        List<WorkspaceSwitcherController.WorkspaceInfo> list = new ArrayList<>();
        if (user == null) return list;
        try {
            List<WorkspaceMember> memberships = workspaceMemberRepository.findByUserId(user.getId());
            for (WorkspaceMember wm : memberships) {
                tenantRepository.findById(wm.getTenantId()).ifPresent(t -> {
                    list.add(new WorkspaceSwitcherController.WorkspaceInfo(
                            t.getId(), t.getName(), wm.getRole(),
                            t.getId().equals(activeId), t.getWorkspaceType()
                    ));
                });
            }
        } catch (Exception e) {
            System.err.println("[DashboardController] Error building workspace list: " + e.getMessage());
        }
        return list;
    }

    private void logError(String section, Exception e) {
        System.err.println("[DashboardController] Error loading " + section + ": " + e.getMessage());
    }
}