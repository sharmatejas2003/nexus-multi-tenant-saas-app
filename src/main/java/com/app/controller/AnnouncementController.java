package com.app.controller;
 
import com.app.entity.*;
import com.app.repository.*;
import com.app.service.*;
import com.app.tenant.TenantContext;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;
 
@Controller
@RequestMapping("/announcements")
public class AnnouncementController {
 
    private final AnnouncementService announcementService;
    private final UserRepository userRepository;
    private final NotificationService notificationService;
 
    public AnnouncementController(AnnouncementService announcementService,
                                   UserRepository userRepository,
                                   NotificationService notificationService) {
        this.announcementService = announcementService;
        this.userRepository = userRepository;
        this.notificationService = notificationService;
    }
 
    @PostMapping("/add")
    public String add(@RequestParam String title,
                      @RequestParam(required = false) String content,
                      @RequestParam(defaultValue = "NORMAL") String priority,
                      @RequestParam(defaultValue = "false") boolean pinned,
                      Authentication auth) {
        if (!TenantContext.isAdminOrOwner()) return "redirect:/chat?error=permission_denied";
        try {
            Announcement a = new Announcement();
            a.setTitle(title);
            a.setContent(content);
            a.setPriority(priority);
            a.setPinned(pinned);
            announcementService.save(a, auth.getName());
 
            // Notify all members
            Long tenantId = TenantContext.getTenant();
            userRepository.findByTenantId(tenantId).forEach(u -> {
                if (!u.getUsername().equals(auth.getName())) {
                    notificationService.notifyWithTenant(
                        u.getUsername(),
                        "📢 New announcement: " + title,
                        "/chat",
                        "ANNOUNCEMENT",
                        tenantId
                    );
                }
            });
        } catch (Exception e) {
            e.printStackTrace();
        }
        return "redirect:/chat?announced=true";
    }
 
    @PostMapping("/delete/{id}")
    public String delete(@PathVariable Long id) {
        if (!TenantContext.isAdminOrOwner()) return "redirect:/chat?error=permission_denied";
        announcementService.delete(id);
        return "redirect:/chat?deleted=true";
    }
}
 