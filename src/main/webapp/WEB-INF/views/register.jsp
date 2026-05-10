<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
    <title>Nexus — Create Account</title>
    <link href="https://fonts.googleapis.com/css2?family=Space+Mono:wght@400;700&family=DM+Sans:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <style>
        :root{--accent:#6c63ff;--accent2:#ff6584;--bg:#0a0a0f;--bg2:#111118;--border:#2a2a3a;--text:#e8e8f0;--text2:#8888aa;}
        *{margin:0;padding:0;box-sizing:border-box;}
        body{background:var(--bg);color:var(--text);font-family:'DM Sans',sans-serif;min-height:100vh;display:flex;align-items:center;justify-content:center;padding:40px 20px;}
        body::before{content:'';position:fixed;inset:0;background:radial-gradient(ellipse at 20% 50%,rgba(108,99,255,0.1) 0%,transparent 60%);pointer-events:none;}
        .auth-box{width:460px;}
        .auth-logo{display:flex;align-items:center;gap:12px;margin-bottom:32px;}
        .logo-icon{width:44px;height:44px;background:var(--accent);border-radius:12px;display:flex;align-items:center;justify-content:center;font-family:'Space Mono',monospace;font-weight:700;font-size:20px;color:white;box-shadow:0 0 30px rgba(108,99,255,0.4);}
        .logo-text{font-family:'Space Mono',monospace;font-size:24px;font-weight:700;}
        h1{font-size:28px;font-weight:700;margin-bottom:6px;}
        .subtitle{color:var(--text2);font-size:14px;margin-bottom:28px;}
        .form-group{margin-bottom:16px;}
        .form-label{display:block;font-size:11px;font-weight:700;letter-spacing:1px;color:var(--text2);margin-bottom:8px;}
        .form-input,.form-select{width:100%;background:#111118;border:1px solid var(--border);color:var(--text);padding:12px 16px;border-radius:10px;font-size:14px;font-family:'DM Sans',sans-serif;transition:all 0.2s;}
        .form-input:focus,.form-select:focus{outline:none;border-color:var(--accent);box-shadow:0 0 0 3px rgba(108,99,255,0.15);}
        .form-select option{background:#111118;}
        .btn-submit{width:100%;padding:13px;background:var(--accent);color:white;border:none;border-radius:10px;font-size:15px;font-weight:600;cursor:pointer;margin-top:8px;transition:all 0.2s;}
        .btn-submit:hover{background:#5a52e0;box-shadow:0 0 24px rgba(108,99,255,0.4);}
        .auth-footer{text-align:center;margin-top:24px;font-size:13px;color:var(--text2);}
        .auth-footer a{color:var(--accent);text-decoration:none;font-weight:600;}
        .alert-error{background:rgba(255,101,132,0.1);border:1px solid rgba(255,101,132,0.3);color:#ff6584;padding:12px 14px;border-radius:8px;font-size:13px;margin-bottom:16px;}
        .alert-info{background:rgba(56,189,248,0.1);border:1px solid rgba(56,189,248,0.3);color:#38bdf8;padding:12px 14px;border-radius:8px;font-size:13px;margin-bottom:16px;}
        .invite-banner{background:rgba(108,99,255,0.1);border:1px solid rgba(108,99,255,0.3);border-radius:10px;padding:16px;margin-bottom:20px;}
        .invite-banner .ws-name{font-weight:700;color:var(--accent);}
    </style>
</head>
<body>
<div class="auth-box">
    <div class="auth-logo">
        <div class="logo-icon">N</div>
        <span class="logo-text">Nexus</span>
    </div>

    <c:choose>
        <c:when test="${not empty tokenError}">
            <div class="alert-error">❌ ${tokenError}</div>
            <h1>Invalid Invitation</h1>
            <div class="subtitle">This link may have expired or already been used.</div>
            <div class="auth-footer" style="margin-top:20px;"><a href="/login">← Back to Sign In</a></div>
        </c:when>
        <c:when test="${not empty invite}">
            <div class="invite-banner">
                ✉️ You've been invited to join <span class="ws-name">${workspaceName}</span> on Nexus!
            </div>
            <h1>Join Workspace</h1>
            <div class="subtitle">Create your account to accept the invitation</div>
            <form method="post" action="/register">
                <input type="hidden" name="token" value="${token}">
                <input type="hidden" name="workspaceName" value="${workspaceName}">
                <input type="hidden" name="mode" value="MEMBER">
                <div class="form-group">
                    <label class="form-label">EMAIL ADDRESS</label>
                    <input type="email" name="username" class="form-input" value="${invite.email}" placeholder="you@company.com" required autofocus>
                </div>
                <div class="form-group">
                    <label class="form-label">PASSWORD</label>
                    <input type="password" name="password" class="form-input" placeholder="Min 8 characters" required minlength="8">
                </div>
                <button type="submit" class="btn-submit">Accept Invitation & Join →</button>
            </form>
        </c:when>
        <c:otherwise>
            <h1>Create your account</h1>
            <div class="subtitle">Start your workspace in seconds — free forever</div>
            <c:if test="${param.error != null}">
                <div class="alert-error">❌ Something went wrong. Please try again.</div>
            </c:if>
            <form method="post" action="/register">
                <div class="form-group">
                    <label class="form-label">EMAIL ADDRESS</label>
                    <input type="email" name="username" class="form-input" placeholder="you@company.com" required autofocus>
                </div>
                <div class="form-group">
                    <label class="form-label">PASSWORD</label>
                    <input type="password" name="password" class="form-input" placeholder="Min 8 characters" required minlength="8">
                </div>
                <div class="form-group">
                    <label class="form-label">WORKSPACE NAME</label>
                    <input type="text" name="workspaceName" class="form-input" placeholder="e.g. Acme Corp" required>
                </div>
                <div class="form-group">
                    <label class="form-label">ACCOUNT TYPE</label>
                    <select name="mode" class="form-select">
                        <option value="PERSONAL">Personal</option>
                        <option value="ORG">Organization</option>
                    </select>
                </div>
                <button type="submit" class="btn-submit">Create Workspace →</button>
            </form>
        </c:otherwise>
    </c:choose>

    <div class="auth-footer">Already have an account? <a href="/login">Sign in</a></div>
</div>
</body>
</html>
