<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:set var="currentPage" value="profile"/>
<!DOCTYPE html>
<html>
<head>
    <title>Nexus — Profile</title>
    <link href="https://fonts.googleapis.com/css2?family=Space+Mono:wght@400;700&family=DM+Sans:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="/css/nexus.css">
    <style>
        .profile-hero {
            display: flex; align-items: center; gap: 24px;
            background: var(--bg2); border: 1px solid var(--border);
            border-radius: 16px; padding: 28px; margin-bottom: 24px;
        }
        .profile-avatar-lg {
            width: 80px; height: 80px; border-radius: 50%;
            background: linear-gradient(135deg, var(--accent), var(--accent2));
            display: flex; align-items: center; justify-content: center;
            font-size: 32px; font-weight: 700; color: white; flex-shrink: 0;
            box-shadow: 0 0 30px rgba(108,99,255,0.35);
        }
        .profile-name { font-size: 22px; font-weight: 700; }
        .profile-email { font-size: 13px; color: var(--text2); margin-top: 4px; }
        .profile-role-badge { margin-top: 8px; display: inline-flex; }
    </style>
</head>
<body>
<%@ include file="sidebar.jsp" %>

<div class="main">
    <div class="topbar">
        <div>
            <div class="page-title">My Profile</div>
            <div class="page-subtitle">Manage your personal information and preferences.</div>
        </div>
    </div>

    <c:if test="${param.saved == 'true'}">
        <div class="alert alert-success" style="margin-bottom:20px;">✅ Profile updated successfully!</div>
    </c:if>

    <%-- Hero card --%>
    <div class="profile-hero">
        <c:choose>
            <c:when test="${not empty user.avatarUrl}">
                <img src="${user.avatarUrl}" style="width:80px;height:80px;border-radius:50%;object-fit:cover;box-shadow:0 0 30px rgba(108,99,255,0.3);" alt="avatar">
            </c:when>
            <c:otherwise>
                <div class="profile-avatar-lg">${user.getInitial()}</div>
            </c:otherwise>
        </c:choose>
        <div>
            <div class="profile-name">${user.username}</div>
            <div class="profile-email">
                Provider: <strong>${user.provider}</strong>
                <c:if test="${not empty tenant}"> &nbsp;·&nbsp; Workspace: <strong>${tenant.name}</strong></c:if>
            </div>
            <div class="profile-role-badge">
                <c:choose>
                    <c:when test="${user.role == 'OWNER'}"><span class="badge badge-red">OWNER</span></c:when>
                    <c:when test="${user.role == 'ADMIN'}"><span class="badge badge-purple">ADMIN</span></c:when>
                    <c:otherwise><span class="badge badge-gray">MEMBER</span></c:otherwise>
                </c:choose>
            </div>
        </div>
    </div>

    <div class="grid-2">
        <%-- Edit form --%>
        <div class="card">
            <div class="card-header">
                <span class="card-title">Edit Profile</span>
            </div>
            <form action="/workspace/profile/update" method="post">
                <div class="form-group">
                    <label class="form-label">BIO</label>
                    <textarea name="bio" class="form-textarea" rows="3"
                              placeholder="Tell your team a bit about yourself…"
                              style="resize:vertical;">${user.bio}</textarea>
                </div>
                <div class="form-group">
                    <label class="form-label">AVATAR URL</label>
                    <input type="url" name="avatarUrl" class="form-input"
                           placeholder="https://example.com/avatar.png"
                           value="${user.avatarUrl}">
                    <div style="font-size:11px;color:var(--text2);margin-top:5px;">Paste a public image URL to set your avatar.</div>
                </div>
                <button type="submit" class="btn btn-primary">Save Changes</button>
            </form>
        </div>

        <%-- Account info --%>
        <div class="card">
            <div class="card-header">
                <span class="card-title">Account Info</span>
            </div>
            <div style="display:flex;flex-direction:column;gap:16px;">
                <div>
                    <div class="form-label">EMAIL / USERNAME</div>
                    <div style="font-size:14px;font-weight:600;">${user.username}</div>
                </div>
                <div>
                    <div class="form-label">SIGN-IN METHOD</div>
                    <div style="display:flex;align-items:center;gap:8px;">
                        <c:choose>
                            <c:when test="${user.provider == 'GOOGLE'}">
                                <span style="font-size:18px;">🔵</span> <span style="font-size:14px;">Google OAuth</span>
                            </c:when>
                            <c:otherwise>
                                <span style="font-size:18px;">🔐</span> <span style="font-size:14px;">Email & Password</span>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>
                <div>
                    <div class="form-label">WORKSPACE ROLE</div>
                    <div style="font-size:14px;font-weight:600;">${user.role}</div>
                </div>
                <c:if test="${not empty tenant}">
                <div>
                    <div class="form-label">WORKSPACE</div>
                    <div style="font-size:14px;font-weight:600;">${tenant.name}</div>
                    <div style="font-size:11px;color:var(--text2);">nexus.app/${tenant.slug}</div>
                </div>
                </c:if>
                <div>
                    <div class="form-label">MEMBER ID</div>
                    <div style="font-size:13px;font-family:'Space Mono',monospace;color:var(--text2);">#${user.id}</div>
                </div>
            </div>
        </div>
    </div>

    <div style="margin-top:20px;">
        <a href="/workspace/settings" class="btn btn-ghost">⚙️ Workspace Settings</a>
    </div>
</div>
</body>
</html>
