<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
    <title>Nexus — Sign In</title>
    <link href="https://fonts.googleapis.com/css2?family=Space+Mono:wght@400;700&family=DM+Sans:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <style>
        :root{--accent:#6c63ff;--accent2:#ff6584;--bg:#0a0a0f;--bg2:#111118;--border:#2a2a3a;--text:#e8e8f0;--text2:#8888aa;}
        *{margin:0;padding:0;box-sizing:border-box;}
        body{background:var(--bg);color:var(--text);font-family:'DM Sans',sans-serif;min-height:100vh;display:flex;align-items:center;justify-content:center;}
        body::before{content:'';position:fixed;inset:0;background:radial-gradient(ellipse at 20% 50%,rgba(108,99,255,0.1) 0%,transparent 60%),radial-gradient(ellipse at 80% 20%,rgba(255,101,132,0.07) 0%,transparent 50%);pointer-events:none;}
        .auth-box{width:420px;padding:0 20px;}
        .auth-logo{display:flex;align-items:center;gap:12px;margin-bottom:40px;}
        .logo-icon{width:44px;height:44px;background:var(--accent);border-radius:12px;display:flex;align-items:center;justify-content:center;font-family:'Space Mono',monospace;font-weight:700;font-size:20px;color:white;box-shadow:0 0 30px rgba(108,99,255,0.4);}
        .logo-text{font-family:'Space Mono',monospace;font-size:24px;font-weight:700;}
        h1{font-size:28px;font-weight:700;margin-bottom:6px;}
        .subtitle{color:var(--text2);font-size:14px;margin-bottom:32px;}
        .form-group{margin-bottom:16px;}
        .form-label{display:block;font-size:11px;font-weight:700;letter-spacing:1px;color:var(--text2);margin-bottom:8px;}
        .form-input{width:100%;background:#111118;border:1px solid var(--border);color:var(--text);padding:12px 16px;border-radius:10px;font-size:14px;font-family:'DM Sans',sans-serif;transition:all 0.2s;}
        .form-input:focus{outline:none;border-color:var(--accent);box-shadow:0 0 0 3px rgba(108,99,255,0.15);}
        .btn-submit{width:100%;padding:13px;background:var(--accent);color:white;border:none;border-radius:10px;font-size:15px;font-weight:600;font-family:'DM Sans',sans-serif;cursor:pointer;margin-top:8px;transition:all 0.2s;}
        .btn-submit:hover{background:#5a52e0;box-shadow:0 0 24px rgba(108,99,255,0.4);}
        .divider{display:flex;align-items:center;gap:12px;margin:20px 0;color:var(--text2);font-size:12px;}
        .divider::before,.divider::after{content:'';flex:1;height:1px;background:var(--border);}
        .btn-google{width:100%;padding:12px;background:#111118;border:1px solid var(--border);color:var(--text);border-radius:10px;font-size:14px;font-weight:500;font-family:'DM Sans',sans-serif;cursor:pointer;display:flex;align-items:center;justify-content:center;gap:10px;text-decoration:none;transition:all 0.2s;}
        .btn-google:hover{border-color:var(--accent);color:var(--accent);}
        .auth-footer{text-align:center;margin-top:24px;font-size:13px;color:var(--text2);}
        .auth-footer a{color:var(--accent);text-decoration:none;font-weight:600;}
        .alert-error{background:rgba(255,101,132,0.1);border:1px solid rgba(255,101,132,0.3);color:#ff6584;padding:10px 14px;border-radius:8px;font-size:13px;margin-bottom:16px;}
        .alert-success{background:rgba(67,233,123,0.1);border:1px solid rgba(67,233,123,0.3);color:#43e97b;padding:10px 14px;border-radius:8px;font-size:13px;margin-bottom:16px;}
    </style>
</head>
<body>
<div class="auth-box">
    <div class="auth-logo">
        <div class="logo-icon">N</div>
        <span class="logo-text">Nexus</span>
    </div>
    <h1>Welcome back</h1>
    <div class="subtitle">Sign in to your workspace</div>

    <c:if test="${param.error != null}"><div class="alert-error">❌ Invalid email or password. Please try again.</div></c:if>
    <c:if test="${param.registered != null}"><div class="alert-success">✅ Account created! Please sign in.</div></c:if>
    <c:if test="${param.deleted != null}"><div class="alert-success">✅ Workspace deleted successfully.</div></c:if>

    <form method="post" action="/perform_login">
        <div class="form-group">
            <label class="form-label">EMAIL</label>
            <input type="email" name="username" class="form-input" placeholder="you@company.com" required autofocus>
        </div>
        <div class="form-group">
            <label class="form-label">PASSWORD</label>
            <input type="password" name="password" class="form-input" placeholder="••••••••" required>
        </div>
        <button type="submit" class="btn-submit">Sign In →</button>
    </form>

    <div class="divider">or continue with</div>

    <a href="/oauth2/authorization/google" class="btn-google">
        <svg width="18" height="18" viewBox="0 0 24 24"><path fill="#4285F4" d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z"/><path fill="#34A853" d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z"/><path fill="#FBBC05" d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.07H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.93l2.85-2.22.81-.62z"/><path fill="#EA4335" d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.07l3.66 2.84c.87-2.6 3.3-4.53 6.16-4.53z"/></svg>
        Sign in with Google
    </a>

    <div class="auth-footer">Don't have an account? <a href="/register">Create one</a></div>
</div>
</body>
</html>
