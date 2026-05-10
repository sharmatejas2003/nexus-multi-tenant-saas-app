package com.app.aop;

import org.aspectj.lang.annotation.*;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;

@Aspect
@Component
public class RoleCheckAspect {

    @Before("@annotation(com.app.annotation.AdminOnly)")
    public void checkAdmin() {
        boolean isAdmin = SecurityContextHolder.getContext()
                .getAuthentication()
                .getAuthorities()
                .stream()
                .anyMatch(a -> a.getAuthority().equals("ROLE_ADMIN")
                            || a.getAuthority().equals("ROLE_OWNER"));
        if (!isAdmin) {
            throw new AccessDeniedException("Access denied: Admin or Owner role required.");
        }
    }
}