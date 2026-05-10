package com.app.controller;

import com.app.entity.Project;
import com.app.entity.Task;
import com.app.repository.*;
import com.app.service.*;
import com.app.tenant.TenantContext;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.ModelAndView;
import java.util.List;

@Controller
@RequestMapping("/projects")
public class ProjectController {

    private final ProjectService service;
    private final UserRepository userRepository;
    private final TaskService taskService;
    private final FileService fileService;
    private final ActivityService activityService;
    private final TaskCommentRepository commentRepo;
    private final WorkspaceMemberRepository workspaceMemberRepository;

    public ProjectController(ProjectService service, UserRepository userRepository,
                              TaskService taskService, FileService fileService,
                              ActivityService activityService, TaskCommentRepository commentRepo,
                              WorkspaceMemberRepository workspaceMemberRepository) {
        this.service = service;
        this.userRepository = userRepository;
        this.taskService = taskService;
        this.fileService = fileService;
        this.activityService = activityService;
        this.commentRepo = commentRepo;
        this.workspaceMemberRepository = workspaceMemberRepository;
    }

    @GetMapping
    public ModelAndView showProjectsPage(Authentication auth) {
        ModelAndView mav = new ModelAndView("projects");
        Long tenantId = TenantContext.getTenant();
        if (tenantId == null) return new ModelAndView("redirect:/login");

        String role = TenantContext.getRole();
        mav.addObject("projects", service.getAll());
        mav.addObject("workspaceMembers", userRepository.findByTenantId(tenantId));
        mav.addObject("currentRole", role);
        mav.addObject("isAdminOrOwner", TenantContext.isAdminOrOwner());
        return mav;
    }

    @GetMapping("/view/{id}")
    public ModelAndView viewProject(@PathVariable String id, Authentication auth) {
        ModelAndView mav = new ModelAndView("project-details");
        Long tenantId = TenantContext.getTenant();
        if (tenantId == null) return new ModelAndView("redirect:/login");

        Project project = service.getById(id);
        if (project == null || !project.getTenantId().equals(tenantId)) {
            return new ModelAndView("redirect:/projects");
        }

        String role = TenantContext.getRole();
        boolean isAdminOrOwner = TenantContext.isAdminOrOwner();

        List<Task> tasks = taskService.getByProject(id);
        List<com.app.entity.FileAttachment> attachments = fileService.getAttachments("PROJECT", id);

        long total = tasks.size();
        long done = tasks.stream().filter(t -> "DONE".equals(t.getStatus())).count();
        long inProgress = tasks.stream().filter(t -> "IN_PROGRESS".equals(t.getStatus())).count();
        long overdue = tasks.stream().filter(t -> "OVERDUE".equals(t.getStatus())).count();
        int progress = total > 0 ? (int) (done * 100 / total) : 0;

        tasks.forEach(t -> {
            long count = commentRepo.countByTaskId(t.getId());
            t.setAttachments(String.valueOf(count));
        });

        mav.addObject("project", project);
        mav.addObject("tasks", tasks);
        mav.addObject("attachments", attachments);
        mav.addObject("workspaceMembers", userRepository.findByTenantId(tenantId));
        mav.addObject("tasksDone", done);
        mav.addObject("tasksInProgress", inProgress);
        mav.addObject("tasksOverdue", overdue);
        mav.addObject("taskProgress", progress);
        mav.addObject("totalTasks", total);
        mav.addObject("currentRole", role);
        mav.addObject("isAdminOrOwner", isAdminOrOwner);
        mav.addObject("currentUsername", auth.getName());
        return mav;
    }

    @PostMapping("/add")
    public String addProject(@RequestParam String name,
                              @RequestParam(required = false) String description,
                              @RequestParam(required = false) String deadline,
                              Authentication auth) {
        if (TenantContext.getTenant() == null) return "redirect:/projects?error=tenant_missing";

        // Only ADMIN/OWNER can create projects
        if (!TenantContext.isAdminOrOwner()) {
            return "redirect:/projects?error=permission_denied";
        }

        Project p = new Project();
        p.setName(name);
        p.setDescription(description);
        if (deadline != null && !deadline.isEmpty()) {
            try { p.setDeadline(java.time.LocalDateTime.parse(deadline + "T00:00:00")); }
            catch (Exception ignored) {}
        }
        try {
            service.save(p);

            // Notify all workspace members about the new project
            notifyAllMembers(TenantContext.getTenant(), auth.getName(),
                    "🚀 New project created: " + name,
                    "/projects", "PROJECT_CREATED");

            return "redirect:/projects?success=created";
        } catch (Exception e) {
            return "redirect:/projects?error=" + java.net.URLEncoder.encode(e.getMessage(), java.nio.charset.StandardCharsets.UTF_8);
        }
    }

    @PostMapping("/delete/{id}")
    public String deleteProject(@PathVariable String id, Authentication auth) {
        // Only ADMIN/OWNER can delete
        if (!TenantContext.isAdminOrOwner()) {
            return "redirect:/projects?error=permission_denied";
        }
        Long currentTenant = TenantContext.getTenant();
        Project p = service.getById(id);
        if (p != null && p.getTenantId().equals(currentTenant)) service.delete(id);
        return "redirect:/projects";
    }

    @PostMapping("/update/{id}")
    public String updateProject(@PathVariable String id,
                                 @RequestParam String name,
                                 @RequestParam(required = false) String description,
                                 @RequestParam(required = false) String status) {
        // Only ADMIN/OWNER can update project details
        if (!TenantContext.isAdminOrOwner()) {
            return "redirect:/projects/view/" + id + "?error=permission_denied";
        }
        Long currentTenant = TenantContext.getTenant();
        Project p = service.getById(id);
        if (p != null && p.getTenantId().equals(currentTenant)) {
            p.setName(name);
            p.setDescription(description);
            if (status != null) p.setStatus(status);
            service.save(p);
        }
        return "redirect:/projects/view/" + id;
    }

    private void notifyAllMembers(Long tenantId, String triggeredBy, String message,
                                   String link, String type) {
        try {
            var members = userRepository.findByTenantId(tenantId);
            for (var m : members) {
                if (!m.getUsername().equals(triggeredBy)) {
                    // We'll call NotificationService via the service layer
                }
            }
        } catch (Exception ignored) {}
    }
}