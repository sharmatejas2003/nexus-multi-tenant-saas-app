<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
    <title>Nexus — Create Account</title>
    <link href="https://fonts.googleapis.com/css2?family=Space+Mono:wght@400;700&family=DM+Sans:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <style>
        :root{--accent:#6c63ff;--accent2:#ff6584;--accent3:#43e97b;--bg:#0a0a0f;--bg2:#111118;--bg3:#1a1a24;--border:#2a2a3a;--text:#e8e8f0;--text2:#8888aa;}
        *{margin:0;padding:0;box-sizing:border-box;}
        body{background:var(--bg);color:var(--text);font-family:'DM Sans',sans-serif;min-height:100vh;display:flex;align-items:center;justify-content:center;padding:40px 20px;}
        body::before{content:'';position:fixed;inset:0;background:radial-gradient(ellipse at 20% 50%,rgba(108,99,255,0.1) 0%,transparent 60%);pointer-events:none;}
        .auth-box{width:480px;}
        .auth-logo{display:flex;align-items:center;gap:12px;margin-bottom:32px;}
        .logo-icon{width:44px;height:44px;background:var(--accent);border-radius:12px;display:flex;align-items:center;justify-content:center;font-family:'Space Mono',monospace;font-weight:700;font-size:20px;color:white;box-shadow:0 0 30px rgba(108,99,255,0.4);}
        .logo-text{font-family:'Space Mono',monospace;font-size:24px;font-weight:700;}
        h1{font-size:26px;font-weight:700;margin-bottom:6px;}
        .subtitle{color:var(--text2);font-size:14px;margin-bottom:24px;}
        .form-group{margin-bottom:14px;}
        .form-label{display:block;font-size:11px;font-weight:700;letter-spacing:1px;color:var(--text2);margin-bottom:7px;}
        .form-input,.form-select{width:100%;background:var(--bg2);border:1px solid var(--border);color:var(--text);padding:12px 16px;border-radius:10px;font-size:14px;font-family:'DM Sans',sans-serif;transition:all 0.2s;}
        .form-input:focus,.form-select:focus{outline:none;border-color:var(--accent);box-shadow:0 0 0 3px rgba(108,99,255,0.15);}
        .form-select option{background:var(--bg2);}
        .btn-submit{width:100%;padding:13px;background:var(--accent);color:white;border:none;border-radius:10px;font-size:15px;font-weight:600;cursor:pointer;margin-top:8px;transition:all 0.2s;}
        .btn-submit:hover{background:#5a52e0;box-shadow:0 0 24px rgba(108,99,255,0.4);}
        .auth-footer{text-align:center;margin-top:24px;font-size:13px;color:var(--text2);}
        .auth-footer a{color:var(--accent);text-decoration:none;font-weight:600;}
        .alert-error{background:rgba(255,101,132,0.1);border:1px solid rgba(255,101,132,0.3);color:#ff6584;padding:12px 14px;border-radius:8px;font-size:13px;margin-bottom:16px;}
        .alert-info{background:rgba(56,189,248,0.1);border:1px solid rgba(56,189,248,0.3);color:#38bdf8;padding:12px 14px;border-radius:8px;font-size:13px;margin-bottom:16px;}
        .invite-banner{background:rgba(108,99,255,0.1);border:1px solid rgba(108,99,255,0.3);border-radius:12px;padding:16px;margin-bottom:20px;display:flex;align-items:center;gap:12px;}
        .invite-banner .ws-icon{font-size:28px;}
        .invite-banner .ws-name{font-weight:700;color:var(--accent);}
        .mode-tabs{display:grid;grid-template-columns:1fr 1fr;gap:0;border:1px solid var(--border);border-radius:10px;overflow:hidden;margin-bottom:20px;}
        .mode-tab{padding:12px;text-align:center;cursor:pointer;font-size:13px;font-weight:600;color:var(--text2);background:var(--bg2);border:none;transition:all 0.2s;}
        .mode-tab.active{background:var(--accent);color:white;}
        .personal-features,.org-features{border:1px solid var(--border);border-radius:10px;padding:14px;margin-bottom:16px;font-size:12px;color:var(--text2);line-height:2;}
        .personal-features{border-color:rgba(67,233,123,0.3);background:rgba(67,233,123,0.05);}
        .org-features{border-color:rgba(108,99,255,0.3);background:rgba(108,99,255,0.05);}
    </style>
</head>
<body>
<div class="auth-box">
    <div class="auth-logo">
        <div class="logo-icon">N</div>
        <span class="logo-text">Nexus</span>
    </div>

    <c:choose>

        <%-- ── INVALID TOKEN ── --%>
        <c:when test="${not empty tokenError}">
            <div class="alert-error">❌ ${tokenError}</div>
            <h1>Invalid Invitation</h1>
            <div class="subtitle">This link may have expired or already been used.</div>
            <div class="auth-footer" style="margin-top:20px;"><a href="/login">← Back to Sign In</a></div>
        </c:when>

        <%-- ── INVITED TO JOIN WORKSPACE ── --%>
        <c:when test="${not empty invite}">
            <div class="invite-banner">
                <span class="ws-icon">✉️</span>
                <div>
                    <div style="font-size:13px;color:var(--text2);">You've been invited to join</div>
                    <span class="ws-name">${workspaceName}</span>
                    <div style="font-size:12px;color:var(--text2);margin-top:2px;">on Nexus — create an account or log in to accept</div>
                </div>
            </div>
            <h1>Join Workspace</h1>
            <div class="subtitle">Create your free account to get started</div>

            <c:if test="${param.error == 'invalid_token'}">
                <div class="alert-error">❌ Invalid or expired invitation token.</div>
            </c:if>

            <form method="post" action="/register">
                <input type="hidden" name="token" value="${token}">
                <input type="hidden" name="workspaceName" value="${workspaceName}">
                <input type="hidden" name="mode" value="MEMBER">

                <div class="form-group">
                    <label class="form-label">EMAIL ADDRESS</label>
                    <input type="email" name="username" class="form-input"
                           value="${invite.email}" placeholder="you@company.com" required autofocus>
                </div>
                <div class="form-group">
                    <label class="form-label">CHOOSE A PASSWORD</label>
                    <input type="password" name="password" class="form-input"
                           placeholder="Min 8 characters" required minlength="8">
                </div>

                <button type="submit" class="btn-submit">Accept & Join ${workspaceName} →</button>
            </form>

            <div class="auth-footer" style="margin-top:20px;">
                Already have an account? <a href="/login">Sign In</a>
                — your existing account will be linked automatically.
            </div>
            <div style="text-align:center;margin-top:14px;font-size:12px;color:var(--text2);">
    <a href="https://github.com/sharmatejas2003/nexus-multi-tenant-saas-app"
       target="_blank"
       style="color:var(--text2);text-decoration:none;display:inline-flex;align-items:center;gap:6px;">
        <span style="font-size:14px;">⭐</span> View Project on GitHub
    </a>
</div>
        </c:when>

        <%-- ── NEW ACCOUNT / NEW WORKSPACE ── --%>
        <c:otherwise>
            <h1>Create your account</h1>
            <div class="subtitle">Start your free workspace today — no credit card needed</div>

            <c:if test="${param.error == 'email_taken'}">
                <div class="alert-error">❌ This email is already registered. <a href="/login" style="color:var(--accent2);">Sign in instead →</a></div>
            </c:if>
            <c:if test="${param.error != null and param.error != 'email_taken'}">
                <div class="alert-error">❌ Something went wrong. Please try again.</div>
            </c:if>

            <%-- WORKSPACE TYPE TOGGLE --%>
            <div class="mode-tabs">
                <button type="button" class="mode-tab active" id="tabPersonal" onclick="selectMode('PERSONAL')">
                    🧑 Personal
                </button>
                <button type="button" class="mode-tab" id="tabOrg" onclick="selectMode('ORGANIZATION')">
                    🏢 Organization
                </button>
            </div>

            <div class="personal-features" id="featPersonal">
                ✅ Private notes &amp; tasks &nbsp;|&nbsp; ✅ Personal kanban &nbsp;|&nbsp; ✅ File vault &nbsp;|&nbsp;
                ✅ Up to 3 projects free
            </div>
            <div class="org-features" id="featOrg" style="display:none;">
                🚀 Team projects &nbsp;|&nbsp; 👥 Unlimited members &nbsp;|&nbsp; 🔔 Notifications &nbsp;|&nbsp;
                📊 Analytics &nbsp;|&nbsp; 🔑 Role management
            </div>

            <form method="post" action="/register" id="regForm">
                <input type="hidden" name="mode" id="modeInput" value="PERSONAL">

                <div class="form-group">
                    <label class="form-label">EMAIL ADDRESS</label>
                    <input type="email" name="username" class="form-input" placeholder="you@company.com" required autofocus>
                </div>
                <div class="form-group">
                    <label class="form-label">PASSWORD</label>
                    <input type="password" name="password" class="form-input" placeholder="Min 8 characters" required minlength="8">
                </div>
                <div class="form-group" id="wsNameGroup">
                    <label class="form-label" id="wsNameLabel">WORKSPACE NAME</label>
                    <input type="text" name="workspaceName" class="form-input"
                           id="wsNameInput" placeholder="e.g. My Projects" required>
                </div>

                <button type="submit" class="btn-submit" id="submitBtn">Create Personal Workspace →</button>
            </form>
        </c:otherwise>

    </c:choose>

    <div class="auth-footer">Already have an account? <a href="/login">Sign in</a></div>
</div>

<script>
function selectMode(mode) {
    document.getElementById('modeInput').value = mode;
    const isPersonal = (mode === 'PERSONAL');

    document.getElementById('tabPersonal').classList.toggle('active', isPersonal);
    document.getElementById('tabOrg').classList.toggle('active', !isPersonal);

    document.getElementById('featPersonal').style.display = isPersonal ? '' : 'none';
    document.getElementById('featOrg').style.display = isPersonal ? 'none' : '';

    document.getElementById('wsNameLabel').textContent = isPersonal ? 'WORKSPACE NAME' : 'ORGANIZATION NAME';
    document.getElementById('wsNameInput').placeholder = isPersonal ? 'e.g. My Projects' : 'e.g. Acme Corp';
    document.getElementById('submitBtn').textContent = isPersonal
        ? 'Create Personal Workspace →'
        : 'Create Organization Workspace →';
}
</script>
</body>
</html>
