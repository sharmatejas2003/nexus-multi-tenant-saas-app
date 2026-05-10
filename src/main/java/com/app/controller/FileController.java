package com.app.controller;

import com.app.entity.FileAttachment;
import com.app.repository.UserRepository;
import com.app.service.ActivityService;
import com.app.service.FileService;
import com.app.tenant.TenantContext;
import org.springframework.core.io.Resource;
import org.springframework.core.io.UrlResource;
import org.springframework.http.*;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import java.nio.file.Path;

@Controller
@RequestMapping("/files")
public class FileController {

    private final FileService fileService;
    private final UserRepository userRepository;
    private final ActivityService activityService;

    public FileController(FileService fileService, UserRepository userRepository, ActivityService activityService) {
        this.fileService = fileService;
        this.userRepository = userRepository;
        this.activityService = activityService;
    }

    @GetMapping
    public String listFiles(Model model) {
        model.addAttribute("files", fileService.getTenantFiles());
        return "files";
    }

    @PostMapping("/upload")
    public String upload(@RequestParam("file") MultipartFile file,
                         @RequestParam(value = "entityType", defaultValue = "GENERAL") String entityType,
                         @RequestParam(value = "entityId", defaultValue = "0") String entityId,
                         @RequestParam(value = "redirectTo", defaultValue = "/files") String redirectTo,
                         Authentication auth) {
        if (file.isEmpty()) return "redirect:" + redirectTo + "?error=empty";
        try {
            var user = userRepository.findByUsername(auth.getName());
            Long userId = user != null ? user.getId() : null;
            FileAttachment saved = fileService.upload(file, entityType, entityId, auth.getName(), userId);
            activityService.log("UPLOADED_FILE", entityType, entityId, saved.getOriginalName(), "File uploaded");
            return "redirect:" + redirectTo + "?uploaded=true";
        } catch (Exception e) {
            System.err.println("[FileController] Upload error: " + e.getMessage());
            return "redirect:" + redirectTo + "?error=upload_failed";
        }
    }

    @GetMapping("/download/{id}")
    public ResponseEntity<Resource> download(@PathVariable Long id) {
        try {
            FileAttachment meta = fileService.getById(id);
            if (!meta.getTenantId().equals(TenantContext.getTenant())) return ResponseEntity.status(403).build();
            Path filePath = fileService.getFilePath(id);
            Resource resource = new UrlResource(filePath.toUri());
            if (!resource.exists()) return ResponseEntity.notFound().build();
            String ct = meta.getContentType() != null ? meta.getContentType() : "application/octet-stream";
            return ResponseEntity.ok()
                    .contentType(MediaType.parseMediaType(ct))
                    .header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=\"" + meta.getOriginalName() + "\"")
                    .body(resource);
        } catch (Exception e) { return ResponseEntity.internalServerError().build(); }
    }

    @GetMapping("/preview/{id}")
    public ResponseEntity<Resource> preview(@PathVariable Long id) {
        try {
            FileAttachment meta = fileService.getById(id);
            if (!meta.getTenantId().equals(TenantContext.getTenant())) return ResponseEntity.status(403).build();
            Path filePath = fileService.getFilePath(id);
            Resource resource = new UrlResource(filePath.toUri());
            String ct = meta.getContentType() != null ? meta.getContentType() : "application/octet-stream";
            return ResponseEntity.ok()
                    .contentType(MediaType.parseMediaType(ct))
                    .header(HttpHeaders.CONTENT_DISPOSITION, "inline; filename=\"" + meta.getOriginalName() + "\"")
                    .body(resource);
        } catch (Exception e) { return ResponseEntity.internalServerError().build(); }
    }

    @PostMapping("/delete/{id}")
    public String delete(@PathVariable Long id,
                         @RequestParam(value = "redirectTo", defaultValue = "/files") String redirectTo) {
        try { fileService.delete(id); }
        catch (Exception e) { return "redirect:" + redirectTo + "?error=delete_failed"; }
        return "redirect:" + redirectTo + "?deleted=true";
    }
}