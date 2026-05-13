package com.app.exception;

import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.servlet.NoHandlerFoundException;

@ControllerAdvice
public class GlobalExceptionHandler {

    @ExceptionHandler(NoHandlerFoundException.class)
    public String handle404(Model model) {
        model.addAttribute("error", "Page not found (404)");
        model.addAttribute("timestamp", java.time.LocalDateTime.now());
        return "error";
    }

    @ExceptionHandler(Exception.class)
    public String handleException(Exception ex, Model model) {

        // FULL ERROR IN CONSOLE
        System.err.println("========== APPLICATION ERROR ==========");
        ex.printStackTrace();
        System.err.println("=======================================");

        // SHOW REAL ERROR MESSAGE
        model.addAttribute("error",
                ex.getClass().getSimpleName() + ": " + ex.getMessage());

        model.addAttribute("timestamp",
                java.time.LocalDateTime.now());

        return "error";
    }
}