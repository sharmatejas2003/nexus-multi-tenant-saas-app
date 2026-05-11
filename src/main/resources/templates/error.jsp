<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Error - Nexus</title>
    <link href="https://fonts.googleapis.com/css2?family=Space+Mono:wght@400;700&family=DM+Sans:wght@300;400;500;600&display=swap" rel="stylesheet">
    <style>
        body { font-family: 'DM Sans', sans-serif; background: #0f0f12; color: #e0e0e0; text-align: center; padding: 50px; }
        .card { background: #1a1a1f; border: 1px solid #333; border-radius: 12px; max-width: 500px; margin: 40px auto; padding: 30px; }
        h1 { color: #ff6584; }
        .btn { background: #6c63ff; color: white; padding: 12px 24px; border-radius: 8px; text-decoration: none; display: inline-block; margin-top: 20px; }
    </style>
</head>
<body>
<div class="card">
    <h1>⚠️ Something went wrong</h1>
    <p>${error}</p>
    <p style="font-size:13px;color:#888;">${timestamp}</p>
    <a href="/dashboard" class="btn">← Back to Dashboard</a>
</div>
</body>
</html>