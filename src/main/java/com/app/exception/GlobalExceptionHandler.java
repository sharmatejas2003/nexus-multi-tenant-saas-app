package com.app.exception;

import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.servlet.NoHandlerFoundException;

@ControllerAdvice
public class GlobalExceptionHandler {

    @ExceptionHandler(Exception.class)
    public String handleException(Exception ex, Model model) {
        ex.printStackTrace();
        model.addAttribute("error", ex.getMessage() != null ? ex.getMessage() : "Internal Server Error");
        model.addAttribute("timestamp", java.time.LocalDateTime.now());
        return "error";
    }

    @ExceptionHandler(NoHandlerFoundException.class)
    public String handle404(Model model) {
        model.addAttribute("error", "Page not found (404)");
        return "error";
    }
}