<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<html>
<head>
    <title>Notifications - Nexus</title>

    <link rel="stylesheet"
          href="${pageContext.request.contextPath}/css/nexus.css">
</head>

<body>

<jsp:include page="sidebar.jsp"/>

<div class="main fade-in">

    <div class="topbar">

        <div>

            <div class="page-title">
                Notifications
            </div>

            <div class="page-subtitle">
                ${unreadCount} unread notifications
            </div>

        </div>

        <form action="/notifications/mark-read" method="post">

            <button class="btn btn-primary">
                🔔 Mark all as read
            </button>

        </form>

    </div>

    <div class="card fade-in">

        <div class="card-header">

            <div class="card-title">
                Notification Center
            </div>

        </div>

        <c:choose>

            <c:when test="${empty notifications}">

                <div class="empty-state">

                    <div class="empty-icon">
                        🔔
                    </div>

                    <p>No notifications yet</p>

                </div>

            </c:when>

            <c:otherwise>

                <c:forEach items="${notifications}" var="n">

                    <div class="
                        notif-item
                        ${!n.read ? 'unread' : ''}
                    ">

                        <div class="notif-icon">
                            ${n.typeIcon}
                        </div>

                        <div style="flex:1;">

                            <div style="
                                font-weight:600;
                                color:var(--text);
                                font-size:14px;
                            ">
                                ${n.message}
                            </div>

                            <div class="comment-time">
                                ${n.timeAgo}
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