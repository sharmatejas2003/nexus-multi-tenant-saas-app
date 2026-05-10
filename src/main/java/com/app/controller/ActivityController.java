package com.app.controller;

import com.app.entity.User;
import com.app.entity.WorkspaceMember;
import com.app.repository.TenantRepository;
import com.app.repository.UserRepository;
import com.app.repository.WorkspaceMemberRepository;
import com.app.service.ActivityService;
import com.app.service.NotificationService;
import com.app.tenant.TenantContext;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

import java.util.ArrayList;
import java.util.List;

@Controller
@RequestMapping("/activity")
public class ActivityController {

    private final ActivityService activityService;
    private final UserRepository userRepository;
    private final NotificationService notificationService;
    private final TenantRepository tenantRepository;
    private final WorkspaceMemberRepository workspaceMemberRepository;

    public ActivityController(ActivityService activityService,
                               UserRepository userRepository,
                               NotificationService notificationService,
                               TenantRepository tenantRepository,
                               WorkspaceMemberRepository workspaceMemberRepository) {
        this.activityService = activityService;
        this.userRepository = userRepository;
        this.notificationService = notificationService;
        this.tenantRepository = tenantRepository;
        this.workspaceMemberRepository = workspaceMemberRepository;
    }

    @GetMapping
    public String activityLog(Model model, Authentication auth,
                               @RequestParam(required = false) String filter) {
        Long tenantId = TenantContext.getTenant();
        if (tenantId == null) return "redirect:/login";

        if (!TenantContext.isAdminOrOwner()) {
            return "redirect:/dashboard?error=access_denied";
        }

        User currentUser = userRepository.findByUsername(auth.getName());
        model.addAttribute("currentUser", currentUser);
        model.addAttribute("currentRole", TenantContext.getRole() != null ? TenantContext.getRole() : "MEMBER");
        model.addAttribute("isAdminOrOwner", TenantContext.isAdminOrOwner());

        long unreadNotifications = 0;
        try { unreadNotifications = notificationService.countUnread(auth.getName()); } catch (Exception ignored) {}
        model.addAttribute("unreadNotifications", unreadNotifications);

        tenantRepository.findById(tenantId).ifPresent(t -> model.addAttribute("tenant", t));

        // Workspace switcher
        List<WorkspaceSwitcherController.WorkspaceInfo> allWorkspaces = new ArrayList<>();
        try {
            if (currentUser != null) {
                List<WorkspaceMember> memberships = workspaceMemberRepository.findByUserId(currentUser.getId());
                for (WorkspaceMember wm : memberships) {
                    tenantRepository.findById(wm.getTenantId()).ifPresent(t ->
                        allWorkspaces.add(new WorkspaceSwitcherController.WorkspaceInfo(
                            t.getId(), t.getName(), wm.getRole(), t.getId().equals(tenantId), t.getWorkspaceType()
                        ))
                    );
                }
            }
        } catch (Exception ignored) {}
        model.addAttribute("allWorkspaces", allWorkspaces);

        model.addAttribute("activityLogs", activityService.getAllActivity());
        model.addAttribute("filter", filter);
        return "activity-log";
    }
}