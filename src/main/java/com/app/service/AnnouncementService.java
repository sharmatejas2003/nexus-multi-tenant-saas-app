package com.app.service;
 
import com.app.entity.Announcement;
import com.app.repository.AnnouncementRepository;
import com.app.tenant.TenantContext;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.util.ArrayList;
import java.util.List;
 
@Service
public class AnnouncementService {
 
    private final AnnouncementRepository repo;
 
    public AnnouncementService(AnnouncementRepository repo) {
        this.repo = repo;
    }
 
    public List<Announcement> getAll() {
        Long tenantId = TenantContext.getTenant();
        if (tenantId == null) return new ArrayList<>();
        try {
            return repo.findByTenantIdOrderByPinnedDescCreatedAtDesc(tenantId);
        } catch (Exception e) { return new ArrayList<>(); }
    }
 
    public List<Announcement> getPinned() {
        Long tenantId = TenantContext.getTenant();
        if (tenantId == null) return new ArrayList<>();
        try {
            return repo.findByTenantIdAndPinnedTrueOrderByCreatedAtDesc(tenantId);
        } catch (Exception e) { return new ArrayList<>(); }
    }
 
    @Transactional
    public Announcement save(Announcement a, String createdBy) {
        a.setTenantId(TenantContext.getTenant());
        a.setCreatedBy(createdBy);
        return repo.save(a);
    }
 
    @Transactional
    public void delete(Long id) {
        repo.deleteById(id);
    }
}
 