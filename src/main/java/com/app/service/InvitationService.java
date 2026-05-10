package com.app.service;

import java.time.LocalDateTime;
import java.util.UUID;

import org.springframework.stereotype.Service;
import org.springframework.web.servlet.support.ServletUriComponentsBuilder;

import com.app.entity.Invitation;
import com.app.repository.InvitationRepository;
import com.app.tenant.TenantContext;

@Service
public class InvitationService {
    private final InvitationRepository repo;

    public InvitationService(InvitationRepository repo) {
        this.repo = repo;
    }

    public String createInvitation(String email) {
        Invitation invite = new Invitation();
        invite.setEmail(email);
        invite.setTenantId(TenantContext.getTenant());
        invite.setToken(UUID.randomUUID().toString()); // Secure random token
        invite.setExpiryDate(LocalDateTime.now().plusDays(7));
        repo.save(invite);
        
        String baseUrl = ServletUriComponentsBuilder
                .fromCurrentContextPath()
                .build()
                .toUriString();

        return baseUrl + "/register?token=" + invite.getToken();
    }
}
