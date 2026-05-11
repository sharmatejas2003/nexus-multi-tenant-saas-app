<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:set var="currentPage" value="calendar"/>
<!DOCTYPE html>
<html>
<head>
    <title>Nexus — Calendar</title>
    <link href="https://fonts.googleapis.com/css2?family=Space+Mono:wght@400;700&family=DM+Sans:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="/css/nexus.css">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/fullcalendar/6.1.11/index.global.min.css" rel="stylesheet">
    <style>
        .fc { font-family: 'DM Sans', sans-serif; }
        .fc-toolbar-title { font-family: 'Space Mono', monospace; font-size: 18px !important; color: var(--text) !important; }
        .fc-button { background: var(--bg3) !important; border-color: var(--border) !important; color: var(--text) !important; font-family: 'DM Sans', sans-serif !important; }
        .fc-button:hover { border-color: var(--accent) !important; color: var(--accent) !important; }
        .fc-button-active { background: var(--accent) !important; border-color: var(--accent) !important; color: white !important; }
        .fc-daygrid-day { background: var(--bg2); border-color: var(--border) !important; }
        .fc-daygrid-day:hover { background: var(--bg3); }
        .fc-day-today { background: rgba(108,99,255,0.08) !important; }
        .fc-day-today .fc-daygrid-day-number { color: var(--accent) !important; font-weight: 700 !important; }
        .fc-daygrid-day-number { color: var(--text2); font-size: 12px; }
        .fc-col-header-cell { background: var(--bg3); border-color: var(--border) !important; }
        .fc-col-header-cell-cushion { color: var(--text2); font-size: 11px; font-weight: 700; letter-spacing: 1px; text-decoration: none; }
        .fc-event { border-radius: 6px !important; padding: 2px 6px !important; font-size: 12px !important; border: none !important; cursor: pointer; }
        .fc-event:hover { opacity: 0.85; }
        .fc-scrollgrid { border-color: var(--border) !important; }
        .fc-scrollgrid td, .fc-scrollgrid th { border-color: var(--border) !important; }
        .fc-timegrid-slot { background: var(--bg2); border-color: var(--border) !important; }
        .fc-timegrid-axis { color: var(--text2); font-size: 11px; }

        .event-badge { display:inline-flex; align-items:center; gap:4px; padding:4px 10px; border-radius:8px; font-size:12px; font-weight:600; margin-bottom:6px; }
        .event-DEADLINE { background:rgba(255,101,132,0.15); color:var(--accent2); }
        .event-MEETING { background:rgba(56,189,248,0.15); color:var(--accent4); }
        .event-REMINDER { background:rgba(249,202,36,0.15); color:#f9ca24; }
        .event-EVENT { background:rgba(108,99,255,0.15); color:var(--accent); }

        .upcoming-item { display:flex; gap:10px; padding:10px 0; border-bottom:1px solid var(--border); align-items:flex-start; }
        .upcoming-item:last-child { border-bottom:none; }
        .event-dot { width:10px; height:10px; border-radius:50%; flex-shrink:0; margin-top:4px; }
        .cal-wrapper { background:var(--bg2); border:1px solid var(--border); border-radius:var(--card-radius); padding:20px; }
    </style>
</head>
<body>
<%@ include file="sidebar.jsp" %>

<div class="main fade-in">
    <div class="topbar">
        <div>
            <div class="page-title">📅 Calendar</div>
            <div class="page-subtitle">Team schedule, deadlines, and reminders.</div>
        </div>
        <div class="topbar-actions">
            <button class="btn btn-primary" onclick="document.getElementById('addEventModal').classList.add('open')">
                + Add Event
            </button>
        </div>
    </div>

    <c:if test="${param.created == 'true'}">
        <div class="alert alert-success" style="margin-bottom:16px;">✅ Event added!</div>
    </c:if>

    <%-- Stats --%>
    <div style="display:grid;grid-template-columns:repeat(4,1fr);gap:14px;margin-bottom:20px;">
        <div class="stat-card purple">
            <div class="stat-label">TOTAL EVENTS</div>
            <div class="stat-value">${events.size()}</div>
        </div>
        <div class="stat-card red">
            <div class="stat-label">DEADLINES</div>
            <div class="stat-value">
                <c:set var="deadlines" value="0"/>
                <c:forEach var="e" items="${events}">
                    <c:if test="${e.eventType == 'DEADLINE'}"><c:set var="deadlines" value="${deadlines+1}"/></c:if>
                </c:forEach>${deadlines}
            </div>
        </div>
        <div class="stat-card blue">
            <div class="stat-label">MEETINGS</div>
            <div class="stat-value">
                <c:set var="meetings" value="0"/>
                <c:forEach var="e" items="${events}">
                    <c:if test="${e.eventType == 'MEETING'}"><c:set var="meetings" value="${meetings+1}"/></c:if>
                </c:forEach>${meetings}
            </div>
        </div>
        <div class="stat-card green">
            <div class="stat-label">UPCOMING</div>
            <div class="stat-value">${upcomingEvents.size()}</div>
        </div>
    </div>

    <div style="display:grid;grid-template-columns:1fr 280px;gap:20px;">
        <%-- Calendar --%>
        <div class="cal-wrapper">
            <div id="calendar"></div>
        </div>

        <%-- Upcoming sidebar --%>
        <div style="display:flex;flex-direction:column;gap:14px;">
            <div class="card">
                <div class="card-header" style="margin-bottom:12px;">
                    <span class="card-title" style="font-size:13px;">⏰ Upcoming</span>
                </div>
                <c:choose>
                    <c:when test="${empty upcomingEvents}">
                        <div style="text-align:center;padding:20px;color:var(--text2);font-size:12px;">
                            No upcoming events
                        </div>
                    </c:when>
                    <c:otherwise>
                        <c:forEach var="e" items="${upcomingEvents}" varStatus="s">
                            <c:if test="${s.index < 8}">
                            <div class="upcoming-item">
                                <div class="event-dot" style="background:${e.color};"></div>
                                <div style="flex:1;min-width:0;">
                                    <div style="font-size:13px;font-weight:600;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;">${e.typeIcon} ${e.title}</div>
                                    <div style="font-size:11px;color:var(--text2);margin-top:2px;">${e.startDatetime}</div>
                                </div>
                                <c:if test="${isAdminOrOwner}">
                                <form action="/calendar/delete/${e.id}" method="post">
                                    <button class="btn btn-danger" style="padding:3px 7px;font-size:10px;">✕</button>
                                </form>
                                </c:if>
                            </div>
                            </c:if>
                        </c:forEach>
                    </c:otherwise>
                </c:choose>
            </div>

            <%-- Color legend --%>
            <div class="card">
                <div class="card-title" style="font-size:13px;margin-bottom:12px;">Legend</div>
                <div style="display:flex;flex-direction:column;gap:8px;">
                    <div style="display:flex;align-items:center;gap:8px;font-size:12px;"><div style="width:12px;height:12px;border-radius:3px;background:#6c63ff;flex-shrink:0;"></div> Event</div>
                    <div style="display:flex;align-items:center;gap:8px;font-size:12px;"><div style="width:12px;height:12px;border-radius:3px;background:#ff6584;flex-shrink:0;"></div> Deadline</div>
                    <div style="display:flex;align-items:center;gap:8px;font-size:12px;"><div style="width:12px;height:12px;border-radius:3px;background:#38bdf8;flex-shrink:0;"></div> Meeting</div>
                    <div style="display:flex;align-items:center;gap:8px;font-size:12px;"><div style="width:12px;height:12px;border-radius:3px;background:#f9ca24;flex-shrink:0;"></div> Reminder</div>
                </div>
            </div>
        </div>
    </div>
</div>

<%-- Add Event Modal --%>
<div class="modal-overlay" id="addEventModal">
    <div class="modal" style="width:520px;">
        <div class="modal-title">📅 Add Calendar Event</div>
        <form action="/calendar/add" method="post">
            <div class="form-group">
                <label class="form-label">EVENT TITLE *</label>
                <input type="text" name="title" class="form-input" placeholder="e.g. Sprint Planning" required autofocus>
            </div>
            <div class="form-group">
                <label class="form-label">DESCRIPTION</label>
                <textarea name="description" class="form-textarea" rows="2" placeholder="Optional details..."></textarea>
            </div>
            <div style="display:grid;grid-template-columns:1fr 1fr;gap:12px;margin-bottom:14px;">
                <div>
                    <label class="form-label">START *</label>
                    <input type="datetime-local" name="startDatetime" class="form-input" required>
                </div>
                <div>
                    <label class="form-label">END</label>
                    <input type="datetime-local" name="endDatetime" class="form-input">
                </div>
            </div>
            <div style="display:grid;grid-template-columns:1fr 1fr 1fr;gap:12px;margin-bottom:16px;">
                <div>
                    <label class="form-label">TYPE</label>
                    <select name="eventType" class="form-select" onchange="updateColor(this)">
                        <option value="EVENT">📅 Event</option>
                        <option value="DEADLINE">⏰ Deadline</option>
                        <option value="MEETING">🤝 Meeting</option>
                        <option value="REMINDER">🔔 Reminder</option>
                    </select>
                </div>
                <div>
                    <label class="form-label">COLOR</label>
                    <input type="color" name="color" id="eventColor" value="#6c63ff" class="form-input" style="height:42px;padding:4px;">
                </div>
                <div>
                    <label class="form-label">PROJECT</label>
                    <select name="linkedProjectId" class="form-select">
                        <option value="">None</option>
                        <c:forEach var="p" items="${projects}">
                            <option value="${p.id}">${p.name}</option>
                        </c:forEach>
                    </select>
                </div>
            </div>
            <div style="display:flex;gap:10px;justify-content:flex-end;">
                <button type="button" class="btn btn-ghost" onclick="document.getElementById('addEventModal').classList.remove('open')">Cancel</button>
                <button type="submit" class="btn btn-primary">Add Event →</button>
            </div>
        </form>
    </div>
</div>

<script src="https://cdnjs.cloudflare.com/ajax/libs/fullcalendar/6.1.11/index.global.min.js"></script>
<script>
const typeColors = { EVENT:'#6c63ff', DEADLINE:'#ff6584', MEETING:'#38bdf8', REMINDER:'#f9ca24' };

function updateColor(sel) {
    document.getElementById('eventColor').value = typeColors[sel.value] || '#6c63ff';
}

document.addEventListener('DOMContentLoaded', function() {
    const calEl = document.getElementById('calendar');
    const calendar = new FullCalendar.Calendar(calEl, {
        initialView: 'dayGridMonth',
        headerToolbar: {
            left: 'prev,next today',
            center: 'title',
            right: 'dayGridMonth,timeGridWeek,listWeek'
        },
        events: '/calendar/events.json',
        eventClick: function(info) {
            alert('📅 ' + info.event.title + '\nType: ' + (info.event.extendedProps.type || 'Event'));
        },
        dateClick: function(info) {
            const modal = document.getElementById('addEventModal');
            modal.classList.add('open');
            modal.querySelector('[name=startDatetime]').value = info.dateStr + 'T09:00';
        },
        height: 620,
        aspectRatio: 1.8,
        nowIndicator: true,
        editable: false,
        eventDisplay: 'block',
        dayMaxEvents: 3,
    });
    calendar.render();
});

document.querySelectorAll('.modal-overlay').forEach(o =>
    o.addEventListener('click', e => { if (e.target === o) o.classList.remove('open'); }));
</script>
</body>
</html>
