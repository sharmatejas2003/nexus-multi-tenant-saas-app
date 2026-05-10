package com.app.controller;

import com.app.service.NotificationService;
import com.app.tenant.TenantContext;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

@Controller
@RequestMapping("/notifications")
public class NotificationController {

    private final NotificationService notificationService;

    public NotificationController(NotificationService notificationService) {
        this.notificationService = notificationService;
    }

    @GetMapping
    public String list(Model model, Authentication auth) {
        if (TenantContext.getTenant() == null) return "redirect:/login";
        model.addAttribute("notifications", notificationService.getForUser(auth.getName()));
        model.addAttribute("unreadCount", notificationService.countUnread(auth.getName()));
        return "notifications";
    }

    @PostMapping("/mark-read")
    public String markAllRead(Authentication auth) {
        notificationService.markAllRead(auth.getName());
        return "redirect:/notifications";
    }
}