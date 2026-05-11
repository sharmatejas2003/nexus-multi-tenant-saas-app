<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<div class="sidebar" id="sidebar">
    <div class="sidebar-logo">
        <div class="logo-icon">N</div>
        <span class="logo-text">Nexus</span>
    </div>

    <%-- WORKSPACE SWITCHER --%>
    <div style="padding:0 12px 12px; border-bottom:1px solid var(--border); margin-bottom:8px;">
        <div style="font-size:10px; font-weight:700; letter-spacing:1.5px; color:var(--text2); margin-bottom:6px; padding:0 8px;">
            WORKSPACE
        </div>

        <c:if test="${not empty tenant}">
            <div style="background:rgba(108,99,255,0.1); border:1px solid rgba(108,99,255,0.25); border-radius:8px; padding:8px 10px; margin-bottom:8px;">
                <div style="font-size:12px; font-weight:700; color:var(--text); white-space:nowrap; overflow:hidden; text-overflow:ellipsis;">
                    ${tenant.personal ? '🧑' : '🏢'} ${tenant.name}
                </div>
                <div style="font-size:10px; color:var(--accent); margin-top:2px;">
                    ${not empty currentRole ? currentRole : 'MEMBER'}
                </div>
            </div>
        </c:if>

        <c:if test="${not empty allWorkspaces}">
            <c:forEach var="ws" items="${allWorkspaces}">
                <c:if test="${!ws.active}">
                    <form action="/workspace/switch" method="post" style="margin-bottom:3px;">
                        <input type="hidden" name="workspaceId" value="${ws.id}">
                        <button type="submit" class="workspace-switch-btn">
                            ${ws.icon} ${ws.name}
                            <span style="font-size:9px; color:var(--text2); margin-left:4px;">${ws.role}</span>
                        </button>
                    </form>
                </c:if>
            </c:forEach>
        </c:if>

        <a href="/workspace/new" class="new-workspace-link">
            <span>+</span> New Workspace
        </a>
    </div>

    <%-- MAIN NAV --%>
    <div class="sidebar-section-label">MAIN</div>
    <a href="/dashboard" class="nav-item ${currentPage == 'dashboard' ? 'active' : ''}">
        <span class="nav-icon">📊</span> Dashboard
    </a>
    <a href="/projects" class="nav-item ${currentPage == 'projects' ? 'active' : ''}">
        <span class="nav-icon">📁</span> Projects
    </a>
    <c:if test="${isAdminOrOwner == true}">
        <a href="/analytics" class="nav-item ${currentPage == 'analytics' ? 'active' : ''}">
            <span class="nav-icon">📈</span> Analytics
        </a>
    </c:if>

    <%-- TOOLS --%>
    <div class="sidebar-section-label">TOOLS</div>
    <a href="/chat" class="nav-item ${currentPage == 'chat' ? 'active' : ''}">
        <span class="nav-icon">💬</span> Team Chat
    </a>
    <a href="/calendar" class="nav-item ${currentPage == 'calendar' ? 'active' : ''}">
        <span class="nav-icon">📅</span> Calendar
    </a>
    <a href="/time" class="nav-item ${currentPage == 'time' ? 'active' : ''}">
        <span class="nav-icon">⏱</span> Time Tracker
    </a>
    <a href="/notes" class="nav-item ${currentPage == 'notes' ? 'active' : ''}">
        <span class="nav-icon">📝</span> Notes
    </a>
    <a href="/files" class="nav-item ${currentPage == 'files' ? 'active' : ''}">
        <span class="nav-icon">📎</span> Files
    </a>
    
    <c:if test="${isAdminOrOwner == true}">
        <a href="/activity" class="nav-item ${currentPage == 'activity' ? 'active' : ''}" id="activity-log-btn">
            <span class="nav-icon">📋</span> Activity Log
        </a>
    </c:if>

    <a href="/notifications" class="nav-item ${currentPage == 'notifications' ? 'active' : ''}">
        <span class="nav-icon">🔔</span> Notifications
        <c:if test="${not empty unreadNotifications and unreadNotifications > 0}">
            <span class="nav-badge">${unreadNotifications}</span>
        </c:if>
    </a>

    <%-- WORKSPACE --%>
    <div class="sidebar-section-label">WORKSPACE</div>
    <a href="/workspace/members" class="nav-item ${currentPage == 'members' ? 'active' : ''}">
        <span class="nav-icon">👥</span> Members
    </a>
    <c:if test="${isAdminOrOwner == true}">
        <a href="/workspace/invite" class="nav-item ${currentPage == 'invite' ? 'active' : ''}">
            <span class="nav-icon">✉️</span> Invite People
        </a>
        <a href="/workspace/settings" class="nav-item ${currentPage == 'settings' ? 'active' : ''}">
            <span class="nav-icon">⚙️</span> Settings
        </a>
    </c:if>
    <a href="/workspace/profile" class="nav-item ${currentPage == 'profile' ? 'active' : ''}">
        <span class="nav-icon">👤</span> My Profile
    </a>

    <div class="sidebar-bottom">
        <div class="user-pill">
            <c:choose>
                <c:when test="${not empty currentUser and not empty currentUser.avatarUrl}">
                    <img src="${currentUser.avatarUrl}" class="user-avatar-img" alt="avatar">
                </c:when>
                <c:otherwise>
                    <div class="user-avatar">
                        <c:choose>
                            <c:when test="${not empty pageContext.request.userPrincipal}">
                                ${pageContext.request.userPrincipal.name.substring(0,1).toUpperCase()}
                            </c:when>
                            <c:otherwise>U</c:otherwise>
                        </c:choose>
                    </div>
                </c:otherwise>
            </c:choose>
            <div class="user-info">
                <div class="user-name">
                    <c:choose>
                        <c:when test="${not empty currentUser}">
                            ${currentUser.username.contains('@') ? currentUser.username.split('@')[0] : currentUser.username}
                        </c:when>
                        <c:when test="${not empty pageContext.request.userPrincipal}">
                            ${pageContext.request.userPrincipal.name}
                        </c:when>
                        <c:otherwise>User</c:otherwise>
                    </c:choose>
                </div>
                <div class="user-role">
                    ${not empty currentRole ? currentRole : 'MEMBER'}
                </div>
            </div>
        </div>
        <a href="/logout" class="logout-btn">↩ Logout</a>
    </div>
</div>