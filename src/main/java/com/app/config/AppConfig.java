package com.app.config;

import org.springframework.context.annotation.*;

@Configuration
public class AppConfig {
    @Bean
    @Scope("singleton")
    public String appName() {
        return "MultiTenantSaasApp";
    }
}