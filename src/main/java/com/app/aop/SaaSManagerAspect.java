package com.app.aop;

import com.app.tenant.TenantContext;
import org.aspectj.lang.annotation.*;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;

@Aspect
@Component
public class SaaSManagerAspect {

    @Before("@annotation(com.app.annotation.TenantSecure)")
    public void enforceTenantIntegrity() {
        if (TenantContext.getTenant() == null) {
            throw new SecurityException("Access Denied: No active Tenant Context found.");
        }
    }

    @Before("execution(* com.app.service.*.save*(..))")
    public void logAuditTrail() {
        try {
            String user = SecurityContextHolder.getContext().getAuthentication().getName();
            Long tenant = TenantContext.getTenant();
            System.out.printf("[AUDIT LOG] Tenant: %d | User: %s | Action: Attempting Data Mutation%n", tenant, user);
        } catch (Exception ignored) {}
    }
}