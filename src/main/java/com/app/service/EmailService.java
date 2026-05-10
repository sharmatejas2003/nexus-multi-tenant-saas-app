package com.app.service;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.stereotype.Service;

@Service
public class EmailService {
    private final JavaMailSender mailSender;

    @Value("${app.base-url:http://localhost:8080}")
    private String baseUrl;

    @Value("${spring.mail.username:no-reply@nexus.app}")
    private String fromEmail;

    public EmailService(JavaMailSender mailSender) {
        this.mailSender = mailSender;
    }

    public void sendInvitation(String toEmail, String token, String workspaceName, String invitedByName) {
        try {
            SimpleMailMessage msg = new SimpleMailMessage();
            msg.setFrom(fromEmail);
            msg.setTo(toEmail);
            msg.setSubject(invitedByName + " invited you to join " + workspaceName + " on Nexus");
            msg.setText(
                "Hi there!\n\n" +
                invitedByName + " has invited you to join the workspace \"" + workspaceName + "\" on Nexus.\n\n" +
                "Click the link below to accept the invitation and create your account:\n\n" +
                baseUrl + "/register?token=" + token + "\n\n" +
                "This invitation link expires in 7 days.\n\n" +
                "If you didn't expect this invitation, you can safely ignore this email.\n\n" +
                "— The Nexus Team"
            );
            mailSender.send(msg);
            System.out.println("[EmailService] Invitation sent to: " + toEmail);
        } catch (Exception e) {
            System.err.println("[EmailService] Failed to send email to " + toEmail + ": " + e.getMessage());
        }
    }

    public void sendTaskAssignedNotification(String toEmail, String taskTitle, String projectName, String assignedBy) {
        try {
            SimpleMailMessage msg = new SimpleMailMessage();
            msg.setFrom(fromEmail);
            msg.setTo(toEmail);
            msg.setSubject("Task assigned to you: " + taskTitle);
            msg.setText(
                "Hi!\n\n" +
                assignedBy + " assigned you a task in project \"" + projectName + "\":\n\n" +
                "Task: " + taskTitle + "\n\n" +
                "Log in to Nexus to view details: " + baseUrl + "/dashboard\n\n" +
                "— The Nexus Team"
            );
            mailSender.send(msg);
        } catch (Exception e) {
            System.err.println("[EmailService] Failed to send task notification: " + e.getMessage());
        }
    }
}