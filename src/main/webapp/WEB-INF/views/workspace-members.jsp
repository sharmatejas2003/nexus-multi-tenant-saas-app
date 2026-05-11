<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:set var="currentPage" value="members"/>
<!DOCTYPE html>
<html>
<head>
    <title>Nexus — Team Members</title>
    <link href="https://fonts.googleapis.com/css2?family=Space+Mono:wght@400;700&family=DM+Sans:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="/css/nexus.css">
    <style>
        .member-card {
            display:flex; align-items:center; gap:16px; padding:16px;
            border-bottom:1px solid rgba(42,42,58,0.5); transition:background 0.15s;
        }
        .member-card:hover { background:rgba(108,99,255,0.04); }
        .member-card:last-child { border-bottom:none; }
        .member-avatar {
            width:44px; height:44px; border-radius:50%; flex-shrink:0;
            background:linear-gradient(135deg, var(--accent), var(--accent2));
            display:flex; align-items:center; justify-content:center;
            font-weight:700; font-size:16px; color:white;
            box-shadow:0 0 12px rgba(108,99,255,0.3);
        }
        .member-avatar img { width:100%; height:100%; border-radius:50%; object-fit:cover; }
        .member-details { flex:1; min-width:0; }
        .member-name { font-size:14px; font-weight:700; color:var(--text); white-space:nowrap; overflow:hidden; text-overflow:ellipsis; }
        .member-email { font-size:11px; color:var(--text2); margin-top:2px; white-space:nowrap; overflow:hidden; text-overflow:ellipsis; }
        .member-bio { font-size:11px; color:var(--text2); margin-top:2px; font-style:italic; }
        .member-joined { font-size:10px; color:var(--text2); margin-top:3px; }
        .online-indicator { width:8px; height:8px; border-radius:50%; background:var(--accent3); flex-shrink:0; box-shadow:0 0 6px rgba(67,233,123,0.5); }
    </style>
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
            <c:if test="${loggedInRole == 'ADMIN' || loggedInRole == 'OWNER'}">
                <a href="/workspace/invite" class="btn btn-primary">+ Invite Member</a>
            </c:if>
        </div>
    </div>

    <%-- Stats --%>
    <div class="grid-3" style="margin-bottom:24px;">
        <div class="stat-card purple">
            <div class="stat-label">TOTAL MEMBERS</div>
            <div class="stat-value">${not empty memberInfoList ? memberInfoList.size() : members.size()}</div>
        </div>
        <div class="stat-card green">
            <div class="stat-label">ONLINE NOW</div>
            <div class="stat-value">${not empty memberInfoList ? memberInfoList.size() : members.size()}</div>
            <div class="stat-sub">All active</div>
        </div>
        <div class="stat-card blue">
            <div class="stat-label">YOUR ROLE</div>
            <div class="stat-value" style="font-size:18px;margin-top:6px;">${loggedInRole}</div>
        </div>
    </div>

    <div class="card" style="padding:0;overflow:hidden;">
        <div style="padding:20px 24px;border-bottom:1px solid var(--border);display:flex;justify-content:space-between;align-items:center;">
            <span class="card-title">All Members
                <span class="badge badge-purple" style="margin-left:8px;">
                    ${not empty memberInfoList ? memberInfoList.size() : members.size()}
                </span>
            </span>
            <input type="text" placeholder="Search members..." class="form-input"
                   style="width:180px;padding:6px 12px;font-size:12px;"
                   oninput="filterMembers(this.value)">
        </div>

        <c:choose>
            <c:when test="${not empty memberInfoList}">
                <%-- Use MemberInfo list (has correct workspace_members role) --%>
                <div id="memberList">
                    <c:forEach var="m" items="${memberInfoList}">
                    <div class="member-card" data-search="${m.username.toLowerCase()} ${m.displayName.toLowerCase()} ${m.role.toLowerCase()}">
                        <div class="member-avatar">
                            <c:choose>
                                <c:when test="${not empty m.avatarUrl}">
                                    <img src="${m.avatarUrl}" alt="${m.displayName}">
                                </c:when>
                                <c:otherwise>${m.initial}</c:otherwise>
                            </c:choose>
                        </div>
                        <div class="member-details">
                            <div class="member-name">
                                ${m.displayName}
                                <c:if test="${m.username == loggedInUsername}">
                                    <span class="badge badge-blue" style="font-size:9px;margin-left:6px;">YOU</span>
                                </c:if>
                            </div>
                            <div class="member-email">${m.username}</div>
                            <c:if test="${not empty m.bio}">
                                <div class="member-bio">${m.bio}</div>
                            </c:if>
                        </div>
                        <div style="text-align:center;min-width:80px;">
                            <c:choose>
                                <c:when test="${m.role == 'OWNER'}"><span class="badge badge-red">👑 OWNER</span></c:when>
                                <c:when test="${m.role == 'ADMIN'}"><span class="badge badge-purple">🛡 ADMIN</span></c:when>
                                <c:otherwise><span class="badge badge-gray">👤 MEMBER</span></c:otherwise>
                            </c:choose>
                        </div>
                        <div style="text-align:center;"><div class="online-indicator"></div></div>
                        <div style="display:flex;gap:8px;flex-wrap:wrap;min-width:180px;justify-content:flex-end;">
                            <c:choose>
                                <c:when test="${m.role == 'OWNER'}">
                                    <span style="font-size:12px;color:var(--text2);">Workspace Owner</span>
                                </c:when>
                                <c:when test="${m.username == loggedInUsername}">
                                    <span style="font-size:12px;color:var(--text2);">That's you!</span>
                                </c:when>
                                <c:when test="${loggedInRole == 'ADMIN' || loggedInRole == 'OWNER'}">
                                    <c:if test="${m.role != 'ADMIN' && m.role != 'OWNER'}">
                                        <form action="/workspace/members/promote/${m.id}" method="post">
                                            <button class="btn btn-ghost" style="padding:5px 10px;font-size:11px;">⬆ Admin</button>
                                        </form>
                                    </c:if>
                                    <c:if test="${m.role == 'ADMIN'}">
                                        <form action="/workspace/members/demote/${m.id}" method="post">
                                            <button class="btn btn-ghost" style="padding:5px 10px;font-size:11px;">⬇ Member</button>
                                        </form>
                                    </c:if>
                                    <c:if test="${loggedInRole == 'OWNER' || (loggedInRole == 'ADMIN' && m.role == 'MEMBER')}">
                                        <form action="/workspace/members/ban/${m.id}" method="post"
                                              onsubmit="return confirm('Remove ${m.displayName} from workspace?')">
                                            <button class="btn btn-danger" style="padding:5px 10px;font-size:11px;">✕ Remove</button>
                                        </form>
                                    </c:if>
                                </c:when>
                                <c:otherwise>
                                    <span style="font-size:12px;color:var(--text2);">—</span>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </div>
                    </c:forEach>
                </div>
            </c:when>
            <c:when test="${not empty members}">
                <%-- Fallback to users list --%>
                <div id="memberList">
                    <c:forEach var="m" items="${members}">
                    <div class="member-card" data-search="${m.username.toLowerCase()} ${m.role.toLowerCase()}">
                        <div class="member-avatar">${m.username.substring(0,1).toUpperCase()}</div>
                        <div class="member-details">
                            <div class="member-name">
                                <c:choose>
                                    <c:when test="${m.username.contains('@')}">${m.username.split('@')[0]}</c:when>
                                    <c:otherwise>${m.username}</c:otherwise>
                                </c:choose>
                                <c:if test="${m.username == loggedInUsername}">
                                    <span class="badge badge-blue" style="font-size:9px;margin-left:6px;">YOU</span>
                                </c:if>
                            </div>
                            <div class="member-email">${m.username}</div>
                            <c:if test="${not empty m.bio}"><div class="member-bio">${m.bio}</div></c:if>
                        </div>
                        <div>
                            <c:choose>
                                <c:when test="${m.role == 'OWNER'}"><span class="badge badge-red">👑 OWNER</span></c:when>
                                <c:when test="${m.role == 'ADMIN'}"><span class="badge badge-purple">🛡 ADMIN</span></c:when>
                                <c:otherwise><span class="badge badge-gray">👤 MEMBER</span></c:otherwise>
                            </c:choose>
                        </div>
                        <div><div class="online-indicator"></div></div>
                        <div style="display:flex;gap:8px;flex-wrap:wrap;min-width:180px;justify-content:flex-end;">
                            <c:choose>
                                <c:when test="${m.role == 'OWNER'}">
                                    <span style="font-size:12px;color:var(--text2);">Owner</span>
                                </c:when>
                                <c:when test="${m.username == loggedInUsername}">
                                    <span style="font-size:12px;color:var(--text2);">That's you!</span>
                                </c:when>
                                <c:when test="${loggedInRole == 'ADMIN' || loggedInRole == 'OWNER'}">
                                    <c:if test="${m.role != 'ADMIN' && m.role != 'OWNER'}">
                                        <form action="/workspace/members/promote/${m.id}" method="post">
                                            <button class="btn btn-ghost" style="padding:5px 10px;font-size:11px;">⬆ Admin</button>
                                        </form>
                                    </c:if>
                                    <c:if test="${m.role == 'ADMIN'}">
                                        <form action="/workspace/members/demote/${m.id}" method="post">
                                            <button class="btn btn-ghost" style="padding:5px 10px;font-size:11px;">⬇ Member</button>
                                        </form>
                                    </c:if>
                                    <form action="/workspace/members/ban/${m.id}" method="post"
                                          onsubmit="return confirm('Remove member?')">
                                        <button class="btn btn-danger" style="padding:5px 10px;font-size:11px;">✕ Remove</button>
                                    </form>
                                </c:when>
                                <c:otherwise><span style="font-size:12px;color:var(--text2);">—</span></c:otherwise>
                            </c:choose>
                        </div>
                    </div>
                    </c:forEach>
                </div>
            </c:when>
            <c:otherwise>
                <div class="empty-state" style="padding:60px 20px;">
                    <div class="empty-icon">👥</div>
                    <p>No members yet. <a href="/workspace/invite" style="color:var(--accent)">Invite someone →</a></p>
                </div>
            </c:otherwise>
        </c:choose>
    </div>
</div>

<script>
function filterMembers(q) {
    const query = q.toLowerCase();
    document.querySelectorAll('.member-card').forEach(card => {
        const text = card.getAttribute('data-search') || '';
        card.style.display = text.includes(query) ? '' : 'none';
    });
}
</script>
</body>
</html>
