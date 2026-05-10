package com.app.aop;

import org.aspectj.lang.annotation.Aspect;
import org.aspectj.lang.annotation.Before;
import org.springframework.core.annotation.Order;
import org.springframework.stereotype.Component;

import com.app.tenant.TenantContext;

/**
 * SecurityAspect — validates TenantContext before @TenantSecure methods.
 * NOTE: SaaSManagerAspect also handles @TenantSecure; this one runs first (@Order(1)).
 * They are intentionally kept separate for layered security concerns.
 */
@Aspect
@Component
@Order(1)
public class SecurityAspect {

    @Before("@annotation(com.app.annotation.TenantSecure)")
    public void verifyTenant() {
        if (TenantContext.getTenant() == null) {
            throw new SecurityException("Illegal access: No Tenant Context established!");
        }
    }
}