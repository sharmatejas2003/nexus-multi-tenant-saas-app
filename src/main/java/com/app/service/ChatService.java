package com.app.service;
 
import com.app.entity.WorkspaceChat;
import com.app.repository.WorkspaceChatRepository;
import com.app.tenant.TenantContext;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.util.ArrayList;
import java.util.List;
 
@Service
public class ChatService {
 
    private final WorkspaceChatRepository repo;
    private final NotificationService notificationService;
 
    public ChatService(WorkspaceChatRepository repo, NotificationService notificationService) {
        this.repo = repo;
        this.notificationService = notificationService;
    }
 
    @Transactional
    public WorkspaceChat send(String message, String senderUsername) {
        Long tenantId = TenantContext.getTenant();
        if (tenantId == null) throw new RuntimeException("No tenant context");
 
        WorkspaceChat chat = new WorkspaceChat();
        chat.setTenantId(tenantId);
        chat.setSenderUsername(senderUsername);
        chat.setMessage(message.trim());
        return repo.save(chat);
    }
 
    public List<WorkspaceChat> getMessages() {
        Long tenantId = TenantContext.getTenant();
        if (tenantId == null) return new ArrayList<>();
        try {
            List<WorkspaceChat> msgs = repo.findByTenantIdAndNotDeleted(tenantId);
            return msgs;
        } catch (Exception e) {
            return new ArrayList<>();
        }
    }
 
    @Transactional
    public void deleteMessage(Long id) {
        repo.findById(id).ifPresent(m -> {
            m.setDeleted(true);
            repo.save(m);
        });
    }
}
 