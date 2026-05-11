package com.app.controller;
 
import com.app.entity.*;
import com.app.repository.*;
import com.app.service.*;
import com.app.tenant.TenantContext;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import java.time.LocalDateTime;
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
 
        model.addAttribute("events", calendarService.getAll());
        model.addAttribute("upcomingEvents", calendarService.getUpcoming());
        try { model.addAttribute("projects", projectService.getAll()); }
        catch (Exception e) { model.addAttribute("projects", List.of()); }
 
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
            event.setStartDatetime(LocalDateTime.parse(startDatetime.replace("T", " ").length() == 16
                    ? startDatetime + ":00" : startDatetime,
                    java.time.format.DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm")));
            if (endDatetime != null && !endDatetime.isEmpty()) {
                event.setEndDatetime(LocalDateTime.parse(endDatetime,
                        java.time.format.DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm")));
            }
            event.setEventType(eventType);
            event.setColor(color);
            event.setLinkedProjectId(linkedProjectId);
            calendarService.save(event, auth.getName());
 
            // Notify team members
            Long tenantId = TenantContext.getTenant();
            notificationService.notify(auth.getName() + " members",
                "📅 New event added: " + title, "/calendar", "CALENDAR_EVENT");
        } catch (Exception e) {
            e.printStackTrace();
        }
        return "redirect:/calendar?created=true";
    }
 
    @PostMapping("/delete/{id}")
    public String deleteEvent(@PathVariable Long id) {
        calendarService.delete(id);
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
                ev.put("start", e.getStartDatetime().toString());
                // FIX: If end is null, don't put it in the map or set it to start
                if (e.getEndDatetime() != null) {
                    ev.put("end", e.getEndDatetime().toString());
                }
                ev.put("color", e.getColor());
                ev.put("extendedProps", Map.of("type", e.getEventType(), "icon", e.getTypeIcon()));
                result.add(ev);
            });
        } catch (Exception ignored) {}
        return result;
    }
}