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

            // public routes
            if (path.startsWith("/login")
                    || path.startsWith("/register")
                    || path.startsWith("/oauth2")
                    || path.startsWith("/css")
                    || path.startsWith("/js")
                    || path.startsWith("/error")
                    || path.equals("/favicon.ico")) {

                filterChain.doFilter(request, response);
                return;
            }

            Authentication auth =
                    SecurityContextHolder.getContext().getAuthentication();

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

            Long sessionWorkspaceId =
                    (Long) session.getAttribute("activeWorkspaceId");

            final Long activeWorkspaceId =
                    (sessionWorkspaceId != null)
                            ? sessionWorkspaceId
                            : user.getTenantId();

            // verify membership
            WorkspaceMember membership =
                    workspaceMemberRepository
                            .findByUserId(user.getId())
                            .stream()
                            .filter(m -> m.getTenantId().equals(activeWorkspaceId))
                            .findFirst()
                            .orElse(null);

            if (membership != null) {
                TenantContext.setTenant(activeWorkspaceId);
                TenantContext.setRole(membership.getRole());
            } else {
                // fallback
                TenantContext.setTenant(user.getTenantId());
                TenantContext.setRole(user.getRole());
            }

            filterChain.doFilter(request, response);

        } finally {
            TenantContext.clear();
        }
    }
}