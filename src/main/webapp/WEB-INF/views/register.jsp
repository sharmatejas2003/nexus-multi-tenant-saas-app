<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
    <title>Nexus — Create Account</title>
    <link href="https://fonts.googleapis.com/css2?family=Space+Mono:wght@400;700&family=DM+Sans:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.2/css/all.min.css">
    <style>
        :root {
            --accent: #6c63ff;
            --accent2: #ff6584;
            --accent3: #43e97b;
            --bg: #0a0a0f;
            --bg2: #111118;
            --bg3: #1a1a24;
            --border: #2a2a3a;
            --text: #e8e8f0;
            --text2: #8888aa;
        }

        * { margin: 0; padding: 0; box-sizing: border-box; }

        body {
            background: var(--bg);
            color: var(--text);
            font-family: 'DM Sans', sans-serif;
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 40px 20px;
        }

        body::before {
            content: '';
            position: fixed;
            inset: 0;
            background: radial-gradient(ellipse at 20% 50%, rgba(108,99,255,0.10) 0%, transparent 60%);
            pointer-events: none;
        }

        .auth-box {
            width: 480px;
            position: relative;
            z-index: 1;
        }

        .auth-logo {
            display: flex;
            align-items: center;
            gap: 12px;
            margin-bottom: 36px;
        }

        .logo-icon {
            width: 44px;
            height: 44px;
            background: var(--accent);
            border-radius: 12px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-family: 'Space Mono', monospace;
            font-weight: 700;
            font-size: 20px;
            color: white;
            box-shadow: 0 0 30px rgba(108,99,255,0.35);
        }

        .logo-text {
            font-family: 'Space Mono', monospace;
            font-size: 24px;
            font-weight: 700;
        }

        h1 { font-size: 26px; font-weight: 700; margin-bottom: 6px; }

        .subtitle { color: var(--text2); font-size: 14px; margin-bottom: 28px; }

        /* Mode tabs */
        .mode-tabs {
            display: grid;
            grid-template-columns: 1fr 1fr;
            border: 1px solid var(--border);
            border-radius: 10px;
            overflow: hidden;
            margin-bottom: 22px;
        }

        .mode-tab {
            padding: 13px;
            text-align: center;
            cursor: pointer;
            font-size: 13px;
            font-weight: 600;
            color: var(--text2);
            background: var(--bg2);
            border: none;
            transition: all 0.2s;
            font-family: 'DM Sans', sans-serif;
        }

        .mode-tab.active {
            background: var(--accent);
            color: white;
        }

        /* Invite banner */
        .invite-banner {
            background: rgba(67,233,123,0.1);
            border: 1px solid rgba(67,233,123,0.3);
            border-radius: 10px;
            padding: 14px 16px;
            margin-bottom: 22px;
            font-size: 13px;
        }

        .invite-banner strong { color: #43e97b; }

        /* Form elements */
        .form-group { margin-bottom: 16px; }

        .form-label {
            display: block;
            font-size: 10px;
            font-weight: 700;
            letter-spacing: 1.5px;
            color: var(--text2);
            margin-bottom: 8px;
        }

        .form-input {
            width: 100%;
            background: var(--bg2);
            border: 1px solid var(--border);
            color: var(--text);
            padding: 13px 16px;
            border-radius: 12px;
            font-size: 14px;
            font-family: 'DM Sans', sans-serif;
            transition: all 0.2s;
        }

        .form-input:focus {
            outline: none;
            border-color: var(--accent);
            box-shadow: 0 0 0 4px rgba(108,99,255,0.15);
        }

        .btn-submit {
            width: 100%;
            padding: 14px;
            background: var(--accent);
            color: white;
            border: none;
            border-radius: 12px;
            font-size: 15px;
            font-weight: 600;
            cursor: pointer;
            margin-top: 6px;
            transition: all 0.2s;
            font-family: 'DM Sans', sans-serif;
        }

        .btn-submit:hover {
            background: #5b54eb;
            transform: translateY(-1px);
            box-shadow: 0 10px 24px rgba(108,99,255,0.30);
        }

        .divider {
            display: flex;
            align-items: center;
            gap: 12px;
            margin: 22px 0;
            color: var(--text2);
            font-size: 12px;
        }

        .divider::before, .divider::after {
            content: '';
            flex: 1;
            height: 1px;
            background: var(--border);
        }

        .btn-google {
            width: 100%;
            padding: 13px;
            background: var(--bg2);
            border: 1px solid var(--border);
            color: var(--text);
            border-radius: 12px;
            font-size: 14px;
            text-decoration: none;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 10px;
            transition: all 0.2s;
            font-family: 'DM Sans', sans-serif;
            cursor: pointer;
        }

        .btn-google:hover {
            border-color: var(--accent);
            transform: translateY(-1px);
        }

        .google-circle {
            width: 28px;
            height: 28px;
            border-radius: 50%;
            background: white;
            display: flex;
            align-items: center;
            justify-content: center;
        }

        .google-circle i { color: #4285F4; font-size: 14px; }

        .auth-footer {
            text-align: center;
            margin-top: 22px;
            font-size: 13px;
            color: var(--text2);
        }

        .auth-footer a {
            color: var(--accent);
            text-decoration: none;
            font-weight: 600;
        }

        .auth-footer a:hover { text-decoration: underline; }

        .alert-error {
            background: rgba(255,101,132,0.1);
            border: 1px solid rgba(255,101,132,0.3);
            color: #ff6584;
            padding: 12px 14px;
            border-radius: 10px;
            margin-bottom: 18px;
            font-size: 13px;
        }

        .alert-success {
            background: rgba(67,233,123,0.1);
            border: 1px solid rgba(67,233,123,0.3);
            color: #43e97b;
            padding: 12px 14px;
            border-radius: 10px;
            margin-bottom: 18px;
            font-size: 13px;
        }

        /* Workspace name field (hidden for invite-join flow) */
        #workspaceSection { transition: all 0.2s; }

        .made-by {
            text-align: center;
            margin-top: 14px;
            color: var(--text2);
            font-size: 12px;
        }

        .made-by strong { color: var(--text); }
    </style>
</head>
<body>

<div class="auth-box">

    <div class="auth-logo">
        <div class="logo-icon">N</div>
        <span class="logo-text">Nexus</span>
    </div>

    <c:choose>
        <%-- ── INVITE FLOW ── --%>
        <c:when test="${not empty invite}">
            <h1>Join Workspace</h1>
            <div class="subtitle">You've been invited to join a workspace.</div>

            <c:if test="${not empty tokenError}">
                <div class="alert-error">❌ ${tokenError}</div>
            </c:if>

            <c:if test="${empty tokenError}">
                <div class="invite-banner">
                    🎉 You're joining <strong>${workspaceName}</strong>
                </div>

                <c:if test="${param.error == 'email_taken'}">
                    <div class="alert-error">❌ That email is already registered. Try logging in instead.</div>
                </c:if>

                <form method="post" action="/register">
                    <input type="hidden" name="token" value="${token}">

                    <div class="form-group">
                        <label class="form-label">EMAIL</label>
                        <input type="email" name="username" class="form-input"
                               placeholder="you@example.com"
                               value="${invite.email}"
                               required autofocus>
                    </div>

                    <div class="form-group">
                        <label class="form-label">PASSWORD</label>
                        <input type="password" name="password" class="form-input"
                               placeholder="Create a password (min 6 chars)"
                               required minlength="6">
                    </div>

                    <button type="submit" class="btn-submit">Join Workspace →</button>
                </form>

                <div class="auth-footer">
                    Already have an account? <a href="/login">Sign in</a>
                </div>
            </c:if>
        </c:when>

        <%-- ── NORMAL REGISTRATION FLOW ── --%>
        <c:otherwise>
            <h1>Create Account</h1>
            <div class="subtitle">Start your free workspace today.</div>

            <c:if test="${param.error == 'email_taken'}">
                <div class="alert-error">❌ That email is already registered. <a href="/login" style="color:var(--accent2);">Sign in instead →</a></div>
            </c:if>
            <c:if test="${param.error == 'true'}">
                <div class="alert-error">❌ Something went wrong. Please try again.</div>
            </c:if>
            <c:if test="${param.error == 'invalid_token'}">
                <div class="alert-error">❌ Your invite link is invalid or has expired.</div>
            </c:if>

            <%-- Workspace type tabs (hidden when joining via invite) --%>
            <div class="mode-tabs" id="modeTabs">
                <button type="button" class="mode-tab active" id="tabPersonal" onclick="selectMode('PERSONAL')">
                    🧑 Personal
                </button>
                <button type="button" class="mode-tab" id="tabOrg" onclick="selectMode('ORGANIZATION')">
                    🏢 Organization
                </button>
            </div>

            <form method="post" action="/register" id="registerForm">
                <input type="hidden" name="mode" id="modeInput" value="PERSONAL">

                <div class="form-group">
                    <label class="form-label">EMAIL</label>
                    <input type="email" name="username" class="form-input"
                           placeholder="you@example.com" required autofocus>
                </div>

                <div class="form-group">
                    <label class="form-label">PASSWORD</label>
                    <input type="password" name="password" class="form-input"
                           placeholder="Create a password (min 6 chars)" required minlength="6">
                </div>

                <div class="form-group" id="workspaceSection">
                    <label class="form-label" id="wsLabel">WORKSPACE NAME <span style="color:var(--text2);font-weight:400;">(optional)</span></label>
                    <input type="text" name="workspaceName" id="wsNameInput" class="form-input"
                           placeholder="e.g. My Projects">
                </div>

                <button type="submit" class="btn-submit" id="submitBtn">
                    Create Account →
                </button>
            </form>

            <div class="divider">or continue with</div>

            <a href="/oauth2/authorization/google" class="btn-google">
                <div class="google-circle">
                    <i class="fa-brands fa-google"></i>
                </div>
                Sign up with Google
            </a>

            <div class="auth-footer">
                Already have an account? <a href="/login">Sign in</a>
            </div>

            <div class="made-by">
                Made by <strong>Tejas Sharma</strong>
            </div>
        </c:otherwise>
    </c:choose>

</div>

<script>
function selectMode(mode) {
    var isPersonal = mode === 'PERSONAL';
    document.getElementById('modeInput').value = mode;
    document.getElementById('tabPersonal').classList.toggle('active', isPersonal);
    document.getElementById('tabOrg').classList.toggle('active', !isPersonal);
    document.getElementById('wsLabel').textContent = isPersonal
        ? 'WORKSPACE NAME (optional)'
        : 'ORGANIZATION NAME';
    document.getElementById('wsNameInput').placeholder = isPersonal
        ? 'e.g. My Projects'
        : 'e.g. Acme Corp';
    document.getElementById('submitBtn').textContent = isPersonal
        ? 'Create Personal Account →'
        : 'Create Organization Account →';
}
</script>

</body>
</html>
