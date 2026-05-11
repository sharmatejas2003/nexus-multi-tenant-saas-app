package com.app.controller;
 
import com.app.entity.*;
import com.app.repository.*;
import com.app.service.*;
import com.app.tenant.TenantContext;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import java.util.*;
 
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
        tenantRepository.findById(tenantId).ifPresent(t -> model.addAttribute("tenant", t));

        // Get your entries
        List<TimeEntry> entries = timeService.getForUser(auth.getName());
        model.addAttribute("entries", entries);

        // FIX: Calculate "Today's" minutes for the red card in time-tracking.jsp
        long todayMins = entries.stream()
                .filter(e -> e.getStartTime() != null && 
                        e.getStartTime().toLocalDate().equals(java.time.LocalDate.now()))
                .mapToLong(e -> e.getDurationMinutes() != null ? e.getDurationMinutes() : 0)
                .sum();
        
        // This matches the ${todayMinutes} or ID logic in your JSP
        model.addAttribute("todayMinutes", todayMins + "m"); 

        model.addAttribute("runningEntry", timeService.getRunning(auth.getName()).orElse(null));
        model.addAttribute("totalMinutes", timeService.getTotalMinutes());

        if (TenantContext.isAdminOrOwner()) {
            model.addAttribute("allEntries", timeService.getForTenant());
        }

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
            Long tenantId = TenantContext.getTenant();
            User user = userRepository.findByUsername(auth.getName());
            var entry = timeService.start(auth.getName(), user != null ? user.getId() : null,
                    description, projectId, taskId);
            result.put("success", true);
            result.put("id", entry.getId());
            result.put("startTime", entry.getStartTime().toString());
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
            var entry = timeService.stopCurrent(auth.getName());
            if (entry != null) {
                result.put("success", true);
                result.put("duration", entry.getFormattedDuration());
                result.put("minutes", entry.getDurationMinutes());
            } else {
                result.put("success", false);
                result.put("error", "No running timer");
            }
        } catch (Exception e) {
            result.put("success", false);
        }
        return ResponseEntity.ok(result);
    }
}