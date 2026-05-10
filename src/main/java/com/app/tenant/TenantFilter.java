package com.app.tenant;

import com.app.entity.User;
import com.app.entity.WorkspaceMember;
import com.app.repository.UserRepository;
import com.app.repository.WorkspaceMemberRepository;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import org.springframework.security.authentication.AnonymousAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;

public class TenantFilter extends OncePerRequestFilter {

    private final UserRepository userRepository;
    private final WorkspaceMemberRepository workspaceMemberRepository;

    public TenantFilter(UserRepository userRepository,
                        WorkspaceMemberRepository workspaceMemberRepository) {
        this.userRepository = userRepository;
        this.workspaceMemberRepository = workspaceMemberRepository;
    }

    @Override
    protected void doFilterInternal(
            HttpServletRequest request,
            HttpServletResponse response,
            FilterChain filterChain)
            throws ServletException, IOException {

        try {
            String path = request.getRequestURI();

            // Skip public routes
            if (path.startsWith("/login")
                    || path.startsWith("/register")
                    || path.startsWith("/oauth2")
                    || path.startsWith("/css")
                    || path.startsWith("/js")
                    || path.startsWith("/error")
                    || path.equals("/favicon.ico")
                    || path.startsWith("/perform_login")) {
                filterChain.doFilter(request, response);
                return;
            }

            Authentication auth = SecurityContextHolder.getContext().getAuthentication();

            if (auth == null
                    || !auth.isAuthenticated()
                    || auth instanceof AnonymousAuthenticationToken) {
                filterChain.doFilter(request, response);
                return;
            }

            String username = auth.getName();
            User user = userRepository.findByUsername(username);

            if (user == null) {
                filterChain.doFilter(request, response);
                return;
            }

            HttpSession session = request.getSession();
            Long sessionWorkspaceId = (Long) session.getAttribute("activeWorkspaceId");

            final Long activeWorkspaceId = (sessionWorkspaceId != null)
                    ? sessionWorkspaceId
                    : user.getTenantId();

            if (activeWorkspaceId == null) {
                // User has no tenant at all — critical error, redirect to login
                filterChain.doFilter(request, response);
                return;
            }

            // Try to find membership record
            WorkspaceMember membership = workspaceMemberRepository
                    .findByUserId(user.getId())
                    .stream()
                    .filter(m -> m.getTenantId().equals(activeWorkspaceId))
                    .findFirst()
                    .orElse(null);

            if (membership != null) {
                TenantContext.setTenant(activeWorkspaceId);
                TenantContext.setRole(membership.getRole());
            } else {
                // MIGRATION FALLBACK: user exists but has no workspace_members row yet.
                // Auto-create the membership so they can log in.
                String role = user.getRole() != null ? user.getRole() : "OWNER";
                try {
                    WorkspaceMember autoMember = new WorkspaceMember();
                    autoMember.setUserId(user.getId());
                    autoMember.setTenantId(activeWorkspaceId);
                    autoMember.setRole(role);
                    workspaceMemberRepository.save(autoMember);
                    System.out.println("[TenantFilter] Auto-created workspace membership for: " + username);
                } catch (Exception e) {
                    System.err.println("[TenantFilter] Could not auto-create membership: " + e.getMessage());
                }
                TenantContext.setTenant(activeWorkspaceId);
                TenantContext.setRole(role);
            }

            filterChain.doFilter(request, response);

        } finally {
            TenantContext.clear();
        }
    }
}