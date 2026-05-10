<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:set var="currentPage" value="notifications"/>
<!DOCTYPE html>
<html>
<head>
    <title>Nexus — Notifications</title>
    <link href="https://fonts.googleapis.com/css2?family=Space+Mono:wght@400;700&family=DM+Sans:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="/css/nexus.css">
    <style>
        .notif-item {
            display:flex; gap:14px; padding:16px;
            border-bottom:1px solid rgba(42,42,58,0.5);
            transition:background 0.15s; align-items:flex-start;
            text-decoration:none; color:inherit;
        }
        .notif-item.unread {
            background:rgba(108,99,255,0.05);
            border-left:3px solid var(--accent);
            padding-left:13px;
        }
        .notif-item:hover { background:rgba(108,99,255,0.08); }
        .notif-item:last-child { border-bottom:none; }
        .notif-icon {
            width:40px; height:40px; border-radius:50%;
            background:rgba(108,99,255,0.15);
            display:flex; align-items:center; justify-content:center;
            font-size:18px; flex-shrink:0;
        }
        .notif-icon.task     { background:rgba(67,233,123,0.15); }
        .notif-icon.comment  { background:rgba(56,189,248,0.15); }
        .notif-icon.member   { background:rgba(255,101,132,0.15); }
        .notif-icon.project  { background:rgba(108,99,255,0.15); }
        .notif-msg { font-size:14px; font-weight:500; line-height:1.4; color:var(--text); }
        .notif-msg.unread { font-weight:600; }
        .notif-time { font-size:11px; color:var(--text2); margin-top:4px; }
        .unread-dot {
            width:8px; height:8px; border-radius:50%;
            background:var(--accent); flex-shrink:0; margin-top:6px;
        }
    </style>
</head>
<body>
<%@ include file="sidebar.jsp" %>

<div class="main fade-in">
    <div class="topbar">
        <div>
            <div class="page-title">Notifications</div>
            <div class="page-subtitle">
                <c:choose>
                    <c:when test="${unreadCount > 0}">${unreadCount} unread notification${unreadCount != 1 ? 's' : ''}</c:when>
                    <c:otherwise>All caught up!</c:otherwise>
                </c:choose>
            </div>
        </div>
        <c:if test="${unreadCount > 0}">
        <form action="/notifications/mark-read" method="post">
            <button class="btn btn-ghost">✅ Mark all as read</button>
        </form>
        </c:if>
    </div>

    <%-- Stats row --%>
    <div style="display:grid;grid-template-columns:repeat(4,1fr);gap:14px;margin-bottom:24px;">
        <div class="stat-card purple">
            <div class="stat-label">TOTAL</div>
            <div class="stat-value">${notifications.size()}</div>
        </div>
        <div class="stat-card red">
            <div class="stat-label">UNREAD</div>
            <div class="stat-value">${unreadCount}</div>
        </div>
        <div class="stat-card green">
            <div class="stat-label">TASK UPDATES</div>
            <div class="stat-value">
                <c:set var="taskNotifs" value="0"/>
                <c:forEach var="n" items="${notifications}">
                    <c:if test="${n.type == 'TASK_ASSIGNED'}"><c:set var="taskNotifs" value="${taskNotifs+1}"/></c:if>
                </c:forEach>
                ${taskNotifs}
            </div>
        </div>
        <div class="stat-card blue">
            <div class="stat-label">PROJECT UPDATES</div>
            <div class="stat-value">
                <c:set var="projNotifs" value="0"/>
                <c:forEach var="n" items="${notifications}">
                    <c:if test="${n.type == 'PROJECT_CREATED'}"><c:set var="projNotifs" value="${projNotifs+1}"/></c:if>
                </c:forEach>
                ${projNotifs}
            </div>
        </div>
    </div>

    <div class="card" style="padding:0;overflow:hidden;">
        <div style="padding:20px 24px;border-bottom:1px solid var(--border);display:flex;justify-content:space-between;align-items:center;">
            <span class="card-title">
                All Notifications
                <c:if test="${unreadCount > 0}">
                    <span class="badge badge-red" style="margin-left:8px;">${unreadCount} new</span>
                </c:if>
            </span>
        </div>

        <c:choose>
            <c:when test="${empty notifications}">
                <div class="empty-state" style="padding:80px 20px;">
                    <div class="empty-icon">🔔</div>
                    <p style="font-size:15px;font-weight:600;margin-bottom:8px;">No notifications yet</p>
                    <p style="font-size:13px;">You'll be notified when tasks are assigned to you,<br>projects are created, or members join your workspace.</p>
                </div>
            </c:when>
            <c:otherwise>
                <c:forEach var="n" items="${notifications}">
                <c:set var="iconClass" value=""/>
                <c:choose>
                    <c:when test="${n.type == 'TASK_ASSIGNED'}"><c:set var="iconClass" value="task"/></c:when>
                    <c:when test="${n.type == 'COMMENT_ADDED'}"><c:set var="iconClass" value="comment"/></c:when>
                    <c:when test="${n.type == 'MEMBER_INVITED' or n.type == 'MEMBER_JOINED'}"><c:set var="iconClass" value="member"/></c:when>
                    <c:when test="${n.type == 'PROJECT_CREATED'}"><c:set var="iconClass" value="project"/></c:when>
                </c:choose>
                <c:choose>
                    <c:when test="${not empty n.link}">
                        <a href="${n.link}" class="notif-item ${!n.read ? 'unread' : ''}" style="display:flex;">
                    </c:when>
                    <c:otherwise>
                        <div class="notif-item ${!n.read ? 'unread' : ''}">
                    </c:otherwise>
                </c:choose>
                    <div class="notif-icon ${iconClass}">${n.typeIcon}</div>
                    <div style="flex:1;">
                        <div class="notif-msg ${!n.read ? 'unread' : ''}">${n.message}</div>
                        <div class="notif-time">${n.timeAgo}</div>
                    </div>
                    <c:if test="${!n.read}">
                        <div class="unread-dot"></div>
                    </c:if>
                <c:choose>
                    <c:when test="${not empty n.link}"></a></c:when>
                    <c:otherwise></div></c:otherwise>
                </c:choose>
                </c:forEach>
            </c:otherwise>
        </c:choose>
    </div>
</div>
</body>
</html>
