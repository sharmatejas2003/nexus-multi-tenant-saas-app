package com.app.tenant;

import com.app.entity.User;
import com.app.entity.WorkspaceMember;
import com.app.repository.UserRepository;
import com.app.repository.WorkspaceMemberRepository;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import org.springframework.security.authentication.AnonymousAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;
import java.util.List;

public class TenantFilter extends OncePerRequestFilter {

    private final UserRepository userRepository;
    private final WorkspaceMemberRepository workspaceMemberRepository;

    public TenantFilter(UserRepository userRepository,
                        WorkspaceMemberRepository workspaceMemberRepository) {
        this.userRepository = userRepository;
        this.workspaceMemberRepository = workspaceMemberRepository;
    }

    @Override
    protected void doFilterInternal(HttpServletRequest request,
                                    HttpServletResponse response,
                                    FilterChain filterChain)
            throws ServletException, IOException {

        try {
            String path = request.getRequestURI();

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

            Authentication auth = SecurityContextHolder.getContext().getAuthentication();

            if (auth == null || !auth.isAuthenticated() || auth instanceof AnonymousAuthenticationToken) {
                filterChain.doFilter(request, response);
                return;
            }

            User user = userRepository.findByUsername(auth.getName());
            if (user != null) {
                HttpSession session = request.getSession(false);

                // Check if user wants to switch workspace
                String switchTo = request.getParameter("switchWorkspace");
                if (switchTo != null) {
                    try {
                        Long switchId = Long.parseLong(switchTo);
                        // Verify user is member of that workspace
                        boolean isMember = workspaceMemberRepository
                                .existsByUserIdAndTenantId(user.getId(), switchId);
                        if (isMember) {
                            if (session == null) session = request.getSession(true);
                            session.setAttribute("activeWorkspaceId", switchId);
                        }
                    } catch (NumberFormatException ignored) {}
                }

                // Determine active workspace
                Long activeWorkspaceId = null;
                if (session != null) {
                    activeWorkspaceId = (Long) session.getAttribute("activeWorkspaceId");
                }

                if (activeWorkspaceId == null) {
                    // Default: user's primary tenantId
                    activeWorkspaceId = user.getTenantId();
                    if (session != null && activeWorkspaceId != null) {
                        session.setAttribute("activeWorkspaceId", activeWorkspaceId);
                    }
                }

                // Verify user is still a member of the active workspace
                if (activeWorkspaceId != null) {
                    boolean stillMember = workspaceMemberRepository
                            .existsByUserIdAndTenantId(user.getId(), activeWorkspaceId);
                    if (!stillMember) {
                        // Fall back to primary
                        activeWorkspaceId = user.getTenantId();
                        if (session != null) {
                            session.setAttribute("activeWorkspaceId", activeWorkspaceId);
                        }
                    }
                }

                if (activeWorkspaceId != null) {
                    TenantContext.setTenant(activeWorkspaceId);

                    // Also store the user's role in the active workspace
                    workspaceMemberRepository
                            .findByUserIdAndTenantId(user.getId(), activeWorkspaceId)
                            .ifPresent(wm -> TenantContext.setRole(wm.getRole()));
                }
            }

            filterChain.doFilter(request, response);

        } finally {
            TenantContext.clear();
        }
    }
}