package com.app.tenant;

public class TenantContext {
    private static final ThreadLocal<Long> CURRENT_TENANT = new ThreadLocal<>();
    private static final ThreadLocal<String> CURRENT_ROLE = new ThreadLocal<>();

    public static Long getTenant() {
        return CURRENT_TENANT.get();
    }

    public static void setTenant(Long tenant) {
        CURRENT_TENANT.set(tenant);
    }

    public static String getRole() {
        return CURRENT_ROLE.get();
    }

    public static void setRole(String role) {
        CURRENT_ROLE.set(role);
    }

    public static boolean isAdminOrOwner() {
        String r = getRole();
        return "ADMIN".equalsIgnoreCase(r) || "OWNER".equalsIgnoreCase(r);
    }

    public static void clear() {
        CURRENT_TENANT.remove();
        CURRENT_ROLE.remove();
    }
}