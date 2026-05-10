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
        Path uploadPath = Paths.get(uploadDir, String.valueOf(TenantContext.getTenant()));
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
        attachment.setEntityType(entityType);
        attachment.setEntityId(entityId);
        attachment.setTenantId(TenantContext.getTenant());
        attachment.setUploadedBy(userId);
        attachment.setUploadedByUsername(username);
        attachment.setStoragePath(filePath.toString());

        return repo.save(attachment);
    }

    public List<FileAttachment> getAttachments(String entityType, String entityId) {
        return repo.findByEntityTypeAndEntityId(entityType, entityId);
    }

    public List<FileAttachment> getTenantFiles() {
        return repo.findByTenantIdOrderByUploadedAtDesc(TenantContext.getTenant());
    }

    public FileAttachment getById(Long id) {
        return repo.findById(id).orElseThrow(() -> new RuntimeException("File not found"));
    }

    public void delete(Long id) throws IOException {
        FileAttachment f = getById(id);
        if (!f.getTenantId().equals(TenantContext.getTenant())) {
            throw new SecurityException("Access denied");
        }
        try {
            Files.deleteIfExists(Paths.get(f.getStoragePath()));
        } catch (IOException e) {
            System.err.println("Warning: Could not delete file from disk: " + e.getMessage());
        }
        repo.deleteById(id);
    }

    public Path getFilePath(Long id) {
        FileAttachment f = getById(id);
        if (!f.getTenantId().equals(TenantContext.getTenant())) {
            throw new SecurityException("Access denied");
        }
        return Paths.get(f.getStoragePath());
    }
}