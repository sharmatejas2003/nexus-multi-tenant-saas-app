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
        if (tenantId == null) {
            return "redirect:/login";
        }

        try {
            User currentUser = userRepository.findByUsername(auth.getName());

            model.addAttribute("currentUser", currentUser);
            model.addAttribute("currentRole",
                    TenantContext.getRole() != null
                            ? TenantContext.getRole()
                            : "MEMBER");

            model.addAttribute("isAdminOrOwner",
                    TenantContext.isAdminOrOwner());

            tenantRepository.findById(tenantId)
                    .ifPresent(t -> model.addAttribute("tenant", t));

            // SAFE DEFAULTS
            model.addAttribute("unreadNotifications", 0L);
            model.addAttribute("allWorkspaces", new ArrayList<>());
            model.addAttribute("messages", new ArrayList<>());
            model.addAttribute("announcements", new ArrayList<>());
            model.addAttribute("pinnedAnnouncements", new ArrayList<>());
            model.addAttribute("lastMessageId", 0L);

            // notifications
            try {
                long unread = notificationService.countUnread(auth.getName());
                model.addAttribute("unreadNotifications", unread);
            } catch (Exception ignored) {}

            // workspace switcher
            try {
                List<WorkspaceSwitcherController.WorkspaceInfo> allWorkspaces =
                        new ArrayList<>();

                workspaceMemberRepository.findByUserId(currentUser.getId())
                        .forEach(wm ->
                                tenantRepository.findById(wm.getTenantId())
                                        .ifPresent(t ->
                                                allWorkspaces.add(
                                                        new WorkspaceSwitcherController.WorkspaceInfo(
                                                                t.getId(),
                                                                t.getName(),
                                                                wm.getRole(),
                                                                t.getId().equals(tenantId),
                                                                t.getWorkspaceType()
                                                        )
                                                )
                                        )
                        );

                model.addAttribute("allWorkspaces", allWorkspaces);

            } catch (Exception e) {
                e.printStackTrace();
            }

            // chat messages
            try {
                List<WorkspaceChat> messages =
                        chatService.getMessages();

                model.addAttribute("messages", messages);

                if (!messages.isEmpty()) {
                    model.addAttribute(
                            "lastMessageId",
                            messages.get(messages.size() - 1).getId()
                    );
                }

            } catch (Exception e) {
                e.printStackTrace();
            }

            // announcements
            try {
                model.addAttribute(
                        "announcements",
                        announcementService.getAll()
                );

                model.addAttribute(
                        "pinnedAnnouncements",
                        announcementService.getPinned()
                );

            } catch (Exception e) {
                e.printStackTrace();
            }

            return "chat";

        } catch (Exception e) {
            e.printStackTrace();
            return "redirect:/dashboard?chat_error=true";
        }
    }

    @PostMapping("/send")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> send(@RequestParam String message, Authentication auth) {
        Map<String, Object> result = new HashMap<>();
        try {
            if (message == null || message.trim().isEmpty()) {
                result.put("success", false);
                result.put("error", "Message cannot be empty");
                return ResponseEntity.badRequest().body(result);
            }
            WorkspaceChat chat = chatService.send(message.trim(), auth.getName());
            result.put("success", true);
            result.put("id", chat.getId());
            result.put("message", chat.getMessage());
            result.put("sender", chat.getSenderUsername());
            result.put("timeAgo", chat.getTimeAgo());
            result.put("initial", chat.getInitial());
        } catch (Exception e) {
            e.printStackTrace();
            result.put("success", false);
            result.put("error", "Failed to send message");
        }
        return ResponseEntity.ok(result);
    }

    @GetMapping("/messages")
    @ResponseBody
    public ResponseEntity<List<Map<String, Object>>> getMessages() {
        List<Map<String, Object>> result = new ArrayList<>();
        try {
            chatService.getMessages().forEach(msg -> {
                Map<String, Object> m = new HashMap<>();
                m.put("id", msg.getId());
                m.put("message", msg.getMessage());
                m.put("sender", msg.getSenderUsername());
                m.put("timeAgo", msg.getTimeAgo());
                m.put("initial", msg.getInitial());
                result.add(m);
            });
        } catch (Exception e) {
            System.err.println("[ChatController] getMessages error: " + e.getMessage());
        }
        return ResponseEntity.ok(result);
    }

    // *** FIX: this endpoint was missing — chat.jsp JS calls /chat/delete/{id} ***
    @PostMapping("/delete/{id}")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> deleteMessage(@PathVariable Long id,
                                                              Authentication auth) {
        Map<String, Object> result = new HashMap<>();
        try {
            if (!TenantContext.isAdminOrOwner()) {
                result.put("success", false);
                result.put("error", "Permission denied");
                return ResponseEntity.status(403).body(result);
            }
            chatService.deleteMessage(id);
            result.put("success", true);
        } catch (Exception e) {
            result.put("success", false);
            result.put("error", e.getMessage());
        }
        return ResponseEntity.ok(result);
    }
    
 // Add to ChatController temporarily
    @GetMapping("/debug")
    @ResponseBody
    public String debug() {
        return "Tenant: " + TenantContext.getTenant() + 
               " | Role: " + TenantContext.getRole();
    }
}