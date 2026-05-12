package com.app.controller;

import com.app.entity.TimeEntry;
import com.app.entity.User;
import com.app.repository.TenantRepository;
import com.app.repository.UserRepository;
import com.app.repository.WorkspaceMemberRepository;
import com.app.service.NotificationService;
import com.app.service.TimeTrackingService;
import com.app.tenant.TenantContext;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Controller
@RequestMapping("/time")
public class TimeTrackingController {

    private final TimeTrackingService timeService;
    private final UserRepository userRepository;
    private final TenantRepository tenantRepository;
    private final WorkspaceMemberRepository workspaceMemberRepository;
    private final NotificationService notificationService;

    public TimeTrackingController(TimeTrackingService timeService,
                                   UserRepository userRepository,
                                   TenantRepository tenantRepository,
                                   WorkspaceMemberRepository workspaceMemberRepository,
                                   NotificationService notificationService) {
        this.timeService = timeService;
        this.userRepository = userRepository;
        this.tenantRepository = tenantRepository;
        this.workspaceMemberRepository = workspaceMemberRepository;
        this.notificationService = notificationService;
    }

    @GetMapping
    public String timePage(Model model, Authentication auth) {
        Long tenantId = TenantContext.getTenant();
        if (tenantId == null) return "redirect:/login";

        User currentUser = userRepository.findByUsername(auth.getName());
        model.addAttribute("currentUser", currentUser);
        model.addAttribute("currentRole", TenantContext.getRole() != null ? TenantContext.getRole() : "MEMBER");
        model.addAttribute("isAdminOrOwner", TenantContext.isAdminOrOwner());

        long unread = 0;
        try { unread = notificationService.countUnread(auth.getName()); } catch (Exception ignored) {}
        model.addAttribute("unreadNotifications", unread);

        tenantRepository.findById(tenantId).ifPresent(t -> model.addAttribute("tenant", t));

        // Workspace switcher
        List<WorkspaceSwitcherController.WorkspaceInfo> allWorkspaces = new ArrayList<>();
        if (currentUser != null) {
            try {
                workspaceMemberRepository.findByUserId(currentUser.getId())
                    .forEach(wm -> tenantRepository.findById(wm.getTenantId()).ifPresent(t ->
                        allWorkspaces.add(new WorkspaceSwitcherController.WorkspaceInfo(
                            t.getId(), t.getName(), wm.getRole(),
                            t.getId().equals(tenantId), t.getWorkspaceType()
                        ))
                    ));
            } catch (Exception ignored) {}
        }
        model.addAttribute("allWorkspaces", allWorkspaces);

        // Running timer for current user
        TimeEntry running = null;
        try { running = timeService.getRunning(auth.getName()).orElse(null); } catch (Exception ignored) {}
        model.addAttribute("runningEntry", running);

        // User's own entries
        List<TimeEntry> entries = new ArrayList<>();
        try { entries = timeService.getForUser(auth.getName()); } catch (Exception ignored) {}
        model.addAttribute("entries", entries);

        // All tenant entries (admin/owner only)
        List<TimeEntry> allEntries = new ArrayList<>();
        if (TenantContext.isAdminOrOwner()) {
            try { allEntries = timeService.getForTenant(); } catch (Exception ignored) {}
        }
        model.addAttribute("allEntries", allEntries);

        long totalMinutes = 0;
        try { totalMinutes = timeService.getTotalMinutes(); } catch (Exception ignored) {}
        model.addAttribute("totalMinutes", totalMinutes);

        return "time-tracking";
    }

    @PostMapping("/start")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> start(
            @RequestParam(required = false) String description,
            @RequestParam(required = false) String projectId,
            @RequestParam(required = false) Long taskId,
            Authentication auth) {

        Map<String, Object> result = new HashMap<>();
        try {
            User user = userRepository.findByUsername(auth.getName());
            Long userId = user != null ? user.getId() : null;
            TimeEntry entry = timeService.start(auth.getName(), userId, description, projectId, taskId);
            result.put("success", true);
            result.put("id", entry.getId());
        } catch (Exception e) {
            result.put("success", false);
            result.put("error", e.getMessage());
        }
        return ResponseEntity.ok(result);
    }

    @PostMapping("/stop")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> stop(Authentication auth) {
        Map<String, Object> result = new HashMap<>();
        try {
            TimeEntry entry = timeService.stopCurrent(auth.getName());
            if (entry != null) {
                result.put("success", true);
                result.put("duration", entry.getFormattedDuration());
                result.put("id", entry.getId());
            } else {
                result.put("success", false);
                result.put("error", "No running timer found");
            }
        } catch (Exception e) {
            result.put("success", false);
            result.put("error", e.getMessage());
        }
        return ResponseEntity.ok(result);
    }
}