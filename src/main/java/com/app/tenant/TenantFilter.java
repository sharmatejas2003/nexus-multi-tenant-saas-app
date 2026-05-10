package com.app.tenant;

import com.app.entity.User;
import com.app.entity.WorkspaceMember;
import com.app.repository.UserRepository;
import com.app.repository.WorkspaceMemberRepository;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
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
    protected void doFilterInternal(
            HttpServletRequest request,
            HttpServletResponse response,
            FilterChain filterChain
    ) throws ServletException, IOException {

        String path = request.getRequestURI();

        // Public routes
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

        if (user != null) {

            // Get active workspace from session
            Long activeWorkspace =
                    (Long) request.getSession()
                            .getAttribute("activeWorkspaceId");

            // If none selected → choose first workspace
            if (activeWorkspace == null) {

                List<WorkspaceMember> memberships =
                        workspaceMemberRepository
                                .findByUserId(user.getId());

                if (!memberships.isEmpty()) {
                    activeWorkspace =
                            memberships.get(0).getTenantId();

                    request.getSession()
                            .setAttribute(
                                    "activeWorkspaceId",
                                    activeWorkspace
                            );
                } else {
                    activeWorkspace = user.getTenantId();
                }
            }

            TenantContext.setTenant(activeWorkspace);

            List<WorkspaceMember> memberships =
                    workspaceMemberRepository
                            .findByUserId(user.getId());

            for (WorkspaceMember wm : memberships) {
                if (wm.getTenantId().equals(activeWorkspace)) {
                    TenantContext.setRole(wm.getRole());
                    break;
                }
            }
        }

        filterChain.doFilter(request, response);
    }
}