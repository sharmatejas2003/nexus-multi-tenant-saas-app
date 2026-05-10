package com.app.controller;

import com.app.entity.Note;
import com.app.repository.NoteRepository;
import com.app.service.ActivityService;
import com.app.tenant.TenantContext;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

@Controller
@RequestMapping("/notes")
public class NoteController {
    private final NoteRepository noteRepo;
    private final ActivityService activityService;

    public NoteController(NoteRepository noteRepo, ActivityService activityService) {
        this.noteRepo = noteRepo;
        this.activityService = activityService;
    }

    @GetMapping
    public String viewNotes(Model model) {
        model.addAttribute("notes", noteRepo.findByTenantIdOrderByCreatedAtDesc(TenantContext.getTenant()));
        return "NotesList";
    }

    @PostMapping("/save")
    public String saveNote(@ModelAttribute Note note, Authentication auth) {
        note.setTenantId(TenantContext.getTenant());
        note.setLastEditedBy(auth.getName());
        noteRepo.save(note);
        activityService.log("CREATED_NOTE", "NOTE", String.valueOf(note.getId()), note.getTitle(), "Note created");
        return "redirect:/notes";
    }

    @PostMapping("/delete/{id}")
    public String delete(@PathVariable Long id) {
        noteRepo.deleteById(id);
        return "redirect:/notes";
    }

    @PostMapping("/update")
    public String update(Note note, Authentication auth) {
        note.setTenantId(TenantContext.getTenant());
        note.setLastEditedBy(auth.getName());
        noteRepo.save(note);
        return "redirect:/notes";
    }
}