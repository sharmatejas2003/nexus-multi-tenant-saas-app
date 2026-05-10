<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<html>
<head>
    <title>Analytics - Nexus</title>

    <link rel="stylesheet"
          href="${pageContext.request.contextPath}/css/nexus.css">
</head>

<body>

<jsp:include page="sidebar.jsp"/>

<div class="main fade-in">

    <div class="topbar">
        <div>
            <div class="page-title">
                Analytics Dashboard
            </div>

            <div class="page-subtitle">
                Workspace insights & productivity
            </div>
        </div>
    </div>

    <div class="stats-grid">

        <div class="stat-card purple">
            <div class="stat-label">TOTAL TASKS</div>
            <div class="stat-value">${totalTasks}</div>
            <div class="stat-sub">All workspace tasks</div>
        </div>

        <div class="stat-card green">
            <div class="stat-label">COMPLETED</div>
            <div class="stat-value">${tasksDone}</div>
            <div class="stat-sub">Finished successfully</div>
        </div>

        <div class="stat-card blue">
            <div class="stat-label">IN PROGRESS</div>
            <div class="stat-value">${tasksInProgress}</div>
            <div class="stat-sub">Currently active</div>
        </div>

        <div class="stat-card purple">
            <div class="stat-label">PROJECTS</div>
            <div class="stat-value">${totalProjects}</div>
            <div class="stat-sub">Workspace projects</div>
        </div>

    </div>

    <div class="card fade-in">

        <div class="card-header">
            <div class="card-title">
                Recent Activity
            </div>
        </div>

        <c:choose>

            <c:when test="${empty recentActivity}">

                <div class="empty-state">
                    <div class="empty-icon">📈</div>
                    <p>No analytics activity yet</p>
                </div>

            </c:when>

            <c:otherwise>

                <c:forEach items="${recentActivity}" var="activity">

                    <div class="notif-item">

                        <div class="notif-icon">
                            ${activity.actionEmoji}
                        </div>

                        <div>

                            <div style="
                                font-weight:600;
                                color:var(--text);
                            ">
                                ${activity.entityName}
                            </div>

                            <div class="comment-time">
                                ${activity.timeAgo}
                            </div>

                        </div>

                    </div>

                </c:forEach>

            </c:otherwise>

        </c:choose>

    </div>

</div>

</body>
</html>