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
            display: flex; 
            gap: 14px; 
            padding: 16px;
            border-bottom: 1px solid rgba(42,42,58,0.5);
            transition: background 0.2s;
            align-items: flex-start;
            text-decoration: none; 
            color: inherit; 
            cursor: pointer;
        }
        .notif-item.unread {
            background: rgba(108,99,255,0.06);
            border-left: 3px solid var(--accent);
            padding-left: 13px;
        }
        .notif-item:hover { 
            background: rgba(108,99,255,0.09); 
        }
        .notif-item:last-child { 
            border-bottom: none; 
        }

        .notif-icon {
            width: 42px; 
            height: 42px; 
            border-radius: 50%;
            background: rgba(108,99,255,0.15);
            display: flex; 
            align-items: center; 
            justify-content: center;
            font-size: 18px; 
            flex-shrink: 0;
        }
        .notif-icon.task    { background: rgba(67,233,123,0.15); }
        .notif-icon.comment { background: rgba(56,189,248,0.15); }
        .notif-icon.member  { background: rgba(255,101,132,0.15); }
        .notif-icon.project { background: rgba(108,99,255,0.15); }
        .notif-icon.announce{ background: rgba(249,202,36,0.15); }

        .notif-msg { 
            font-size: 14px; 
            font-weight: 500; 
            line-height: 1.4; 
            color: var(--text); 
        }
        .notif-msg.unread { font-weight: 700; }

        .notif-time { 
            font-size: 11px; 
            color: var(--text2); 
            margin-top: 4px; 
        }

        .unread-dot {
            width: 9px; 
            height: 9px; 
            border-radius: 50%;
            background: var(--accent); 
            flex-shrink: 0; 
            margin-top: 6px;
            box-shadow: 0 0 6px rgba(108,99,255,0.6);
        }

        .filter-tabs { 
            display: flex; 
            gap: 6px; 
            margin-bottom: 20px; 
            flex-wrap: wrap; 
        }
        .filter-tab {
            padding: 6px 14px; 
            border-radius: 20px; 
            font-size: 12px; 
            font-weight: 600;
            border: 1px solid var(--border); 
            background: var(--bg2); 
            color: var(--text2);
            cursor: pointer; 
            transition: all 0.2s; 
            text-decoration: none;
        }
        .filter-tab.active, 
        .filter-tab:hover {
            border-color: var(--accent); 
            color: var(--accent); 
            background: rgba(108,99,255,0.1);
        }

        .empty-notif {
            text-align: center; 
            padding: 80px 20px; 
            color: var(--text2);
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
                    <c:when test="${unreadCount > 0}">${unreadCount} unread messages</c:when>
                    <c:otherwise>All caught up! ✅</c:otherwise>
                </c:choose>
            </div>
        </div>
        <div class="topbar-actions">
            <c:if test="${unreadCount > 0}">
                <form action="/notifications/mark-read" method="post">
                    <button class="btn btn-primary">✅ Mark all as read</button>
                </form>
            </c:if>
        </div>
    </div>

    <!-- Stats -->
    <div style="display:grid;grid-template-columns:repeat(5,1fr);gap:14px;margin-bottom:24px;">
        <div class="stat-card purple">
            <div class="stat-label">TOTAL</div>
            <div class="stat-value">${notifications.size()}</div>
        </div>
        <div class="stat-card red">
            <div class="stat-label">UNREAD</div>
            <div class="stat-value">${unreadCount}</div>
        </div>
        <div class="stat-card green">
            <div class="stat-label">TASKS</div>
            <div class="stat-value">
                <c:set var="taskCount" value="0"/>
                <c:forEach var="n" items="${notifications}">
                    <c:if test="${n.type == 'TASK_ASSIGNED'}"><c:set var="taskCount" value="${taskCount + 1}"/></c:if>
                </c:forEach>
                ${taskCount}
            </div>
        </div>
        <div class="stat-card blue">
            <div class="stat-label">PROJECTS</div>
            <div class="stat-value">
                <c:set var="projCount" value="0"/>
                <c:forEach var="n" items="${notifications}">
                    <c:if test="${n.type == 'PROJECT_CREATED'}"><c:set var="projCount" value="${projCount + 1}"/></c:if>
                </c:forEach>
                ${projCount}
            </div>
        </div>
        <div class="stat-card purple">
            <div class="stat-label">TEAM</div>
            <div class="stat-value">
                <c:set var="teamCount" value="0"/>
                <c:forEach var="n" items="${notifications}">
                    <c:if test="${n.type == 'MEMBER_JOINED' || n.type == 'MEMBER_INVITED'}">
                        <c:set var="teamCount" value="${teamCount + 1}"/>
                    </c:if>
                </c:forEach>
                ${teamCount}
            </div>
        </div>
    </div>

    <!-- Filter Tabs -->
    <div class="filter-tabs">
        <a href="#" class="filter-tab active" onclick="filterNotifs('all', this)">All</a>
        <a href="#" class="filter-tab" onclick="filterNotifs('TASK_ASSIGNED', this)">✅ Tasks</a>
        <a href="#" class="filter-tab" onclick="filterNotifs('PROJECT_CREATED', this)">🚀 Projects</a>
        <a href="#" class="filter-tab" onclick="filterNotifs('COMMENT_ADDED', this)">💬 Comments</a>
        <a href="#" class="filter-tab" onclick="filterNotifs('MEMBER_JOINED', this)">👥 Team</a>
        <a href="#" class="filter-tab" onclick="filterNotifs('ANNOUNCEMENT', this)">📢 Announcements</a>
    </div>

    <div class="card" style="padding:0; overflow:hidden;">
        <div style="padding:20px 24px; border-bottom:1px solid var(--border); display:flex; justify-content:space-between; align-items:center;">
            <span class="card-title">Notification History</span>
            <input type="text" id="searchInput" placeholder="Search notifications..." 
                   class="form-input" style="width:220px; padding:6px 12px; font-size:13px;"
                   oninput="searchNotifs(this.value)">
        </div>

        <c:choose>
            <c:when test="${empty notifications}">
                <div class="empty-notif">
                    <div style="font-size:72px; margin-bottom:16px; opacity:0.3;">🔔</div>
                    <p style="font-size:17px; font-weight:600; margin-bottom:8px;">No notifications yet</p>
                    <p style="font-size:13px; max-width:380px; margin:0 auto;">
                        You'll see task assignments, project updates, and team activity here.
                    </p>
                </div>
            </c:when>
            <c:otherwise>
                <div id="notifList">
                    <c:forEach var="n" items="${notifications}">
                        <div class="notif-item ${!n.read ? 'unread' : ''}" 
                             data-type="${n.type}"
                             data-msg="${n.message}"
                             onclick="${not empty n.link ? 'window.location.href=\''.concat(n.link).concat('\'') : ''}">
                            
                            <div class="notif-icon ${n.type == 'TASK_ASSIGNED' ? 'task' : 
                                                  n.type == 'COMMENT_ADDED' ? 'comment' : 
                                                  (n.type == 'MEMBER_JOINED' || n.type == 'MEMBER_INVITED') ? 'member' : 
                                                  n.type == 'PROJECT_CREATED' ? 'project' : 'announce'}">
                                ${n.typeIcon != null ? n.typeIcon : '🔔'}
                            </div>
                            
                            <div style="flex:1;">
                                <div class="notif-msg ${!n.read ? 'unread' : ''}">${n.message}</div>
                                <div class="notif-time">
                                    ${n.timeAgo}
                                    <c:if test="${not empty n.type}">
                                        &nbsp;·&nbsp;
                                        <span style="font-size:10px; padding:1px 6px; border-radius:4px; background:rgba(108,99,255,0.1); color:var(--accent);">
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
    document.querySelectorAll('.filter-tab').forEach(tab => tab.classList.remove('active'));
    el.classList.add('active');

    document.querySelectorAll('.notif-item').forEach(item => {
        item.style.display = (type === 'all' || item.dataset.type === type) ? '' : 'none';
    });
}

function searchNotifs(query) {
    query = query.toLowerCase().trim();
    document.querySelectorAll('.notif-item').forEach(item => {
        const text = (item.dataset.msg || '').toLowerCase();
        item.style.display = text.includes(query) ? '' : 'none';
    });
}

// Close modals if any
document.querySelectorAll('.modal-overlay').forEach(overlay => {
    overlay.addEventListener('click', e => {
        if (e.target === overlay) overlay.classList.remove('open');
    });
});
</script>
</body>
</html>