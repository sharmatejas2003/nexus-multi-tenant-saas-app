package com.app.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;

import com.app.entity.Note;

public interface NoteRepository extends JpaRepository<Note, Long> {
	List<Note> findByTenantIdOrderByCreatedAtDesc(Long tenantId);
    List<Note> findByTenantId(Long tenantId);
}
