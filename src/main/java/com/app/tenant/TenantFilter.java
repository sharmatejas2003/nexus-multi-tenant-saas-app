package com.app.tenant;

import com.app.entity.User;
import com.app.repository.UserRepository;
import jakarta.servlet.*;
import jakarta.servlet.http.*;

import org.springframework.security.authentication.AnonymousAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.filter.OncePerRequestFilter;
import java.io.IOException;

public class TenantFilter extends OncePerRequestFilter {
    private final UserRepository userRepository;

    public TenantFilter(UserRepository userRepository) { this.userRepository = userRepository; }

    @Override
    protected void doFilterInternal(
            HttpServletRequest request,
            HttpServletResponse response,
            FilterChain filterChain)
            throws ServletException, IOException {

        String path = request.getRequestURI();

        // Allow public routes
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

        // Not logged in yet → continue
        if (auth == null
                || !auth.isAuthenticated()
                || auth instanceof AnonymousAuthenticationToken) {

            filterChain.doFilter(request, response);
            return;
        }

        String username = auth.getName();

        User user = userRepository.findByUsername(username);

        if (user != null && user.getTenantId() != null) {
            TenantContext.setTenant(user.getTenantId());
        }

        filterChain.doFilter(request, response);
    }
}