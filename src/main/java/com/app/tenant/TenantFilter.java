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

    public TenantFilter(UserRepository userRepository) {
        this.userRepository = userRepository;
    }

    @Override
    protected void doFilterInternal(HttpServletRequest request,
                                    HttpServletResponse response,
                                    FilterChain filterChain)
            throws ServletException, IOException {

        try {
            String path = request.getRequestURI();

            // Allow public routes without tenant resolution
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
            if (user != null && user.getTenantId() != null) {
                TenantContext.setTenant(user.getTenantId());
            }

            filterChain.doFilter(request, response);

        } finally {
            // CRITICAL: always clear to avoid thread-pool reuse leaking tenant IDs
            TenantContext.clear();
        }
    }
}