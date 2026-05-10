package com.app.tenant;

public class TenantContext {

    private static final ThreadLocal<Long> CURRENT_TENANT =
            new ThreadLocal<>();

    private static final ThreadLocal<String> CURRENT_ROLE =
            new ThreadLocal<>();

    public static void setTenant(Long tenantId) {
        CURRENT_TENANT.set(tenantId);
    }

    public static Long getTenant() {
        return CURRENT_TENANT.get();
    }

    public static void setRole(String role) {
        CURRENT_ROLE.set(role);
    }

    public static String getRole() {
        return CURRENT_ROLE.get();
    }

    public static boolean isAdminOrOwner() {
        String role = CURRENT_ROLE.get();
        return "OWNER".equals(role)
                || "ADMIN".equals(role);
    }

    public static void clear() {
        CURRENT_TENANT.remove();
        CURRENT_ROLE.remove();
    }
}