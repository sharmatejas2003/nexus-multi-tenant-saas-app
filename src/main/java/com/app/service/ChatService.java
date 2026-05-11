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

    public ChatService(WorkspaceChatRepository repo) {
        this.repo = repo;
    }

    @Transactional
    public WorkspaceChat send(String message, String senderUsername) {
        Long tenantId = TenantContext.getTenant();
        if (tenantId == null) {
            throw new SecurityException("No active tenant context");
        }

        WorkspaceChat chat = new WorkspaceChat();
        chat.setTenantId(tenantId);
        chat.setSenderUsername(senderUsername);
        chat.setMessage(message);
        chat.setMessageType("TEXT");

        return repo.save(chat);
    }

    public List<WorkspaceChat> getMessages() {
        Long tenantId = TenantContext.getTenant();
        if (tenantId == null) return new ArrayList<>();

        try {
            return repo.findByTenantIdAndNotDeleted(tenantId);
        } catch (Exception e) {
            e.printStackTrace();
            return new ArrayList<>();
        }
    }

    @Transactional
    public void deleteMessage(Long id) {
        repo.findById(id).ifPresent(chat -> {
            chat.setDeleted(true);
            repo.save(chat);
        });
    }
}