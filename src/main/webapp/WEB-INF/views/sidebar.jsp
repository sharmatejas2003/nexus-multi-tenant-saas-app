<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<div class="sidebar" id="sidebar">
    <div class="sidebar-logo">
        <div class="logo-icon">N</div>
        <span class="logo-text">Nexus</span>
    </div>

    <div class="sidebar-section-label">MAIN</div>
    <a href="/dashboard" class="nav-item ${currentPage == 'dashboard' ? 'active' : ''}">
        <span class="nav-icon">📊</span> Dashboard
    </a>
    <a href="/projects" class="nav-item ${currentPage == 'projects' ? 'active' : ''}">
        <span class="nav-icon">📁</span> Projects
    </a>
    <a href="/analytics" class="nav-item ${currentPage == 'analytics' ? 'active' : ''}">
        <span class="nav-icon">📈</span> Analytics
    </a>
    <a href="/notes" class="nav-item ${currentPage == 'notes' ? 'active' : ''}">
        <span class="nav-icon">📝</span> Notes
    </a>
    <a href="/files" class="nav-item ${currentPage == 'files' ? 'active' : ''}">
        <span class="nav-icon">📎</span> Files
    </a>
    <a href="/notifications" class="nav-item ${currentPage == 'notifications' ? 'active' : ''}">
        <span class="nav-icon">🔔</span> Notifications
        <c:if test="${unreadNotifications > 0}">
            <span class="nav-badge">${unreadNotifications}</span>
        </c:if>
    </a>

    <div class="sidebar-section-label">WORKSPACE</div>
    <a href="/workspace/members" class="nav-item ${currentPage == 'members' ? 'active' : ''}">
        <span class="nav-icon">👥</span> Team Members
    </a>
    <a href="/workspace/invite" class="nav-item ${currentPage == 'invite' ? 'active' : ''}">
        <span class="nav-icon">✉️</span> Invite People
    </a>
    <a href="/workspace/settings" class="nav-item ${currentPage == 'settings' ? 'active' : ''}">
        <span class="nav-icon">⚙️</span> Settings
    </a>

    <div class="sidebar-bottom">
        <div class="user-pill">
            <c:choose>
                <c:when test="${not empty currentUser and not empty currentUser.avatarUrl}">
                    <img src="${currentUser.avatarUrl}" style="width:36px;height:36px;border-radius:50%;object-fit:cover;" alt="avatar">
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
                <div class="user-name" style="white-space:nowrap;overflow:hidden;text-overflow:ellipsis;max-width:130px;">
                    <c:choose>
                        <c:when test="${not empty pageContext.request.userPrincipal}">${pageContext.request.userPrincipal.name}</c:when>
                        <c:otherwise>User</c:otherwise>
                    </c:choose>
                </div>
                <div class="user-role">
                    <a href="/workspace/profile" style="color:var(--text2);text-decoration:none;font-size:11px;">View Profile</a>
                </div>
            </div>
        </div>
        <a href="/logout" class="logout-btn">↩ Logout</a>
    </div>
</div>
