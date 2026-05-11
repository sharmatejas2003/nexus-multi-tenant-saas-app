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
            width:48px; height:48px; border-radius:50%; flex-shrink:0;
            background:linear-gradient(135deg,var(--accent),var(--accent2));
            display:flex; align-items:center; justify-content:center;
            font-weight:700; font-size:18px; color:white;
            box-shadow:0 0 12px rgba(108,99,255,0.3);
            overflow:hidden;
        }
        .member-avatar img { width:100%; height:100%; object-fit:cover; }
        .member-details { flex:1; min-width:0; }
        .member-name  { font-size:15px; font-weight:700; color:var(--text); }
        .member-email { font-size:12px; color:var(--text2); margin-top:2px; }
        .member-bio   { font-size:11px; color:var(--text2); margin-top:3px; font-style:italic; }
        .online-dot   { width:8px; height:8px; border-radius:50%; background:var(--accent3);
                        flex-shrink:0; box-shadow:0 0 6px rgba(67,233,123,0.5); }
        .role-chip    { min-width:90px; text-align:center; }
        .actions-col  { min-width:200px; display:flex; gap:6px; justify-content:flex-end; flex-wrap:wrap; }
    </style>
</head>
<body>
<%@ include file="sidebar.jsp" %>

<div class="main">
    <div class="topbar">
        <div>
            <div class="page-title">Team Members</div>
            <div class="page-subtitle">
                <c:if test="${not empty tenant}">${tenant.name} · </c:if>
                All workspace members and their roles.
            </div>
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
            <div class="stat-value">${not empty memberInfoList ? memberInfoList.size() : 0}</div>
        </div>
        <div class="stat-card green">
            <div class="stat-label">ADMINS</div>
            <div class="stat-value">
                <c:set var="adminCount" value="0"/>
                <c:forEach var="m" items="${memberInfoList}">
                    <c:if test="${m.role == 'ADMIN' || m.role == 'OWNER'}">
                        <c:set var="adminCount" value="${adminCount+1}"/>
                    </c:if>
                </c:forEach>${adminCount}
            </div>
        </div>
        <div class="stat-card blue">
            <div class="stat-label">YOUR ROLE</div>
            <div class="stat-value" style="font-size:18px;margin-top:6px;">${loggedInRole}</div>
        </div>
    </div>

    <div class="card" style="padding:0;overflow:hidden;">
        <div style="padding:20px 24px;border-bottom:1px solid var(--border);display:flex;justify-content:space-between;align-items:center;">
            <span class="card-title">
                All Members
                <span class="badge badge-purple" style="margin-left:8px;">${memberInfoList.size()}</span>
            </span>
            <input type="text" placeholder="Search members..." class="form-input"
                   style="width:200px;padding:6px 12px;font-size:12px;"
                   oninput="filterMembers(this.value)">
        </div>

        <c:choose>
            <c:when test="${not empty memberInfoList}">
                <div id="memberList">
                    <c:forEach var="m" items="${memberInfoList}">
                    <div class="member-card"
                         data-search="${m.username.toLowerCase()} ${m.displayName.toLowerCase()} ${m.role.toLowerCase()}">

                        <%-- Avatar --%>
                        <div class="member-avatar">
                            <c:choose>
                                <c:when test="${not empty m.avatarUrl}">
                                    <img src="${m.avatarUrl}" alt="${m.displayName}">
                                </c:when>
                                <c:otherwise>${m.initial}</c:otherwise>
                            </c:choose>
                        </div>

                        <%-- Name + email + bio --%>
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
                            <c:if test="${m.joinedAt != null}">
                                <div style="font-size:10px;color:var(--text2);margin-top:2px;">
                                    Joined ${m.joinedAt.toLocalDate()}
                                </div>
                            </c:if>
                        </div>

                        <%-- Role badge --%>
                        <div class="role-chip">
                            <c:choose>
                                <c:when test="${m.role == 'OWNER'}"><span class="badge badge-red">👑 OWNER</span></c:when>
                                <c:when test="${m.role == 'ADMIN'}"><span class="badge badge-purple">🛡 ADMIN</span></c:when>
                                <c:otherwise><span class="badge badge-gray">👤 MEMBER</span></c:otherwise>
                            </c:choose>
                        </div>

                        <%-- Online dot --%>
                        <div class="online-dot"></div>

                        <%-- Actions --%>
                        <div class="actions-col">
                            <c:choose>
                                <c:when test="${m.role == 'OWNER'}">
                                    <span style="font-size:12px;color:var(--text2);">Workspace Owner</span>
                                </c:when>
                                <c:when test="${m.username == loggedInUsername}">
                                    <a href="/workspace/profile" class="btn btn-ghost" style="padding:5px 10px;font-size:11px;">✏ Edit Profile</a>
                                </c:when>
                                <c:when test="${loggedInRole == 'ADMIN' || loggedInRole == 'OWNER'}">
                                    <c:if test="${m.role == 'MEMBER'}">
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
                                          onsubmit="return confirm('Remove ${m.displayName} from workspace?')">
                                        <button class="btn btn-danger" style="padding:5px 10px;font-size:11px;">✕ Remove</button>
                                    </form>
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
            <c:otherwise>
                <div class="empty-state" style="padding:60px 20px;">
                    <div class="empty-icon">👥</div>
                    <p>No members found. <a href="/workspace/invite" style="color:var(--accent)">Invite someone →</a></p>
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
