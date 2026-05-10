<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:set var="currentPage" value="dashboard"/>
<!DOCTYPE html>
<html>
<head>
    <title>Nexus — Dashboard</title>
    <link href="https://fonts.googleapis.com/css2?family=Space+Mono:wght@400;700&family=DM+Sans:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="/css/nexus.css">
    <style>
        .task-bar { display:flex; gap:4px; height:6px; border-radius:4px; overflow:hidden; margin-top:8px; }
        .task-bar-seg { height:100%; transition: width 0.5s ease; }
        .quick-actions { display:grid; grid-template-columns:repeat(4,1fr); gap:12px; margin-bottom:28px; }
        .quick-action-card {
            background:var(--bg2); border:1px solid var(--border); border-radius:12px;
            padding:16px; text-decoration:none; color:var(--text);
            display:flex; flex-direction:column; align-items:center; gap:8px;
            transition:all 0.2s; text-align:center;
        }
        .quick-action-card:hover { border-color:var(--accent); transform:translateY(-2px); box-shadow:0 8px 24px rgba(108,99,255,0.15); }
        .quick-action-icon { font-size:24px; }
        .quick-action-label { font-size:12px; font-weight:600; color:var(--text2); }
        .activity-dot { width:8px;height:8px;border-radius:50%;background:var(--accent);flex-shrink:0; margin-top:4px; }
        .pulse { animation: pulse 2s infinite; }
        @keyframes pulse { 0%,100%{opacity:1} 50%{opacity:0.4} }
    </style>
</head>
<body>

<%@ include file="sidebar.jsp" %>

<div class="main">
    <div class="topbar">
        <div>
            <div class="page-title">Good morning 👋</div>
            <div class="page-subtitle">Here's what's happening in your workspace today.</div>
        </div>
        <div class="topbar-actions">
            <a href="/files" class="btn btn-ghost">📎 Files</a>
            <a href="/projects" class="btn btn-primary">+ New Project</a>
        </div>
    </div>

    <!-- STATS -->
    <div class="stats-grid">
        <div class="stat-card purple">
            <div class="stat-label">ACTIVE PROJECTS</div>
            <div class="stat-value">${projects.size()}</div>
            <div class="stat-sub">Across workspace</div>
        </div>
        <div class="stat-card green">
            <div class="stat-label">TASKS DONE</div>
            <div class="stat-value">${tasksDone}</div>
            <div class="stat-sub">${tasksInProgress} in progress</div>
        </div>
        <div class="stat-card blue">
            <div class="stat-label">TEAM MEMBERS</div>
            <div class="stat-value">${members.size()}</div>
            <div class="stat-sub">All active</div>
        </div>
        <div class="stat-card red">
            <div class="stat-label">OVERDUE TASKS</div>
            <div class="stat-value">${tasksOverdue}</div>
            <div class="stat-sub">
                <c:choose>
                    <c:when test="${tasksOverdue > 0}">
                        <a href="/projects" style="color:var(--accent2);">Needs attention →</a>
                    </c:when>
                    <c:otherwise>All on track ✓</c:otherwise>
                </c:choose>
            </div>
        </div>
    </div>

    <!-- QUICK ACTIONS -->
    <div class="quick-actions">
        <a href="/projects" class="quick-action-card" onclick="document.querySelector('#newProjectTrigger') && document.querySelector('#newProjectTrigger').click()">
            <span class="quick-action-icon">🚀</span>
            <span class="quick-action-label">NEW PROJECT</span>
        </a>
        <a href="/notes" class="quick-action-card">
            <span class="quick-action-icon">📝</span>
            <span class="quick-action-label">NEW NOTE</span>
        </a>
        <a href="/workspace/invite" class="quick-action-card">
            <span class="quick-action-icon">✉️</span>
            <span class="quick-action-label">INVITE MEMBER</span>
        </a>
        <a href="/files" class="quick-action-card">
            <span class="quick-action-icon">📎</span>
            <span class="quick-action-label">UPLOAD FILE</span>
        </a>
    </div>

    <div class="grid-2" style="margin-bottom:20px;">
        <!-- RECENT PROJECTS -->
        <div class="card">
            <div class="card-header">
                <span class="card-title">Recent Projects</span>
                <a href="/projects" class="btn btn-ghost" style="font-size:12px;padding:6px 12px;">View All</a>
            </div>
            <c:choose>
                <c:when test="${empty projects}">
                    <div class="empty-state">
                        <div class="empty-icon">📁</div>
                        <p>No projects yet. <a href="/projects" style="color:var(--accent)">Create one</a></p>
                    </div>
                </c:when>
                <c:otherwise>
                    <c:forEach var="p" items="${projects}" varStatus="s">
                        <c:if test="${s.index < 5}">
                        <div style="display:flex;align-items:center;gap:14px;padding:12px 0;border-bottom:1px solid var(--border);">
                            <div style="width:40px;height:40px;border-radius:10px;background:rgba(108,99,255,0.15);display:flex;align-items:center;justify-content:center;font-size:18px;flex-shrink:0;">📁</div>
                            <div style="flex:1;min-width:0;">
                                <div style="font-weight:600;font-size:14px;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;">${p.name}</div>
                                <div style="font-size:11px;color:var(--text2);margin-top:2px;">ID #${p.id}</div>
                            </div>
                            <c:choose>
                                <c:when test="${p.status == 'COMPLETED'}"><span class="badge badge-green">Done</span></c:when>
                                <c:when test="${p.status == 'PAUSED'}"><span class="badge badge-gray">Paused</span></c:when>
                                <c:otherwise><span class="badge badge-purple">Active</span></c:otherwise>
                            </c:choose>
                            <a href="/projects/view/${p.id}" style="color:var(--text2);font-size:16px;text-decoration:none;margin-left:4px;">→</a>
                        </div>
                        </c:if>
                    </c:forEach>
                </c:otherwise>
            </c:choose>
        </div>

        <!-- TEAM MEMBERS -->
        <div class="card">
            <div class="card-header">
                <span class="card-title">Team Members</span>
                <a href="/workspace/invite" class="btn btn-ghost" style="font-size:12px;padding:6px 12px;">+ Invite</a>
            </div>
            <c:choose>
                <c:when test="${empty members}">
                    <div class="empty-state"><div class="empty-icon">👥</div><p>No members yet.</p></div>
                </c:when>
                <c:otherwise>
                    <c:forEach var="m" items="${members}" varStatus="s">
                        <c:if test="${s.index < 6}">
                        <div style="display:flex;align-items:center;gap:12px;padding:10px 0;border-bottom:1px solid var(--border);">
                            <div class="avatar">${m.username.substring(0,1).toUpperCase()}</div>
                            <div style="flex:1;">
                                <div style="font-size:13px;font-weight:600;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;max-width:180px;">${m.username}</div>
                                <div style="font-size:11px;color:var(--text2);">${m.role}</div>
                            </div>
                            <div style="width:8px;height:8px;border-radius:50%;background:var(--accent3);flex-shrink:0;"></div>
                        </div>
                        </c:if>
                    </c:forEach>
                </c:otherwise>
            </c:choose>
        </div>
    </div>

    <div class="grid-2">
        <!-- RECENT TASKS -->
        <div class="card">
            <div class="card-header">
                <span class="card-title">Recent Tasks</span>
                <span class="badge badge-gray">${tasksTodo + tasksInProgress} pending</span>
            </div>
            <c:choose>
                <c:when test="${empty recentTasks}">
                    <div class="empty-state" style="padding:30px 20px;">
                        <div class="empty-icon">✅</div>
                        <p>No tasks yet. Add tasks to your projects.</p>
                    </div>
                </c:when>
                <c:otherwise>
                    <c:forEach var="t" items="${recentTasks}">
                    <div style="display:flex;align-items:center;gap:12px;padding:10px 0;border-bottom:1px solid var(--border);">
                        <c:choose>
                            <c:when test="${t.status == 'DONE'}"><div style="width:20px;height:20px;border-radius:50%;background:rgba(67,233,123,0.2);display:flex;align-items:center;justify-content:center;font-size:10px;flex-shrink:0;">✓</div></c:when>
                            <c:when test="${t.status == 'OVERDUE'}"><div style="width:20px;height:20px;border-radius:50%;background:rgba(255,101,132,0.2);display:flex;align-items:center;justify-content:center;font-size:10px;flex-shrink:0;color:var(--accent2);">!</div></c:when>
                            <c:otherwise><div style="width:20px;height:20px;border-radius:50%;border:2px solid var(--border);flex-shrink:0;"></div></c:otherwise>
                        </c:choose>
                        <div style="flex:1;min-width:0;">
                            <div style="font-size:13px;font-weight:500;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;">${t.title}</div>
                            <div style="font-size:11px;color:var(--text2);">Project #${t.projectId}</div>
                        </div>
                        <c:choose>
                            <c:when test="${t.priority == 'HIGH' || t.priority == 'CRITICAL'}"><span class="badge badge-red" style="font-size:9px;">${t.priority}</span></c:when>
                            <c:when test="${t.priority == 'MEDIUM'}"><span class="badge badge-purple" style="font-size:9px;">MED</span></c:when>
                            <c:otherwise><span class="badge badge-gray" style="font-size:9px;">LOW</span></c:otherwise>
                        </c:choose>
                    </div>
                    </c:forEach>
                </c:otherwise>
            </c:choose>
        </div>

        <!-- ACTIVITY FEED -->
        <div class="card">
            <div class="card-header">
                <span class="card-title">Activity Feed</span>
                <span class="badge badge-green pulse">Live</span>
            </div>
            <div style="display:flex;flex-direction:column;max-height:280px;overflow-y:auto;">
                <c:choose>
                    <c:when test="${empty recentActivity}">
                        <div style="display:flex;gap:16px;padding:14px 0;align-items:flex-start;">
                            <div style="width:32px;height:32px;border-radius:50%;background:rgba(108,99,255,0.2);display:flex;align-items:center;justify-content:center;font-size:14px;flex-shrink:0;">🚀</div>
                            <div><div style="font-size:13px;font-weight:500;">Workspace created</div><div style="font-size:11px;color:var(--text2);">Just now</div></div>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <c:forEach var="a" items="${recentActivity}">
                        <div style="display:flex;gap:12px;padding:10px 0;border-bottom:1px solid var(--border);align-items:flex-start;">
                            <div style="width:30px;height:30px;border-radius:50%;background:rgba(108,99,255,0.15);display:flex;align-items:center;justify-content:center;font-size:13px;flex-shrink:0;">${a.actionEmoji}</div>
                            <div style="flex:1;min-width:0;">
                                <div style="font-size:12px;font-weight:500;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;">
                                    <span style="color:var(--accent)">${a.username}</span> · ${a.entityName}
                                </div>
                                <div style="font-size:11px;color:var(--text2);margin-top:1px;">${a.timeAgo}</div>
                            </div>
                        </div>
                        </c:forEach>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>
    </div>
</div>

</body>
</html>
