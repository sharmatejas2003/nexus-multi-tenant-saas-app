package com.app.controller;

import com.app.repository.UserRepository;
import com.app.service.ActivityService;
import com.app.tenant.TenantContext;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

@Controller
@RequestMapping("/activity")
public class ActivityController {

    private final ActivityService activityService;
    private final UserRepository userRepository;

    public ActivityController(ActivityService activityService, UserRepository userRepository) {
        this.activityService = activityService;
        this.userRepository = userRepository;
    }

    @GetMapping
    public String activityLog(Model model, Authentication auth,
                               @RequestParam(required = false) String filter) {
        Long tenantId = TenantContext.getTenant();
        if (tenantId == null) return "redirect:/login";

        // Only ADMIN/OWNER can view activity logs
        if (!TenantContext.isAdminOrOwner()) {
            return "redirect:/dashboard?error=access_denied";
        }

        model.addAttribute("currentUser", userRepository.findByUsername(auth.getName()));
        model.addAttribute("activityLogs", activityService.getAllActivity());
        model.addAttribute("filter", filter);
        return "activity-log";
    }
}