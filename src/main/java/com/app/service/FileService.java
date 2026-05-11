package com.app.service;

import com.app.entity.FileAttachment;
import com.app.entity.User;
import com.app.repository.FileAttachmentRepository;
import com.app.repository.UserRepository;
import com.app.tenant.TenantContext;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.nio.file.*;
import java.util.Collections;
import java.util.List;
import java.util.UUID;

@Service
public class FileService {

    private final FileAttachmentRepository repo;
    private final UserRepository userRepository;

    @Value("${app.upload.dir:uploads}")
    private String uploadDir;

    public FileService(FileAttachmentRepository repo, UserRepository userRepository) {
        this.repo = repo;
        this.userRepository = userRepository;
    }

    public User getUserByUsername(String username) {
        return userRepository.findByUsername(username);
    }

    public FileAttachment upload(MultipartFile file, String entityType, String entityId,
                                  String username, Long userId) throws IOException {
        Long tenantId = TenantContext.getTenant();
        if (tenantId == null) throw new RuntimeException("No tenant context");

        Path uploadPath = Paths.get(uploadDir, String.valueOf(tenantId));
        Files.createDirectories(uploadPath);

        String extension = "";
        String original = file.getOriginalFilename();
        if (original != null && original.contains(".")) {
            extension = original.substring(original.lastIndexOf("."));
        }
        String storedName = UUID.randomUUID().toString() + extension;
        Path filePath = uploadPath.resolve(storedName);
        Files.copy(file.getInputStream(), filePath, StandardCopyOption.REPLACE_EXISTING);

        FileAttachment attachment = new FileAttachment();
        attachment.setOriginalName(original);
        attachment.setStoredName(storedName);
        attachment.setContentType(file.getContentType());
        attachment.setFileSize(file.getSize());
        // Normalize entityType to uppercase for consistent querying
        attachment.setEntityType(entityType != null ? entityType.toUpperCase() : "GENERAL");
        attachment.setEntityId(entityId);
        attachment.setTenantId(tenantId);
        attachment.setUploadedBy(userId);
        attachment.setUploadedByUsername(username);
        attachment.setStoragePath(filePath.toString());

        FileAttachment saved = repo.save(attachment);
        System.out.println("[FileService] Uploaded: " + original + " entityType=" + attachment.getEntityType() + " entityId=" + entityId);
        return saved;
    }

    public List<FileAttachment> getAttachments(String entityType, String entityId) {
        if (entityType == null || entityId == null) return Collections.emptyList();
        try {
            // Try both cases
            List<FileAttachment> result = repo.findByEntityTypeAndEntityId(entityType.toUpperCase(), entityId);
            if (result.isEmpty()) {
                result = repo.findByEntityTypeAndEntityId(entityType, entityId);
            }
            return result;
        } catch (Exception e) {
            System.err.println("[FileService] getAttachments error: " + e.getMessage());
            return Collections.emptyList();
        }
    }

    public List<FileAttachment> getAttachmentsForTask(Long taskId) {
        return getAttachments("TASK", String.valueOf(taskId));
    }

    public List<FileAttachment> getTenantFiles() {
        Long tenantId = TenantContext.getTenant();
        if (tenantId == null) return Collections.emptyList();
        try {
            return repo.findByTenantIdOrderByUploadedAtDesc(tenantId);
        } catch (Exception e) {
            return Collections.emptyList();
        }
    }

    public FileAttachment getById(Long id) {
        return repo.findById(id).orElseThrow(() -> new RuntimeException("File not found"));
    }

    public void delete(Long id) throws IOException {
        FileAttachment f = getById(id);
        Long tenantId = TenantContext.getTenant();
        if (tenantId != null && !f.getTenantId().equals(tenantId)) {
            throw new SecurityException("Access denied");
        }
        try {
            if (f.getStoragePath() != null) {
                Files.deleteIfExists(Paths.get(f.getStoragePath()));
            }
        } catch (IOException e) {
            System.err.println("Warning: Could not delete file from disk: " + e.getMessage());
        }
        repo.deleteById(id);
    }

    public Path getFilePath(Long id) {
        FileAttachment f = getById(id);
        Long tenantId = TenantContext.getTenant();
        if (tenantId != null && !f.getTenantId().equals(tenantId)) {
            throw new SecurityException("Access denied");
        }
        if (f.getStoragePath() == null) throw new RuntimeException("File path not found");
        return Paths.get(f.getStoragePath());
    }
}