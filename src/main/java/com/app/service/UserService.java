package com.app.service;

import com.app.entity.User;
import com.app.repository.UserRepository;
import com.app.tenant.TenantContext;
import org.springframework.stereotype.Service;

@Service
public class UserService {
    private final UserRepository repo;

    public UserService(UserRepository repo) { this.repo = repo; }

    public User save(User user) {
        Long tenantId = TenantContext.getTenant();
        if (tenantId != null) user.setTenantId(tenantId);
        return repo.save(user);
    }

    public User findByUsername(String username) { return repo.findByUsername(username); }
}