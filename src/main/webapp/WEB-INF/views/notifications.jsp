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
            text-decoration:none; color:inherit; cursor:pointer;
        }
        .notif-item.unread {
            background:rgba(108,99,255,0.06);
            border-left:3px solid var(--accent);
            padding-left:13px;
        }
        .notif-item:hover { background:rgba(108,99,255,0.09); }
        .notif-item:last-child { border-bottom:none; }
        .notif-icon {
            width:42px; height:42px; border-radius:50%;
            background:rgba(108,99,255,0.15);
            display:flex; align-items:center; justify-content:center;
            font-size:18px; flex-shrink:0;
        }
        .notif-icon.task     { background:rgba(67,233,123,0.15); }
        .notif-icon.comment  { background:rgba(56,189,248,0.15); }
        .notif-icon.member   { background:rgba(255,101,132,0.15); }
        .notif-icon.project  { background:rgba(108,99,255,0.15); }
        .notif-icon.announce { background:rgba(249,202,36,0.15); }
        .notif-msg { font-size:14px; font-weight:500; line-height:1.4; color:var(--text); }
        .notif-msg.unread { font-weight:700; }
        .notif-time { font-size:11px; color:var(--text2); margin-top:4px; }
        .unread-dot {
            width:9px; height:9px; border-radius:50%;
            background:var(--accent); flex-shrink:0; margin-top:5px;
            box-shadow: 0 0 6px rgba(108,99,255,0.6);
        }
        .filter-tabs { display:flex; gap:6px; margin-bottom:20px; flex-wrap:wrap; }
        .filter-tab {
            padding:6px 14px; border-radius:20px; font-size:12px; font-weight:600;
            border:1px solid var(--border); background:var(--bg2); color:var(--text2);
            cursor:pointer; transition:all 0.2s; text-decoration:none;
        }
        .filter-tab.active, .filter-tab:hover {
            border-color:var(--accent); color:var(--accent); background:rgba(108,99,255,0.1);
        }
        .empty-notif {
            text-align:center; padding:80px 20px; color:var(--text2);
        }
        .notif-group-label {
            font-size:10px; font-weight:700; letter-spacing:2px; color:var(--text2);
            padding:10px 16px 4px; background:var(--bg3); border-bottom:1px solid var(--border);
        }
    </style>
</head>
<body>
<%@ include file="sidebar.jsp" %>

<div class="main fade-in">
    <div class="topbar">
        <div>
            <div class="page-title">🔔 Notifications</div>
            <div class="page-subtitle">
                <c:choose>
                    <c:when test="${unreadCount > 0}">${unreadCount} unread · Stay in the loop</c:when>
                    <c:otherwise>All caught up! ✅</c:otherwise>
                </c:choose>
            </div>
        </div>
        <div class="topbar-actions">
            <c:if test="${unreadCount > 0}">
            <form action="/notifications/mark-read" method="post">
                <button class="btn btn-primary">✅ Mark all read</button>
            </form>
            </c:if>
        </div>
    </div>

    <%-- Stats row --%>
    <div style="display:grid;grid-template-columns:repeat(5,1fr);gap:14px;margin-bottom:24px;">
        <div class="stat-card purple">
            <div class="stat-label">TOTAL</div>
            <div class="stat-value">${notifications.size()}</div>
            <div class="stat-sub">All time</div>
        </div>
        <div class="stat-card red">
            <div class="stat-label">UNREAD</div>
            <div class="stat-value">${unreadCount}</div>
            <div class="stat-sub">Need attention</div>
        </div>
        <div class="stat-card green">
            <div class="stat-label">TASKS</div>
            <div class="stat-value">
                <c:set var="taskNotifs" value="0"/>
                <c:forEach var="n" items="${notifications}">
                    <c:if test="${n.type == 'TASK_ASSIGNED'}"><c:set var="taskNotifs" value="${taskNotifs+1}"/></c:if>
                </c:forEach>${taskNotifs}
            </div>
            <div class="stat-sub">Assigned</div>
        </div>
        <div class="stat-card blue">
            <div class="stat-label">PROJECTS</div>
            <div class="stat-value">
                <c:set var="projNotifs" value="0"/>
                <c:forEach var="n" items="${notifications}">
                    <c:if test="${n.type == 'PROJECT_CREATED'}"><c:set var="projNotifs" value="${projNotifs+1}"/></c:if>
                </c:forEach>${projNotifs}
            </div>
            <div class="stat-sub">Created</div>
        </div>
        <div class="stat-card purple">
            <div class="stat-label">TEAM</div>
            <div class="stat-value">
                <c:set var="teamNotifs" value="0"/>
                <c:forEach var="n" items="${notifications}">
                    <c:if test="${n.type == 'MEMBER_JOINED' || n.type == 'MEMBER_INVITED'}"><c:set var="teamNotifs" value="${teamNotifs+1}"/></c:if>
                </c:forEach>${teamNotifs}
            </div>
            <div class="stat-sub">Members</div>
        </div>
    </div>

    <%-- Filter tabs --%>
    <div class="filter-tabs">
        <a href="#" class="filter-tab active" onclick="filterNotifs('all',this)">All</a>
        <a href="#" class="filter-tab" onclick="filterNotifs('TASK_ASSIGNED',this)">✅ Tasks</a>
        <a href="#" class="filter-tab" onclick="filterNotifs('PROJECT_CREATED',this)">🚀 Projects</a>
        <a href="#" class="filter-tab" onclick="filterNotifs('COMMENT_ADDED',this)">💬 Comments</a>
        <a href="#" class="filter-tab" onclick="filterNotifs('MEMBER_JOINED',this)">👥 Members</a>
        <a href="#" class="filter-tab" onclick="filterNotifs('ANNOUNCEMENT',this)">📢 Announcements</a>
    </div>

    <div class="card" style="padding:0;overflow:hidden;">
        <div style="padding:20px 24px;border-bottom:1px solid var(--border);display:flex;justify-content:space-between;align-items:center;">
            <span class="card-title">
                Notification Feed
                <c:if test="${unreadCount > 0}">
                    <span class="badge badge-red" style="margin-left:8px;">${unreadCount} new</span>
                </c:if>
            </span>
            <input type="text" placeholder="Search…" class="form-input"
                   style="width:180px;padding:6px 12px;font-size:12px;"
                   oninput="searchNotifs(this.value)">
        </div>

        <c:choose>
            <c:when test="${empty notifications}">
                <div class="empty-notif">
                    <div style="font-size:64px;margin-bottom:16px;opacity:0.3;">🔔</div>
                    <p style="font-size:16px;font-weight:700;margin-bottom:8px;">You're all caught up!</p>
                    <p style="font-size:13px;">Notifications will appear here when tasks are assigned to you,<br>
                    projects are created, or teammates join your workspace.</p>
                    <div style="margin-top:24px;display:flex;gap:10px;justify-content:center;flex-wrap:wrap;">
                        <a href="/projects" class="btn btn-primary">📁 View Projects</a>
                        <a href="/workspace/invite" class="btn btn-ghost">✉️ Invite Someone</a>
                    </div>
                </div>
            </c:when>
            <c:otherwise>
                <div id="notifList">
                    <c:forEach var="n" items="${notifications}">
                    <c:set var="iconClass" value=""/>
                    <c:choose>
                        <c:when test="${n.type == 'TASK_ASSIGNED'}"><c:set var="iconClass" value="task"/></c:when>
                        <c:when test="${n.type == 'COMMENT_ADDED'}"><c:set var="iconClass" value="comment"/></c:when>
                        <c:when test="${n.type == 'MEMBER_INVITED' or n.type == 'MEMBER_JOINED'}"><c:set var="iconClass" value="member"/></c:when>
                        <c:when test="${n.type == 'PROJECT_CREATED'}"><c:set var="iconClass" value="project"/></c:when>
                        <c:when test="${n.type == 'ANNOUNCEMENT'}"><c:set var="iconClass" value="announce"/></c:when>
                    </c:choose>
                    <div class="notif-item ${!n.read ? 'unread' : ''}"
                         data-type="${n.type}"
                         data-msg="${n.message}"
                         onclick="${not empty n.link ? 'location.href=\\''.concat(n.link).concat('\\'') : ''}">
                        <div class="notif-icon ${iconClass}">
                            <c:choose>
                                <c:when test="${n.typeIcon != null}">${n.typeIcon}</c:when>
                                <c:otherwise>🔔</c:otherwise>
                            </c:choose>
                        </div>
                        <div style="flex:1;">
                            <div class="notif-msg ${!n.read ? 'unread' : ''}">${n.message}</div>
                            <div class="notif-time">
                                ${n.timeAgo}
                                <c:if test="${n.type != null}">
                                    &nbsp;·&nbsp;
                                    <span style="font-size:10px;padding:1px 6px;border-radius:4px;
                                        background:rgba(108,99,255,0.1);color:var(--accent);">
                                        ${n.type.replace('_', ' ')}
                                    </span>
                                </c:if>
                            </div>
                        </div>
                        <c:if test="${!n.read}">
                            <div class="unread-dot"></div>
                        </c:if>
                    </div>
                    </c:forEach>
                </div>
            </c:otherwise>
        </c:choose>
    </div>
</div>

<script>
function filterNotifs(type, el) {
    document.querySelectorAll('.filter-tab').forEach(t => t.classList.remove('active'));
    el.classList.add('active');
    document.querySelectorAll('.notif-item').forEach(item => {
        if (type === 'all') {
            item.style.display = '';
        } else {
            item.style.display = item.dataset.type === type ? '' : 'none';
        }
    });
}

function searchNotifs(q) {
    const query = q.toLowerCase();
    document.querySelectorAll('.notif-item').forEach(item => {
        const msg = (item.dataset.msg || '').toLowerCase();
        item.style.display = msg.includes(query) ? '' : 'none';
    });
}
</script>
</body>
</html>
