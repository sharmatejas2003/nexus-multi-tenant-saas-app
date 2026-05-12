package com.app.controller;

import com.app.entity.CalendarEvent;
import com.app.entity.User;
import com.app.repository.TenantRepository;
import com.app.repository.UserRepository;
import com.app.repository.WorkspaceMemberRepository;
import com.app.service.CalendarService;
import com.app.service.NotificationService;
import com.app.service.ProjectService;
import com.app.tenant.TenantContext;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.*;

@Controller
@RequestMapping("/calendar")
public class CalendarController {

    private final CalendarService calendarService;
    private final UserRepository userRepository;
    private final TenantRepository tenantRepository;
    private final WorkspaceMemberRepository workspaceMemberRepository;
    private final NotificationService notificationService;
    private final ProjectService projectService;

    private static final DateTimeFormatter FORMATTER = DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm");

    public CalendarController(CalendarService calendarService,
                              UserRepository userRepository,
                              TenantRepository tenantRepository,
                              WorkspaceMemberRepository workspaceMemberRepository,
                              NotificationService notificationService,
                              ProjectService projectService) {
        this.calendarService = calendarService;
        this.userRepository = userRepository;
        this.tenantRepository = tenantRepository;
        this.workspaceMemberRepository = workspaceMemberRepository;
        this.notificationService = notificationService;
        this.projectService = projectService;
    }

    @GetMapping
    public String calendar(Model model, Authentication auth) {
        Long tenantId = TenantContext.getTenant();
        if (tenantId == null) return "redirect:/login";

        User currentUser = userRepository.findByUsername(auth.getName());
        model.addAttribute("currentUser", currentUser);
        model.addAttribute("currentRole", TenantContext.getRole() != null ? TenantContext.getRole() : "MEMBER");
        model.addAttribute("isAdminOrOwner", TenantContext.isAdminOrOwner());
        tenantRepository.findById(tenantId).ifPresent(t -> model.addAttribute("tenant", t));

        long unread = 0;
        try { unread = notificationService.countUnread(auth.getName()); } catch (Exception ignored) {}
        model.addAttribute("unreadNotifications", unread);

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

        List<CalendarEvent> events = new ArrayList<>();
        List<CalendarEvent> upcomingEvents = new ArrayList<>();

        try { events = calendarService.getAll(); } catch (Exception ignored) {}
        try { upcomingEvents = calendarService.getUpcoming(); } catch (Exception ignored) {}

        model.addAttribute("events", events);
        model.addAttribute("upcomingEvents", upcomingEvents);
        model.addAttribute("projects", projectService.getAll());

        return "calendar";
    }

    @PostMapping("/add")
    public String addEvent(@RequestParam String title,
                           @RequestParam(required = false) String description,
                           @RequestParam String startDatetime,
                           @RequestParam(required = false) String endDatetime,
                           @RequestParam(defaultValue = "EVENT") String eventType,
                           @RequestParam(defaultValue = "#6c63ff") String color,
                           @RequestParam(required = false) String linkedProjectId,
                           Authentication auth) {

        if (TenantContext.getTenant() == null) return "redirect:/login";

        try {
            CalendarEvent event = new CalendarEvent();
            event.setTitle(title);
            event.setDescription(description);
            event.setStartDatetime(LocalDateTime.parse(startDatetime, FORMATTER));
            if (endDatetime != null && !endDatetime.isEmpty()) {
                event.setEndDatetime(LocalDateTime.parse(endDatetime, FORMATTER));
            }
            event.setEventType(eventType);
            event.setColor(color);
            event.setLinkedProjectId(linkedProjectId);
            calendarService.save(event, auth.getName());
        } catch (Exception e) {
            e.printStackTrace();
            return "redirect:/calendar?error=true";
        }
        return "redirect:/calendar?created=true";
    }

    @PostMapping("/delete/{id}")
    public String deleteEvent(@PathVariable Long id) {
        try { calendarService.delete(id); } catch (Exception ignored) {}
        return "redirect:/calendar?deleted=true";
    }

    @GetMapping("/events.json")
    @ResponseBody
    public List<Map<String, Object>> eventsJson() {
        List<Map<String, Object>> result = new ArrayList<>();
        try {
            calendarService.getAll().forEach(e -> {
                Map<String, Object> ev = new HashMap<>();
                ev.put("id", e.getId());
                ev.put("title", e.getTitle());
                ev.put("start", e.getStartDatetime() != null ? e.getStartDatetime().toString() : "");
                if (e.getEndDatetime() != null) ev.put("end", e.getEndDatetime().toString());
                ev.put("color", e.getColor() != null ? e.getColor() : "#6c63ff");
                ev.put("extendedProps", Map.of("type", e.getEventType() != null ? e.getEventType() : "EVENT"));
                result.add(ev);
            });
        } catch (Exception ignored) {}
        return result;
    }
}