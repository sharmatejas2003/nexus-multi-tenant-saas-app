package com.app.controller;

import com.app.entity.Notification;
import com.app.entity.User;
import com.app.entity.WorkspaceMember;
import com.app.repository.TenantRepository;
import com.app.repository.UserRepository;
import com.app.repository.WorkspaceMemberRepository;
import com.app.service.NotificationService;
import com.app.tenant.TenantContext;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Map;

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

        String username = auth.getName();

        User currentUser = null;
        try { currentUser = userRepository.findByUsername(username); } catch (Exception ignored) {}
        model.addAttribute("currentUser", currentUser);
        model.addAttribute("currentRole", TenantContext.getRole() != null ? TenantContext.getRole() : "MEMBER");
        model.addAttribute("isAdminOrOwner", TenantContext.isAdminOrOwner());

        long unreadCount = 0;
        try { unreadCount = notificationService.countUnread(username); } catch (Exception ignored) {}
        model.addAttribute("unreadNotifications", unreadCount);
        model.addAttribute("unreadCount", unreadCount);

        try {
            tenantRepository.findById(tenantId).ifPresent(t -> model.addAttribute("tenant", t));
        } catch (Exception ignored) {}

        // Workspace switcher
        List<WorkspaceSwitcherController.WorkspaceInfo> allWorkspaces = new ArrayList<>();
        try {
            if (currentUser != null) {
                List<WorkspaceMember> memberships = workspaceMemberRepository.findByUserId(currentUser.getId());
                for (WorkspaceMember wm : memberships) {
                    try {
                        tenantRepository.findById(wm.getTenantId()).ifPresent(t ->
                            allWorkspaces.add(new WorkspaceSwitcherController.WorkspaceInfo(
                                t.getId(), t.getName(), wm.getRole(),
                                t.getId().equals(tenantId), t.getWorkspaceType()
                            ))
                        );
                    } catch (Exception ignored) {}
                }
            }
        } catch (Exception ignored) {}
        model.addAttribute("allWorkspaces", allWorkspaces);

        // *** FIX: use concrete type List<Notification> not List<?> ***
        // JSP EL cannot introspect wildcard types — it needs the concrete type
        List<Notification> notifications = Collections.emptyList();
        try {
            notifications = notificationService.getForUser(username);
        } catch (Exception e) {
            System.err.println("[NotificationController] Error loading notifications: " + e.getMessage());
        }
        model.addAttribute("notifications", notifications);

        return "notifications";
    }

    @PostMapping("/mark-read")
    public String markAllRead(Authentication auth) {
        try {
            notificationService.markAllRead(auth.getName());
        } catch (Exception e) {
            System.err.println("[NotificationController] markAllRead error: " + e.getMessage());
        }
        return "redirect:/notifications";
    }

    @GetMapping("/count")
    @ResponseBody
    public ResponseEntity<Map<String, Long>> getCount(Authentication auth) {
        long count = 0;
        try { count = notificationService.countUnread(auth.getName()); } catch (Exception ignored) {}
        return ResponseEntity.ok(Map.of("count", count));
    }
}