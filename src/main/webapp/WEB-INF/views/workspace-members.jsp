<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:set var="currentPage" value="members"/>
<!DOCTYPE html>
<html>
<head>
    <title>Nexus — Team Members</title>
    <link href="https://fonts.googleapis.com/css2?family=Space+Mono:wght@400;700&family=DM+Sans:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="/css/nexus.css">
</head>
<body>

<%@ include file="sidebar.jsp" %>

<div class="main">
    <div class="topbar">
        <div>
            <div class="page-title">Team Members</div>
            <div class="page-subtitle">Manage roles and permissions for your workspace.</div>
        </div>
        <div class="topbar-actions">
            <a href="/workspace/invite" class="btn btn-primary">+ Invite Member</a>
        </div>
    </div>

    <div class="grid-3" style="margin-bottom:24px;">
        <div class="stat-card purple">
            <div class="stat-label">TOTAL MEMBERS</div>
            <div class="stat-value">${members.size()}</div>
        </div>
        <div class="stat-card green">
            <div class="stat-label">ACTIVE NOW</div>
            <div class="stat-value">${members.size()}</div>
        </div>
        <div class="stat-card blue">
            <div class="stat-label">ADMINS</div>
            <div class="stat-value">1</div>
        </div>
    </div>

    <div class="card" style="padding:0;overflow:hidden;">
        <div style="padding:20px 24px;border-bottom:1px solid var(--border);">
            <span class="card-title">All Members</span>
        </div>

        <c:choose>
            <c:when test="${empty members}">
                <div class="empty-state">
                    <div class="empty-icon">👥</div>
                    <p>No team members yet. <a href="/workspace/invite" style="color:var(--accent)">Invite someone</a></p>
                </div>
            </c:when>
            <c:otherwise>
                <table class="table">
                    <thead>
                        <tr>
                            <th>MEMBER</th>
                            <th>ROLE</th>
                            <th>STATUS</th>
                            <th>ACTIONS</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="m" items="${members}">
                        <tr>
                            <td>
                                <div style="display:flex;align-items:center;gap:12px;">
                                    <div class="avatar">${m.username.substring(0,1).toUpperCase()}</div>
                                    <div>
                                        <div style="font-weight:600;font-size:14px;">${m.username}</div>
                                        <div style="font-size:11px;color:var(--text2);">${m.bio != null ? m.bio : 'No bio added'}</div>
                                    </div>
                                </div>
                            </td>
                            <td>
                                <c:choose>
                                    <c:when test="${m.role == 'OWNER'}"><span class="badge badge-red">OWNER</span></c:when>
                                    <c:when test="${m.role == 'ADMIN'}"><span class="badge badge-purple">ADMIN</span></c:when>
                                    <c:otherwise><span class="badge badge-gray">MEMBER</span></c:otherwise>
                                </c:choose>
                            </td>
                            <td>
                                <div style="display:flex;align-items:center;gap:6px;">
                                    <div style="width:7px;height:7px;border-radius:50%;background:var(--accent3);"></div>
                                    <span style="font-size:12px;color:var(--text2);">Active</span>
                                </div>
                            </td>
                            <td>
                                <div style="display:flex;gap:8px;">
                                    <form action="/workspace/members/promote/${m.id}" method="post" style="display:inline;">
                                        <button class="btn btn-ghost" style="padding:6px 12px;font-size:12px;">Make Admin</button>
                                    </form>
                                    <form action="/workspace/members/ban/${m.id}" method="post" style="display:inline;" onsubmit="return confirm('Remove this member?')">
                                        <button class="btn btn-danger" style="padding:6px 12px;font-size:12px;">Remove</button>
                                    </form>
                                </div>
                            </td>
                        </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </c:otherwise>
        </c:choose>
    </div>
</div>

</body>
</html>
