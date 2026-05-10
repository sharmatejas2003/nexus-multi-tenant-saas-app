package com.app.controller;

import com.app.entity.User;
import com.app.entity.WorkspaceMember;
import com.app.repository.TenantRepository;
import com.app.repository.UserRepository;
import com.app.repository.WorkspaceMemberRepository;
import com.app.service.NotificationService;
import com.app.tenant.TenantContext;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import java.util.ArrayList;
import java.util.List;

@Controller
@RequestMapping("/notifications")
public class NotificationController {

    private final NotificationService notificationService;
    private final UserRepository userRepository;
    private final TenantRepository tenantRepository;
    private final WorkspaceMemberRepository workspaceMemberRepository;

    public NotificationController(NotificationService notificationService,
                                   UserRepository userRepository,
                                   TenantRepository tenantRepository,
                                   WorkspaceMemberRepository workspaceMemberRepository) {
        this.notificationService = notificationService;
        this.userRepository = userRepository;
        this.tenantRepository = tenantRepository;
        this.workspaceMemberRepository = workspaceMemberRepository;
    }

    @GetMapping
    public String list(Model model, Authentication auth) {
        Long tenantId = TenantContext.getTenant();
        if (tenantId == null) return "redirect:/login";

        User currentUser = userRepository.findByUsername(auth.getName());
        model.addAttribute("currentUser", currentUser);
        model.addAttribute("currentRole", TenantContext.getRole() != null ? TenantContext.getRole() : "MEMBER");
        model.addAttribute("isAdminOrOwner", TenantContext.isAdminOrOwner());

        long unreadCount = 0;
        try { unreadCount = notificationService.countUnread(auth.getName()); } catch (Exception ignored) {}
        model.addAttribute("unreadNotifications", unreadCount);
        model.addAttribute("unreadCount", unreadCount);

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

        model.addAttribute("notifications", notificationService.getForUser(auth.getName()));
        return "notifications";
    }

    @PostMapping("/mark-read")
    public String markAllRead(Authentication auth) {
        notificationService.markAllRead(auth.getName());
        return "redirect:/notifications";
    }
}