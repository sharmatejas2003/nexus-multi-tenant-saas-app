package com.app.aop;

import org.aspectj.lang.annotation.*;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;

@Aspect
@Component
public class LoggingAspect {

    @AfterReturning(pointcut = "execution(* com.app.service.*.save*(..))", returning = "result")
    public void auditAction(Object result) {
        String user = SecurityContextHolder.getContext().getAuthentication().getName();
        System.out.println("[AUDIT] Action by: " + user + " | Resource Created: " + result);
    }

    @AfterThrowing(pointcut = "execution(* com.app.service.*.*(..))", throwing = "ex")
    public void logError(Exception ex) {
        System.err.println("[CRITICAL ERROR] Logic failure: " + ex.getMessage());
    }
}
