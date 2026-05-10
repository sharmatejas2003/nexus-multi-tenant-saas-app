package com.app.repository;
import com.app.entity.FileAttachment;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;
public interface FileAttachmentRepository extends JpaRepository<FileAttachment, Long> {
    List<FileAttachment> findByEntityTypeAndEntityId(String entityType, String entityId);
    List<FileAttachment> findByTenantId(Long tenantId);
    List<FileAttachment> findByTenantIdOrderByUploadedAtDesc(Long tenantId);
    long countByTenantId(Long tenantId);
}