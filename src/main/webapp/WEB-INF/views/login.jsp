<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
    <title>Nexus — Sign In</title>

    <link href="https://fonts.googleapis.com/css2?family=Space+Mono:wght@400;700&family=DM+Sans:wght@300;400;500;600;700&display=swap" rel="stylesheet">

    <style>
        :root{
            --accent:#6c63ff;
            --accent2:#ff6584;
            --accent3:#43e97b;
            --bg:#0a0a0f;
            --bg2:#111118;
            --border:#2a2a3a;
            --text:#e8e8f0;
            --text2:#8888aa;
        }

        *{
            margin:0;
            padding:0;
            box-sizing:border-box;
        }

        body{
            background:var(--bg);
            color:var(--text);
            font-family:'DM Sans',sans-serif;
            min-height:100vh;
            display:flex;
            align-items:center;
            justify-content:center;
        }

        body::before{
            content:'';
            position:fixed;
            inset:0;
            background:
                radial-gradient(ellipse at 20% 50%,rgba(108,99,255,0.1) 0%,transparent 60%),
                radial-gradient(ellipse at 80% 20%,rgba(255,101,132,0.07) 0%,transparent 50%);
            pointer-events:none;
        }

        .auth-box{
            width:420px;
            padding:0 20px;
        }

        .auth-logo{
            display:flex;
            align-items:center;
            gap:12px;
            margin-bottom:40px;
        }

        .logo-icon{
            width:44px;
            height:44px;
            background:var(--accent);
            border-radius:12px;
            display:flex;
            align-items:center;
            justify-content:center;
            font-family:'Space Mono',monospace;
            font-weight:700;
            font-size:20px;
            color:white;
            box-shadow:0 0 30px rgba(108,99,255,0.4);
        }

        .logo-text{
            font-family:'Space Mono',monospace;
            font-size:24px;
            font-weight:700;
        }

        h1{
            font-size:28px;
            font-weight:700;
            margin-bottom:6px;
        }

        .subtitle{
            color:var(--text2);
            font-size:14px;
            margin-bottom:32px;
        }

        .form-group{
            margin-bottom:16px;
        }

        .form-label{
            display:block;
            font-size:11px;
            font-weight:700;
            letter-spacing:1px;
            color:var(--text2);
            margin-bottom:8px;
        }

        .form-input{
            width:100%;
            background:var(--bg2);
            border:1px solid var(--border);
            color:var(--text);
            padding:12px 16px;
            border-radius:10px;
            font-size:14px;
        }

        .form-input:focus{
            outline:none;
            border-color:var(--accent);
            box-shadow:0 0 0 3px rgba(108,99,255,0.15);
        }

        .btn-submit{
            width:100%;
            padding:13px;
            background:var(--accent);
            color:white;
            border:none;
            border-radius:10px;
            font-size:15px;
            font-weight:600;
            cursor:pointer;
            margin-top:8px;
        }

        .btn-submit:hover{
            background:#5a52e0;
        }

        .divider{
            display:flex;
            align-items:center;
            gap:12px;
            margin:20px 0;
            color:var(--text2);
            font-size:12px;
        }

        .divider::before,
        .divider::after{
            content:'';
            flex:1;
            height:1px;
            background:var(--border);
        }

        .btn-google{
            width:100%;
            padding:12px;
            background:var(--bg2);
            border:1px solid var(--border);
            color:var(--text);
            border-radius:10px;
            font-size:14px;
            text-decoration:none;
            display:flex;
            align-items:center;
            justify-content:center;
            gap:10px;
        }

        .btn-google:hover{
            border-color:var(--accent);
        }

        .auth-footer{
            text-align:center;
            margin-top:24px;
            font-size:13px;
            color:var(--text2);
        }

        .auth-footer a{
            color:var(--accent);
            text-decoration:none;
            font-weight:600;
        }

        .alert-error{
            background:rgba(255,101,132,0.1);
            border:1px solid rgba(255,101,132,0.3);
            color:#ff6584;
            padding:10px 14px;
            border-radius:8px;
            font-size:13px;
            margin-bottom:16px;
        }

        .alert-success{
            background:rgba(67,233,123,0.1);
            border:1px solid rgba(67,233,123,0.3);
            color:#43e97b;
            padding:10px 14px;
            border-radius:8px;
            font-size:13px;
            margin-bottom:16px;
        }

        .github-link{
            text-align:center;
            margin-top:14px;
            font-size:12px;
        }

        .github-link a{
            color:var(--text2);
            text-decoration:none;
        }

        .github-link a:hover{
            color:var(--accent);
        }
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

    <c:if test="${param.error != null}">
        <div class="alert-error">
            ❌ Invalid email or password. Please try again.
        </div>
    </c:if>

    <c:if test="${param.registered != null}">
        <div class="alert-success">
            ✅ Account created successfully! Please sign in.
        </div>
    </c:if>

    <form method="post" action="/perform_login">

        <div class="form-group">
            <label class="form-label">EMAIL</label>
            <input type="email"
                   name="username"
                   class="form-input"
                   placeholder="you@company.com"
                   required
                   autofocus>
        </div>

        <div class="form-group">
            <label class="form-label">PASSWORD</label>
            <input type="password"
                   name="password"
                   class="form-input"
                   placeholder="••••••••"
                   required>
        </div>

        <button type="submit" class="btn-submit">
            Sign In →
        </button>

    </form>

    <div class="divider">or continue with</div>

    <a href="/oauth2/authorization/google" class="btn-google">
        G Sign in with Google
    </a>

    <div class="auth-footer">
        Don't have an account?
        <a href="/register">Create one</a>
    </div>

    <div class="github-link">
        <a href="https://github.com/sharmatejas2003/nexus-multi-tenant-saas-app"
           target="_blank">
            ⭐ View Project on GitHub
        </a>
    </div>

</div>

</body>
</html>