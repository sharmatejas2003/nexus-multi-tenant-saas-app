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
@RequestMapping("/chat")
public class ChatController {
 
    private final ChatService chatService;
    private final UserRepository userRepository;
    private final TenantRepository tenantRepository;
    private final WorkspaceMemberRepository workspaceMemberRepository;
    private final NotificationService notificationService;
    private final AnnouncementService announcementService;
 
    public ChatController(ChatService chatService,
                          UserRepository userRepository,
                          TenantRepository tenantRepository,
                          WorkspaceMemberRepository workspaceMemberRepository,
                          NotificationService notificationService,
                          AnnouncementService announcementService) {
        this.chatService = chatService;
        this.userRepository = userRepository;
        this.tenantRepository = tenantRepository;
        this.workspaceMemberRepository = workspaceMemberRepository;
        this.notificationService = notificationService;
        this.announcementService = announcementService;
    }
 
    @GetMapping
    public String chat(Model model, Authentication auth) {
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
 
        model.addAttribute("messages", chatService.getMessages());
        model.addAttribute("announcements", announcementService.getAll());
        model.addAttribute("pinnedAnnouncements", announcementService.getPinned());
        return "chat";
    }
 
    @PostMapping("/send")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> send(@RequestParam String message,
                                                     Authentication auth) {
        Map<String, Object> result = new HashMap<>();
        try {
            if (message == null || message.trim().isEmpty()) {
                result.put("success", false);
                result.put("error", "Message cannot be empty");
                return ResponseEntity.badRequest().body(result);
            }
            var chat = chatService.send(message, auth.getName());
            result.put("success", true);
            result.put("id", chat.getId());
            result.put("message", chat.getMessage());
            result.put("sender", chat.getSenderUsername());
            result.put("timeAgo", chat.getTimeAgo());
            result.put("initial", chat.getInitial());
        } catch (Exception e) {
            result.put("success", false);
            result.put("error", e.getMessage());
        }
        return ResponseEntity.ok(result);
    }
 
    @GetMapping("/messages")
    @ResponseBody
    public ResponseEntity<List<Map<String, Object>>> getMessages() {
        List<Map<String, Object>> msgs = new ArrayList<>();
        try {
            chatService.getMessages().forEach(m -> {
                Map<String, Object> msg = new HashMap<>();
                msg.put("id", m.getId());
                msg.put("message", m.getMessage());
                msg.put("sender", m.getSenderUsername());
                msg.put("timeAgo", m.getTimeAgo());
                msg.put("initial", m.getInitial());
                msgs.add(msg);
            });
        } catch (Exception ignored) {}
        return ResponseEntity.ok(msgs);
    }
 
    @PostMapping("/delete/{id}")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> deleteMessage(@PathVariable Long id, Authentication auth) {
        Map<String, Object> result = new HashMap<>();
        try {
            if (TenantContext.isAdminOrOwner()) {
                chatService.deleteMessage(id);
                result.put("success", true);
            } else {
                result.put("success", false);
                result.put("error", "Permission denied");
            }
        } catch (Exception e) {
            result.put("success", false);
        }
        return ResponseEntity.ok(result);
    }
}