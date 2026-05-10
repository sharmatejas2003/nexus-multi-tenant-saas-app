package com.app.tenant;

public class TenantContext {

    private static final ThreadLocal<Long> tenant =
            new ThreadLocal<>();

    private static final ThreadLocal<String> role =
            new ThreadLocal<>();

    public static void setTenant(Long id) {
        tenant.set(id);
    }

    public static Long getTenant() {
        return tenant.get();
    }

    public static void setRole(String r) {
        role.set(r);
    }

    public static String getRole() {
        return role.get();
    }

    public static boolean isAdminOrOwner() {
        String r = role.get();

        return "OWNER".equals(r)
                || "ADMIN".equals(r);
    }

    public static void clear() {
        tenant.remove();
        role.remove();
    }
}