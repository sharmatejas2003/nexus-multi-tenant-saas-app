package com.app.controller;

import com.app.entity.FileAttachment;
import com.app.service.FileService;
import com.app.tenant.TenantContext;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.core.io.Resource;
import org.springframework.core.io.UrlResource;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.net.MalformedURLException;
import java.nio.file.Path;
import java.util.List;

@Controller
@RequestMapping("/files")
public class FileController {

    private final FileService fileService;

    public FileController(FileService fileService) {
        this.fileService = fileService;
    }

    @GetMapping
    public String listFiles(Model model) {
        if (TenantContext.getTenant() == null) return "redirect:/login";
        List<FileAttachment> files = fileService.getTenantFiles();
        model.addAttribute("files", files);
        return "files";
    }

    @PostMapping("/upload")
    public String upload(@RequestParam("file") MultipartFile file,
                         @RequestParam(value = "entityType", defaultValue = "GENERAL") String entityType,
                         @RequestParam(value = "entityId", defaultValue = "0") String entityId,
                         @RequestParam(value = "redirectTo", defaultValue = "/files") String redirectTo,
                         Authentication auth) {
        if (TenantContext.getTenant() == null) return "redirect:/login";
        try {
            if (file.isEmpty()) return "redirect:" + redirectTo + "?error=empty_file";
            var user = fileService.getUserByUsername(auth.getName());
            Long userId = user != null ? user.getId() : null;
            fileService.upload(file, entityType, entityId, auth.getName(), userId);
            return "redirect:" + redirectTo + "?uploaded=true";
        } catch (Exception e) {
            return "redirect:" + redirectTo + "?error=" +
                    java.net.URLEncoder.encode(e.getMessage(), java.nio.charset.StandardCharsets.UTF_8);
        }
    }

    @GetMapping("/download/{id}")
    public ResponseEntity<Resource> download(@PathVariable Long id) {
        try {
            FileAttachment f = fileService.getById(id);
            Path path = fileService.getFilePath(id);
            Resource resource = new UrlResource(path.toUri());
            if (!resource.exists()) return ResponseEntity.notFound().build();
            return ResponseEntity.ok()
                    .contentType(MediaType.parseMediaType(
                            f.getContentType() != null ? f.getContentType() : "application/octet-stream"))
                    .header(HttpHeaders.CONTENT_DISPOSITION,
                            "attachment; filename=\"" + f.getOriginalName() + "\"")
                    .body(resource);
        } catch (Exception e) {
            return ResponseEntity.notFound().build();
        }
    }

    @GetMapping("/preview/{id}")
    public ResponseEntity<Resource> preview(@PathVariable Long id) {
        try {
            FileAttachment f = fileService.getById(id);
            Path path = fileService.getFilePath(id);
            Resource resource = new UrlResource(path.toUri());
            if (!resource.exists()) return ResponseEntity.notFound().build();
            return ResponseEntity.ok()
                    .contentType(MediaType.parseMediaType(
                            f.getContentType() != null ? f.getContentType() : "application/octet-stream"))
                    .header(HttpHeaders.CONTENT_DISPOSITION,
                            "inline; filename=\"" + f.getOriginalName() + "\"")
                    .body(resource);
        } catch (Exception e) {
            return ResponseEntity.notFound().build();
        }
    }

    @PostMapping("/delete/{id}")
    public String delete(@PathVariable Long id,
                         @RequestParam(value = "redirectTo", defaultValue = "/files") String redirectTo) {
        try {
            fileService.delete(id);
            return "redirect:" + redirectTo + "?deleted=true";
        } catch (Exception e) {
            return "redirect:" + redirectTo + "?error=" +
                    java.net.URLEncoder.encode(e.getMessage(), java.nio.charset.StandardCharsets.UTF_8);
        }
    }
}