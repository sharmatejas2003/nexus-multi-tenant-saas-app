package com.app.controller;


import com.app.entity.User;
import com.app.entity.WorkspaceMember;
import com.app.repository.TenantRepository;
import com.app.repository.UserRepository;
import com.app.repository.WorkspaceMemberRepository;
import com.app.tenant.TenantContext;
import jakarta.servlet.http.HttpSession;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import java.util.ArrayList;
import java.util.List;

@Controller
public class WorkspaceSwitcherController {

    private final UserRepository userRepository;
    private final WorkspaceMemberRepository workspaceMemberRepository;
    private final TenantRepository tenantRepository;

    public WorkspaceSwitcherController(UserRepository userRepository,
                                        WorkspaceMemberRepository workspaceMemberRepository,
                                        TenantRepository tenantRepository) {
        this.userRepository = userRepository;
        this.workspaceMemberRepository = workspaceMemberRepository;
        this.tenantRepository = tenantRepository;
    }

    @PostMapping("/workspace/switch")
    public String switchWorkspace(@RequestParam Long workspaceId,
                                   Authentication auth,
                                   HttpSession session) {
        User user = userRepository.findByUsername(auth.getName());
        if (user == null) return "redirect:/login";

        boolean isMember = workspaceMemberRepository
                .existsByUserIdAndTenantId(user.getId(), workspaceId);

        if (isMember) {
            session.setAttribute("activeWorkspaceId", workspaceId);
        }
        return "redirect:/dashboard";
    }

    @GetMapping("/workspace/new")
    public String newWorkspacePage(Model model, Authentication auth) {
        Long tenantId = TenantContext.getTenant();
        if (tenantId == null) return "redirect:/login";

        User user = userRepository.findByUsername(auth.getName());
        model.addAttribute("currentUser", user);
        return "workspace-new";
    }

    public List<WorkspaceInfo> getWorkspacesForUser(User user, Long activeId) {
        List<WorkspaceInfo> list = new ArrayList<>();
        List<WorkspaceMember> memberships = workspaceMemberRepository.findByUserId(user.getId());
        for (WorkspaceMember wm : memberships) {
            tenantRepository.findById(wm.getTenantId()).ifPresent(t -> {
                list.add(new WorkspaceInfo(
                        t.getId(),
                        t.getName(),
                        wm.getRole(),
                        t.getId().equals(activeId),
                        t.getWorkspaceType()
                ));
            });
        }
        return list;
    }

    // ─────────────────────────────────────────────────────────────
    // WorkspaceInfo — ALL fields must have proper getters so that
    // JSP EL (${ws.active}, ${ws.name}, etc.) can resolve them.
    // Public fields alone are NOT enough for Jakarta EL — it needs
    // JavaBean-style getter methods (getX / isX).
    // ─────────────────────────────────────────────────────────────
    public static class WorkspaceInfo {
        private final Long id;
        private final String name;
        private final String role;
        private final boolean active;
        private final String workspaceType;

        public WorkspaceInfo(Long id, String name, String role,
                             boolean active, String workspaceType) {
            this.id            = id;
            this.name          = name;
            this.role          = role;
            this.active        = active;
            this.workspaceType = workspaceType;
        }

        // ── Getters (required by JSP EL) ──
        public Long    getId()            { return id; }
        public String  getName()          { return name; }
        public String  getRole()          { return role; }
        public boolean isActive()         { return active; }   // boolean → isX()
        public String  getWorkspaceType() { return workspaceType; }

        // ── Helper used in sidebar.jsp: ${ws.icon} ──
        public String getIcon() {
            return "PERSONAL".equalsIgnoreCase(workspaceType) ? "🧑" : "🏢";
        }
    }
}