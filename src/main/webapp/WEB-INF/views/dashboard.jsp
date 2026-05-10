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
        .quick-actions{display:grid;grid-template-columns:repeat(4,1fr);gap:12px;margin-bottom:28px;}
        .quick-action-card{background:var(--bg2);border:1px solid var(--border);border-radius:12px;padding:16px;text-decoration:none;color:var(--text);display:flex;flex-direction:column;align-items:center;gap:8px;transition:all 0.2s;text-align:center;}
        .quick-action-card:hover{border-color:var(--accent);transform:translateY(-2px);box-shadow:0 8px 24px rgba(108,99,255,0.15);}
        .quick-action-icon{font-size:24px;}
        .quick-action-label{font-size:12px;font-weight:600;color:var(--text2);}
        .notif-bell{position:relative;}
        .notif-dot{position:absolute;top:-2px;right:-2px;width:8px;height:8px;background:var(--accent2);border-radius:50%;border:2px solid var(--bg);}
        .ws-type-banner{display:flex;align-items:center;gap:12px;background:var(--bg2);border:1px solid var(--border);border-radius:12px;padding:14px 20px;margin-bottom:24px;}
        .ws-type-icon{font-size:28px;}
        .ws-type-label{font-size:11px;font-weight:700;letter-spacing:1px;color:var(--text2);}
        .ws-type-name{font-size:15px;font-weight:700;color:var(--text);}
        .ws-type-badge{margin-left:auto;padding:4px 12px;border-radius:20px;font-size:11px;font-weight:700;}
        .personal-badge{background:rgba(67,233,123,0.15);color:#43e97b;}
        .org-badge{background:rgba(108,99,255,0.15);color:#6c63ff;}
    </style>
</head>
<body>
<%@ include file="sidebar.jsp" %>
<div class="main">
    <div class="topbar">
        <div>
            <div class="page-title">Good day 👋</div>
            <div class="page-subtitle">Here's what's happening in your workspace today.</div>
        </div>
        <div class="topbar-actions">
            <a href="/notifications" class="btn btn-ghost notif-bell">
                🔔
                <c:if test="${unreadNotifications > 0}"><span class="notif-dot"></span></c:if>
            </a>
            <a href="/projects" class="btn btn-primary">+ New Project</a>
        </div>
    </div>

    <%-- ── WORKSPACE TYPE BANNER ── --%>
    <c:if test="${not empty tenant}">
    <div class="ws-type-banner">
        <span class="ws-type-icon">${tenant.personal ? '🧑' : '🏢'}</span>
        <div>
            <div class="ws-type-label">${tenant.personal ? 'PERSONAL WORKSPACE' : 'ORGANIZATION WORKSPACE'}</div>
            <div class="ws-type-name">${tenant.name}</div>
        </div>
        <c:choose>
            <c:when test="${tenant.personal}">
                <span class="ws-type-badge personal-badge">Personal</span>
            </c:when>
            <c:otherwise>
                <span class="ws-type-badge org-badge">Organization</span>
            </c:otherwise>
        </c:choose>
    </div>
    </c:if>

    <%-- ── STATS GRID ── --%>
    <div class="stats-grid">
        <div class="stat-card purple">
            <div class="stat-label">ACTIVE PROJECTS</div>
            <div class="stat-value">${projects.size()}</div>
            <div class="stat-sub">In your workspace</div>
        </div>
        <div class="stat-card green">
            <div class="stat-label">TASKS DONE</div>
            <div class="stat-value">${tasksDone}</div>
            <div class="stat-sub">${tasksInProgress} in progress</div>
        </div>
        <c:choose>
            <c:when test="${not empty tenant and tenant.personal}">
                <%-- Personal: show Files instead of Team Members --%>
                <div class="stat-card blue">
                    <div class="stat-label">FILES STORED</div>
                    <div class="stat-value">${totalFiles}</div>
                    <div class="stat-sub"><a href="/files" style="color:var(--accent4)">View all →</a></div>
                </div>
            </c:when>
            <c:otherwise>
                <div class="stat-card blue">
                    <div class="stat-label">TEAM MEMBERS</div>
                    <div class="stat-value">${members.size()}</div>
                    <div class="stat-sub"><a href="/workspace/invite" style="color:var(--accent4)">+ Invite →</a></div>
                </div>
            </c:otherwise>
        </c:choose>
        <div class="stat-card red">
            <div class="stat-label">OVERDUE TASKS</div>
            <div class="stat-value">${tasksOverdue}</div>
            <div class="stat-sub">
                <c:choose>
                    <c:when test="${tasksOverdue > 0}"><a href="/projects" style="color:var(--accent2)">Needs attention →</a></c:when>
                    <c:otherwise>All on track ✓</c:otherwise>
                </c:choose>
            </div>
        </div>
    </div>

    <%-- ── QUICK ACTIONS (differ by workspace type) ── --%>
    <c:choose>
        <c:when test="${not empty tenant and tenant.personal}">
            <%-- PERSONAL quick actions --%>
            <div class="quick-actions">
                <a href="/projects" class="quick-action-card">
                    <span class="quick-action-icon">✅</span>
                    <span class="quick-action-label">MY TASKS</span>
                </a>
                <a href="/notes" class="quick-action-card">
                    <span class="quick-action-icon">📝</span>
                    <span class="quick-action-label">MY NOTES</span>
                </a>
                <a href="/files" class="quick-action-card">
                    <span class="quick-action-icon">📁</span>
                    <span class="quick-action-label">MY FILES</span>
                </a>
                <a href="/analytics" class="quick-action-card">
                    <span class="quick-action-icon">📈</span>
                    <span class="quick-action-label">MY STATS</span>
                </a>
            </div>
        </c:when>
        <c:otherwise>
            <%-- ORGANIZATION quick actions --%>
            <div class="quick-actions">
                <a href="/projects" class="quick-action-card">
                    <span class="quick-action-icon">🚀</span>
                    <span class="quick-action-label">NEW PROJECT</span>
                </a>
                <a href="/notes" class="quick-action-card">
                    <span class="quick-action-icon">📝</span>
                    <span class="quick-action-label">TEAM NOTES</span>
                </a>
                <a href="/workspace/invite" class="quick-action-card">
                    <span class="quick-action-icon">✉️</span>
                    <span class="quick-action-label">INVITE MEMBER</span>
                </a>
                <a href="/analytics" class="quick-action-card">
                    <span class="quick-action-icon">📈</span>
                    <span class="quick-action-label">ANALYTICS</span>
                </a>
            </div>
        </c:otherwise>
    </c:choose>

    <div class="grid-2" style="margin-bottom:20px;">
        <%-- RECENT PROJECTS --%>
        <div class="card">
            <div class="card-header">
                <span class="card-title">
                    ${not empty tenant and tenant.personal ? 'My Projects' : 'Team Projects'}
                </span>
                <a href="/projects" class="btn btn-ghost btn-sm">View All →</a>
            </div>
            <c:choose>
                <c:when test="${empty projects}">
                    <div class="empty-state" style="padding:30px 20px;">
                        <div class="empty-icon">📁</div>
                        <p>No projects yet. <a href="/projects" style="color:var(--accent)">Create one →</a></p>
                    </div>
                </c:when>
                <c:otherwise>
                    <c:forEach var="p" items="${projects}" varStatus="s">
                        <c:if test="${s.index < 5}">
                        <div style="display:flex;align-items:center;gap:12px;padding:10px 0;border-bottom:1px solid var(--border);">
                            <div style="width:38px;height:38px;border-radius:10px;background:rgba(108,99,255,0.15);display:flex;align-items:center;justify-content:center;font-size:16px;flex-shrink:0;">📁</div>
                            <div style="flex:1;min-width:0;">
                                <div style="font-weight:600;font-size:14px;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;">${p.name}</div>
                                <div style="font-size:11px;color:var(--text2);">#${p.id} · ${p.status}</div>
                            </div>
                            <c:choose>
                                <c:when test="${p.status=='COMPLETED'}"><span class="badge badge-green">Done</span></c:when>
                                <c:when test="${p.status=='PAUSED'}"><span class="badge badge-gray">Paused</span></c:when>
                                <c:otherwise><span class="badge badge-purple">Active</span></c:otherwise>
                            </c:choose>
                            <a href="/projects/view/${p.id}" style="color:var(--text2);text-decoration:none;margin-left:4px;">→</a>
                        </div>
                        </c:if>
                    </c:forEach>
                </c:otherwise>
            </c:choose>
        </div>

        <%-- Right column: Team Members for Org, Recent Notes for Personal --%>
        <c:choose>
            <c:when test="${not empty tenant and tenant.personal}">
                <%-- PERSONAL: show recent notes --%>
                <div class="card">
                    <div class="card-header">
                        <span class="card-title">Recent Notes</span>
                        <a href="/notes" class="btn btn-ghost btn-sm">+ New Note</a>
                    </div>
                    <div class="empty-state" style="padding:30px 20px;">
                        <div class="empty-icon">📝</div>
                        <p>Your personal notes will appear here. <a href="/notes" style="color:var(--accent)">Add one →</a></p>
                    </div>
                </div>
            </c:when>
            <c:otherwise>
                <%-- ORGANIZATION: show team members --%>
                <div class="card">
                    <div class="card-header">
                        <span class="card-title">Team Members</span>
                        <a href="/workspace/invite" class="btn btn-ghost btn-sm">+ Invite</a>
                    </div>
                    <c:choose>
                        <c:when test="${empty members}">
                            <div class="empty-state" style="padding:30px 20px;">
                                <div class="empty-icon">👥</div>
                                <p>No members yet. <a href="/workspace/invite" style="color:var(--accent)">Invite someone →</a></p>
                            </div>
                        </c:when>
                        <c:otherwise>
                            <c:forEach var="m" items="${members}" varStatus="s">
                                <c:if test="${s.index < 6}">
                                <div style="display:flex;align-items:center;gap:12px;padding:9px 0;border-bottom:1px solid var(--border);">
                                    <div class="avatar">${m.username.substring(0,1).toUpperCase()}</div>
                                    <div style="flex:1;">
                                        <div style="font-size:13px;font-weight:600;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;max-width:160px;">${m.username}</div>
                                        <div style="font-size:11px;color:var(--text2);">${m.role}</div>
                                    </div>
                                    <div style="width:7px;height:7px;border-radius:50%;background:var(--accent3);flex-shrink:0;"></div>
                                </div>
                                </c:if>
                            </c:forEach>
                        </c:otherwise>
                    </c:choose>
                </div>
            </c:otherwise>
        </c:choose>
    </div>

    <div class="grid-2">
        <%-- RECENT TASKS --%>
        <div class="card">
            <div class="card-header">
                <span class="card-title">${not empty tenant and tenant.personal ? 'My Tasks' : 'Recent Tasks'}</span>
                <span class="badge badge-gray">${tasksTodo + tasksInProgress} pending</span>
            </div>
            <c:choose>
                <c:when test="${empty recentTasks}">
                    <div class="empty-state" style="padding:30px 20px;"><div class="empty-icon">✅</div><p>No tasks yet.</p></div>
                </c:when>
                <c:otherwise>
                    <c:forEach var="t" items="${recentTasks}">
                    <div style="display:flex;align-items:center;gap:10px;padding:9px 0;border-bottom:1px solid var(--border);">
                        <c:choose>
                            <c:when test="${t.status=='DONE'}"><div style="width:18px;height:18px;border-radius:50%;background:rgba(67,233,123,0.2);display:flex;align-items:center;justify-content:center;font-size:9px;flex-shrink:0;color:var(--accent3);">✓</div></c:when>
                            <c:when test="${t.status=='OVERDUE'}"><div style="width:18px;height:18px;border-radius:50%;background:rgba(255,101,132,0.2);display:flex;align-items:center;justify-content:center;font-size:9px;flex-shrink:0;color:var(--accent2);">!</div></c:when>
                            <c:otherwise><div style="width:18px;height:18px;border-radius:50%;border:2px solid var(--border);flex-shrink:0;"></div></c:otherwise>
                        </c:choose>
                        <div style="flex:1;min-width:0;">
                            <div style="font-size:13px;font-weight:500;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;">${t.title}</div>
                            <div style="font-size:11px;color:var(--text2);">Project #${t.projectId}</div>
                        </div>
                        <c:choose>
                            <c:when test="${t.priority=='HIGH'||t.priority=='CRITICAL'}"><span class="badge badge-red" style="font-size:9px;">${t.priority}</span></c:when>
                            <c:when test="${t.priority=='MEDIUM'}"><span class="badge badge-purple" style="font-size:9px;">MED</span></c:when>
                            <c:otherwise><span class="badge badge-gray" style="font-size:9px;">LOW</span></c:otherwise>
                        </c:choose>
                        <a href="/tasks/detail/${t.id}" style="color:var(--text2);font-size:12px;text-decoration:none;">→</a>
                    </div>
                    </c:forEach>
                </c:otherwise>
            </c:choose>
        </div>

        <%-- ACTIVITY FEED (org) / PRODUCTIVITY TIPS (personal) --%>
        <c:choose>
            <c:when test="${not empty tenant and tenant.personal}">
                <div class="card">
                    <div class="card-header">
                        <span class="card-title">Productivity Tips</span>
                        <span class="badge badge-green">Personal</span>
                    </div>
                    <div style="padding:8px 0;">
                        <div style="display:flex;gap:10px;padding:10px 0;border-bottom:1px solid var(--border);align-items:flex-start;">
                            <div style="font-size:20px;">💡</div>
                            <div style="font-size:13px;color:var(--text2);line-height:1.5;">Break big goals into small tasks. Use the Kanban board to track each step.</div>
                        </div>
                        <div style="display:flex;gap:10px;padding:10px 0;border-bottom:1px solid var(--border);align-items:flex-start;">
                            <div style="font-size:20px;">📝</div>
                            <div style="font-size:13px;color:var(--text2);line-height:1.5;">Use Notes to capture ideas quickly before they slip away.</div>
                        </div>
                        <div style="display:flex;gap:10px;padding:10px 0;border-bottom:1px solid var(--border);align-items:flex-start;">
                            <div style="font-size:20px;">📅</div>
                            <div style="font-size:13px;color:var(--text2);line-height:1.5;">Set due dates on tasks and review overdue items every morning.</div>
                        </div>
                        <div style="display:flex;gap:10px;padding:10px 0;align-items:flex-start;">
                            <div style="font-size:20px;">🚀</div>
                            <div style="font-size:13px;color:var(--text2);line-height:1.5;">Need to collaborate? <a href="/workspace/settings" style="color:var(--accent);">Upgrade to Organization</a> and invite your team.</div>
                        </div>
                    </div>
                </div>
            </c:when>
            <c:otherwise>
                <div class="card">
                    <div class="card-header">
                        <span class="card-title">Activity Feed</span>
                        <span class="badge badge-green pulse">Live</span>
                    </div>
                    <div style="max-height:300px;overflow-y:auto;">
                        <c:choose>
                            <c:when test="${empty recentActivity}">
                                <div style="text-align:center;padding:30px;color:var(--text2);font-size:13px;">
                                    🚀 Your workspace is ready! Start by creating a project.
                                </div>
                            </c:when>
                            <c:otherwise>
                                <c:forEach var="a" items="${recentActivity}">
                                <div style="display:flex;gap:10px;padding:9px 0;border-bottom:1px solid var(--border);align-items:flex-start;">
                                    <div style="width:28px;height:28px;border-radius:50%;background:rgba(108,99,255,0.15);display:flex;align-items:center;justify-content:center;font-size:12px;flex-shrink:0;">${a.actionEmoji}</div>
                                    <div style="flex:1;min-width:0;">
                                        <div style="font-size:12px;font-weight:500;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;">
                                            <span style="color:var(--accent)">${a.username}</span> · ${a.entityName}
                                        </div>
                                        <div style="font-size:11px;color:var(--text2);">${a.timeAgo}</div>
                                    </div>
                                </div>
                                </c:forEach>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>
            </c:otherwise>
        </c:choose>
    </div>
</div>
</body>
</html>
