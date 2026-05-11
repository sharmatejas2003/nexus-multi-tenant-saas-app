package com.app.tenant;

import com.app.repository.UserRepository;
import com.app.repository.WorkspaceMemberRepository;
import jakarta.servlet.*;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;

import java.io.IOException;

@Component
public class TenantFilter implements Filter {

    private final UserRepository userRepository;
    private final WorkspaceMemberRepository workspaceMemberRepository;

    public TenantFilter(UserRepository userRepository, WorkspaceMemberRepository workspaceMemberRepository) {
        this.userRepository = userRepository;
        this.workspaceMemberRepository = workspaceMemberRepository;
    }

    @Override
    public void doFilter(ServletRequest req, ServletResponse res, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest request = (HttpServletRequest) req;
        Long tenantId = null;
        String role = "MEMBER";

        try {
            var auth = SecurityContextHolder.getContext().getAuthentication();
            if (auth != null && auth.isAuthenticated() && !"anonymousUser".equals(auth.getName())) {
                String username = auth.getName();

                // Try session first
                tenantId = (Long) request.getSession().getAttribute("tenantId");

                // If not in session, find from workspace membership
                if (tenantId == null) {
                    var members = workspaceMemberRepository.findByUserUsername(username);
                    if (!members.isEmpty()) {
                        var member = members.get(0); // Take first membership
                        tenantId = member.getTenantId();
                        role = member.getRole() != null ? member.getRole() : "MEMBER";
                        
                        // Save in session for future requests
                        request.getSession().setAttribute("tenantId", tenantId);
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        TenantContext.setTenant(tenantId);
        TenantContext.setRole(role);

        try {
            chain.doFilter(req, res);
        } finally {
            TenantContext.clear();
        }
    }
}