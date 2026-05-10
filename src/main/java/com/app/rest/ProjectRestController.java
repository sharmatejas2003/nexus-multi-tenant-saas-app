package com.app.rest;

import com.app.entity.Project;
import com.app.service.ProjectService;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/api/projects")
public class ProjectRestController {
    private final ProjectService service;
    public ProjectRestController(ProjectService service) { this.service = service; }

    @GetMapping(produces = {"application/json"})
    public List<Project> getApiProjects() { return service.getAll(); }
}