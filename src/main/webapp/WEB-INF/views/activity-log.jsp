<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:set var="currentPage" value="activity"/>
<!DOCTYPE html>
<html>
<head>
    <title>Nexus — Activity Log</title>
    <link href="https://fonts.googleapis.com/css2?family=Space+Mono:wght@400;700&family=DM+Sans:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="/css/nexus.css">
    <style>
        .activity-timeline { position: relative; padding-left: 28px; }
        .activity-timeline::before {
            content: '';
            position: absolute;
            left: 9px; top: 0; bottom: 0;
            width: 2px;
            background: var(--border);
        }
        .activity-entry {
            position: relative;
            margin-bottom: 0;
            padding: 14px 0 14px 20px;
            border-bottom: 1px solid rgba(42,42,58,0.4);
            transition: background 0.15s;
        }
        .activity-entry:last-child { border-bottom: none; }
        .activity-entry:hover { background: rgba(108,99,255,0.03); border-radius: 8px; }
        .activity-dot {
            position: absolute;
            left: -24px;
            top: 50%;
            transform: translateY(-50%);
            width: 20px; height: 20px;
            border-radius: 50%;
            background: var(--bg3);
            border: 2px solid var(--border);
            display: flex; align-items: center; justify-content: center;
            font-size: 10px;
            z-index: 1;
        }
        .activity-entry:hover .activity-dot {
            border-color: var(--accent);
            background: rgba(108,99,255,0.15);
        }
        .activity-main { display: flex; align-items: center; gap: 12px; }
        .activity-meta { font-size: 11px; color: var(--text2); margin-top: 3px; }
        .activity-user { color: var(--accent); font-weight: 700; }
        .activity-entity { color: var(--text); font-weight: 600; }
        .filter-bar { display: flex; gap: 8px; flex-wrap: wrap; margin-bottom: 20px; align-items: center; }
        .filter-chip {
            padding: 5px 14px; border-radius: 20px; font-size: 12px; font-weight: 600;
            border: 1px solid var(--border); background: var(--bg2); color: var(--text2);
            cursor: pointer; text-decoration: none; transition: all 0.2s;
        }
        .filter-chip:hover, .filter-chip.active {
            border-color: var(--accent); color: var(--accent); background: rgba(108,99,255,0.1);
        }
        .search-wrap { margin-left: auto; }
        .empty-timeline {
            text-align: center; padding: 60px 20px; color: var(--text2);
        }
        .empty-timeline .icon { font-size: 48px; margin-bottom: 12px; opacity: 0.3; }
        .action-badge {
            font-size: 10px; font-weight: 700; letter-spacing: 0.5px;
            padding: 2px 8px; border-radius: 6px;
        }
    </style>
</head>
<body>
<%@ include file="sidebar.jsp" %>

<div class="main">
    <div class="topbar">
        <div>
            <div class="page-title">Activity Log</div>
            <div class="page-subtitle">Everything that's happened in this workspace.</div>
        </div>
        <div class="topbar-actions">
            <span class="badge badge-green pulse">Live</span>
        </div>
    </div>

    <%-- ── FILTER BAR ── --%>
    <div class="filter-bar">
        <a href="/activity" class="filter-chip ${empty filter ? 'active' : ''}">All</a>
        <a href="/activity?filter=PROJECT" class="filter-chip ${'PROJECT' == filter ? 'active' : ''}">🚀 Projects</a>
        <a href="/activity?filter=TASK" class="filter-chip ${'TASK' == filter ? 'active' : ''}">✅ Tasks</a>
        <a href="/activity?filter=NOTE" class="filter-chip ${'NOTE' == filter ? 'active' : ''}">📝 Notes</a>
        <a href="/activity?filter=FILE" class="filter-chip ${'FILE' == filter ? 'active' : ''}">📎 Files</a>
        <a href="/activity?filter=MEMBER" class="filter-chip ${'MEMBER' == filter ? 'active' : ''}">👥 Members</a>
        <div class="search-wrap">
            <input type="text" id="searchInput" placeholder="Search activity…" class="form-input"
                   style="width:200px;padding:6px 12px;font-size:12px;" oninput="filterEntries(this.value)">
        </div>
    </div>

    <%-- ── SUMMARY STATS ── --%>
    <div style="display:grid;grid-template-columns:repeat(4,1fr);gap:14px;margin-bottom:24px;">
        <div class="stat-card purple">
            <div class="stat-label">TOTAL EVENTS</div>
            <div class="stat-value">${activityLogs.size()}</div>
        </div>
        <div class="stat-card green">
            <div class="stat-label">TASKS COMPLETED</div>
            <div class="stat-value">
                <c:set var="doneCount" value="0"/>
                <c:forEach var="a" items="${activityLogs}">
                    <c:if test="${a.action == 'COMPLETED_TASK'}"><c:set var="doneCount" value="${doneCount + 1}"/></c:if>
                </c:forEach>
                ${doneCount}
            </div>
        </div>
        <div class="stat-card blue">
            <div class="stat-label">FILES UPLOADED</div>
            <div class="stat-value">
                <c:set var="fileCount" value="0"/>
                <c:forEach var="a" items="${activityLogs}">
                    <c:if test="${a.action == 'UPLOADED_FILE'}"><c:set var="fileCount" value="${fileCount + 1}"/></c:if>
                </c:forEach>
                ${fileCount}
            </div>
        </div>
        <div class="stat-card red">
            <div class="stat-label">COMMENTS ADDED</div>
            <div class="stat-value">
                <c:set var="commentCount" value="0"/>
                <c:forEach var="a" items="${activityLogs}">
                    <c:if test="${a.action == 'ADDED_COMMENT'}"><c:set var="commentCount" value="${commentCount + 1}"/></c:if>
                </c:forEach>
                ${commentCount}
            </div>
        </div>
    </div>

    <%-- ── TIMELINE ── --%>
    <div class="card" style="padding:0;overflow:hidden;">
        <div style="padding:20px 24px;border-bottom:1px solid var(--border);display:flex;justify-content:space-between;align-items:center;">
            <span class="card-title">
                Timeline
                <span class="badge badge-purple" style="margin-left:8px;">${activityLogs.size()} events</span>
            </span>
        </div>

        <div style="padding:20px 24px;">
            <c:choose>
                <c:when test="${empty activityLogs}">
                    <div class="empty-timeline">
                        <div class="icon">📋</div>
                        <p style="font-size:14px;font-weight:600;margin-bottom:6px;">No activity yet</p>
                        <p style="font-size:13px;">Actions like creating projects, tasks, and notes will appear here.</p>
                    </div>
                </c:when>
                <c:otherwise>
                    <div class="activity-timeline" id="activityTimeline">
                        <c:forEach var="a" items="${activityLogs}">
                        <%-- filter logic: show all if no filter, else match entityType --%>
                        <c:if test="${empty filter || a.entityType == filter}">
                        <div class="activity-entry" data-search="${a.username.toLowerCase()} ${a.entityName.toLowerCase()} ${a.action.toLowerCase()} ${a.entityType.toLowerCase()}">
                            <div class="activity-dot">${a.actionEmoji}</div>
                            <div class="activity-main">
                                <div style="flex:1;min-width:0;">
                                    <div style="font-size:13px;line-height:1.4;">
                                        <span class="activity-user">${a.username}</span>
                                        <span style="color:var(--text2);font-weight:400;"> · </span>
                                        <c:choose>
                                            <c:when test="${a.action == 'CREATED_PROJECT'}">created project</c:when>
                                            <c:when test="${a.action == 'DELETED_PROJECT'}">deleted project</c:when>
                                            <c:when test="${a.action == 'CREATED_TASK'}">created task</c:when>
                                            <c:when test="${a.action == 'COMPLETED_TASK'}">completed task</c:when>
                                            <c:when test="${a.action == 'DELETED_TASK'}">deleted task</c:when>
                                            <c:when test="${a.action == 'UPLOADED_FILE'}">uploaded file</c:when>
                                            <c:when test="${a.action == 'CREATED_NOTE'}">created note</c:when>
                                            <c:when test="${a.action == 'INVITED_MEMBER'}">invited member</c:when>
                                            <c:when test="${a.action == 'PROMOTED_MEMBER'}">promoted member</c:when>
                                            <c:when test="${a.action == 'REMOVED_MEMBER'}">removed member</c:when>
                                            <c:when test="${a.action == 'ADDED_COMMENT'}">commented on</c:when>
                                            <c:otherwise>${a.action.toLowerCase().replace('_', ' ')}</c:otherwise>
                                        </c:choose>
                                        <span style="color:var(--text);font-weight:600;margin-left:4px;">"${a.entityName}"</span>
                                    </div>
                                    <div class="activity-meta">
                                        <span class="action-badge badge
                                            <c:choose>
                                                <c:when test="${a.entityType == 'PROJECT'}">badge-purple</c:when>
                                                <c:when test="${a.entityType == 'TASK'}">badge-green</c:when>
                                                <c:when test="${a.entityType == 'NOTE'}">badge-blue</c:when>
                                                <c:otherwise>badge-gray</c:otherwise>
                                            </c:choose>
                                        ">${a.entityType}</span>
                                        &nbsp;·&nbsp; ${a.timeAgo}
                                        <c:if test="${not empty a.details}">
                                            &nbsp;·&nbsp; <span style="color:var(--text2);">${a.details}</span>
                                        </c:if>
                                    </div>
                                </div>
                            </div>
                        </div>
                        </c:if>
                        </c:forEach>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>
    </div>
</div>

<script>
function filterEntries(query) {
    const q = query.toLowerCase();
    document.querySelectorAll('.activity-entry').forEach(el => {
        const text = el.getAttribute('data-search') || '';
        el.style.display = text.includes(q) ? '' : 'none';
    });
}
</script>
</body>
</html>
