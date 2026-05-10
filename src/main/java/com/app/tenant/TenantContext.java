package com.app.tenant;

public class TenantContext {
    private static final ThreadLocal<Long> tenant = new ThreadLocal<>();
    private static final ThreadLocal<String> role = new ThreadLocal<>();
    private static final ThreadLocal<String> CURRENT_ROLE = new ThreadLocal<>();


    public static void setTenant(Long id) { tenant.set(id); }
    public static Long getTenant() { return tenant.get(); }

    public static void setRole(String r) { role.set(r); }
    public static String getRole() { return role.get(); }

    public static boolean isAdminOrOwner() {
        String r = role.get();
        return "ADMIN".equals(r) || "OWNER".equals(r);
    }

    public static void clear() {
        CURRENT_TENANT.remove();
        CURRENT_ROLE.remove();
    }}
    
    
}