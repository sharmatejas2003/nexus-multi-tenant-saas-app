package com.app.exception;

import org.springframework.http.HttpStatus;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.servlet.NoHandlerFoundException;
import org.springframework.web.servlet.resource.NoResourceFoundException;

@ControllerAdvice
public class GlobalExceptionHandler {

    // Silently ignore favicon and other missing static resources
    @ExceptionHandler(NoResourceFoundException.class)
    @ResponseStatus(HttpStatus.NOT_FOUND)
    public void handleNoResource() {
        // intentionally empty — no logging, no error page
    }

    @ExceptionHandler(NoHandlerFoundException.class)
    public String handle404(Model model) {
        model.addAttribute("error", "Page not found (404)");
        model.addAttribute("timestamp", java.time.LocalDateTime.now());
        return "error";
    }

    @ExceptionHandler(Exception.class)
    public String handleException(Exception ex, Model model) {
        System.err.println("========== APPLICATION ERROR ==========");
        ex.printStackTrace();
        System.err.println("=======================================");
        model.addAttribute("error",
                ex.getClass().getSimpleName() + ": " + ex.getMessage());
        model.addAttribute("timestamp", java.time.LocalDateTime.now());
        return "error";
    }
}