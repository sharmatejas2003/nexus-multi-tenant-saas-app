package com.app.tenant;

public class TenantContext {
	private static final ThreadLocal<Long> tenant = new ThreadLocal<>();

    public static void setTenant(Long id) {
        tenant.set(id);
    }

    public static Long getTenant() {
        return tenant.get();
    }
    public static void clear() {
        tenant.remove();
    }


}
