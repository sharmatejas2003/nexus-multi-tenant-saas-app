package com.app.service;

import com.app.entity.Invitation;
import com.app.repository.InvitationRepository;
import com.app.tenant.TenantContext;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.UUID;

@Service
public class InvitationService {

    private final InvitationRepository repo;

    public InvitationService(InvitationRepository repo) {
        this.repo = repo;
    }

    /**
     * Creates an invitation record and returns the raw token.
     * The controller is responsible for building the full URL.
     */
    public String createInvitation(String email) {
        Invitation invite = new Invitation();
        invite.setEmail(email);
        invite.setTenantId(TenantContext.getTenant());
        invite.setToken(UUID.randomUUID().toString());
        invite.setExpiryDate(LocalDateTime.now().plusDays(7));
        repo.save(invite);
        return invite.getToken();
    }
}