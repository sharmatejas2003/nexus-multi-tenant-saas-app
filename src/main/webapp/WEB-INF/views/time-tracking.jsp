<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:set var="currentPage" value="time"/>
<!DOCTYPE html>
<html>
<head>
    <title>Nexus — Time Tracker</title>
    <link href="https://fonts.googleapis.com/css2?family=Space+Mono:wght@400;700&family=DM+Sans:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="/css/nexus.css">
    <style>
        .timer-display {
            font-family: 'Space Mono', monospace;
            font-size: 56px;
            font-weight: 700;
            color: var(--text);
            text-align: center;
            letter-spacing: 4px;
            text-shadow: 0 0 30px rgba(108,99,255,0.3);
        }
        .timer-display.running { color: var(--accent3); text-shadow: 0 0 30px rgba(67,233,123,0.4); animation: timerPulse 2s ease-in-out infinite; }
        @keyframes timerPulse { 0%,100%{text-shadow:0 0 30px rgba(67,233,123,0.4)} 50%{text-shadow:0 0 60px rgba(67,233,123,0.7)} }
        .timer-card { background:var(--bg2); border:1px solid var(--border); border-radius:var(--card-radius); padding:40px; text-align:center; margin-bottom:24px; position:relative; overflow:hidden; }
        .timer-card::before { content:''; position:absolute; inset:0; background:radial-gradient(ellipse at 50% 0%,rgba(108,99,255,0.08),transparent 70%); pointer-events:none; }
        .timer-btn { padding:14px 36px; border-radius:12px; font-size:16px; font-weight:700; cursor:pointer; border:none; font-family:'DM Sans',sans-serif; transition:all 0.2s; }
        .timer-start { background:var(--accent3); color:#0a0a0f; }
        .timer-start:hover { box-shadow:0 0 24px rgba(67,233,123,0.5); transform:translateY(-1px); }
        .timer-stop { background:var(--accent2); color:white; }
        .timer-stop:hover { box-shadow:0 0 24px rgba(255,101,132,0.5); transform:translateY(-1px); }
        .entry-row { display:flex; align-items:center; gap:12px; padding:12px 0; border-bottom:1px solid var(--border); }
        .entry-row:last-child { border-bottom:none; }
        .duration-badge { background:var(--bg3); border:1px solid var(--border); border-radius:8px; padding:4px 12px; font-family:'Space Mono',monospace; font-size:13px; font-weight:700; color:var(--accent); white-space:nowrap; }
        .entry-desc { flex:1; min-width:0; }
        .entry-desc strong { font-size:14px; display:block; white-space:nowrap; overflow:hidden; text-overflow:ellipsis; }
        .entry-desc small { font-size:11px; color:var(--text2); }
    </style>
</head>
<body>
<%@ include file="sidebar.jsp" %>

<div class="main fade-in">
    <div class="topbar">
        <div>
            <div class="page-title">⏱ Time Tracker</div>
            <div class="page-subtitle">Track time spent on tasks and projects.</div>
        </div>
    </div>

    <%-- Stats --%>
    <div style="display:grid;grid-template-columns:repeat(4,1fr);gap:14px;margin-bottom:24px;">
        <div class="stat-card purple">
            <div class="stat-label">TOTAL LOGGED</div>
            <c:set var="totalHrs" value="${totalMinutes / 60}"/>
            <div class="stat-value" style="font-size:24px;">${totalMinutes / 60}h</div>
            <div class="stat-sub">${totalMinutes} minutes total</div>
        </div>
        <div class="stat-card green">
            <div class="stat-label">YOUR ENTRIES</div>
            <div class="stat-value">${entries.size()}</div>
        </div>
        <div class="stat-card blue">
            <div class="stat-label">STATUS</div>
            <div class="stat-value" style="font-size:18px;margin-top:4px;">
                <c:choose>
                    <c:when test="${runningEntry != null}">
                        <span style="color:var(--accent3);">● LIVE</span>
                    </c:when>
                    <c:otherwise>
                        <span style="color:var(--text2);">○ IDLE</span>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>
        <div class="stat-card red">
            <div class="stat-label">TODAY</div>
            <div class="stat-value" id="todayMinutes" style="font-size:24px;">—</div>
        </div>
    </div>

    <%-- Timer Widget --%>
    <div class="timer-card">
        <div style="font-size:12px;font-weight:700;letter-spacing:2px;color:var(--text2);margin-bottom:20px;">
            <c:choose>
                <c:when test="${runningEntry != null}">⏱ TIMER RUNNING</c:when>
                <c:otherwise>⏱ READY TO TRACK</c:otherwise>
            </c:choose>
        </div>
        <div class="timer-display ${runningEntry != null ? 'running' : ''}" id="timerDisplay">
            00:00:00
        </div>

        <c:if test="${runningEntry != null}">
            <div style="color:var(--text2);font-size:13px;margin:12px 0;">
                Working on: <strong style="color:var(--text);">${runningEntry.description != null ? runningEntry.description : 'Task'}</strong>
            </div>
        </c:if>

        <div style="margin:24px 0;">
            <c:choose>
                <c:when test="${runningEntry != null}">
                    <button class="timer-btn timer-stop" onclick="stopTimer()">⏹ Stop Timer</button>
                </c:when>
                <c:otherwise>
                    <div style="display:flex;flex-direction:column;align-items:center;gap:12px;max-width:340px;margin:0 auto;">
                        <input type="text" id="timerDesc" class="form-input" placeholder="What are you working on?" style="text-align:center;">
                        <button class="timer-btn timer-start" onclick="startTimer()">▶ Start Timer</button>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>
    </div>

    <div class="grid-2">
        <%-- My Time Entries --%>
        <div class="card" style="padding:0;overflow:hidden;">
            <div style="padding:20px 24px;border-bottom:1px solid var(--border);">
                <span class="card-title">My Time Log</span>
            </div>
            <div style="padding:16px 20px;">
                <c:choose>
                    <c:when test="${empty entries}">
                        <div class="empty-state" style="padding:30px 20px;">
                            <div class="empty-icon">⏱</div>
                            <p>No time logged yet. Start tracking!</p>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <c:forEach var="e" items="${entries}" varStatus="s">
                            <c:if test="${s.index < 20}">
                            <div class="entry-row">
                                <div class="duration-badge">${e.formattedDuration}</div>
                                <div class="entry-desc">
                                    <strong>${e.description != null ? e.description : 'No description'}</strong>
                                    <small>
                                        <c:if test="${e.projectId != null}">📁 ${e.projectId} · </c:if>
                                        ${e.createdAt}
                                    </small>
                                </div>
                                <c:if test="${e.running}">
                                    <span class="badge badge-green pulse">LIVE</span>
                                </c:if>
                            </div>
                            </c:if>
                        </c:forEach>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>

        <%-- Team Time (admin only) --%>
        <c:if test="${isAdminOrOwner}">
        <div class="card" style="padding:0;overflow:hidden;">
            <div style="padding:20px 24px;border-bottom:1px solid var(--border);">
                <span class="card-title">Team Time Log</span>
                <span class="badge badge-purple" style="margin-left:8px;">${allEntries.size()} entries</span>
            </div>
            <div style="padding:16px 20px;">
                <c:choose>
                    <c:when test="${empty allEntries}">
                        <div class="empty-state" style="padding:30px 20px;">
                            <div class="empty-icon">👥</div>
                            <p>Team hasn't logged any time yet.</p>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <c:forEach var="e" items="${allEntries}" varStatus="s">
                            <c:if test="${s.index < 15}">
                            <div class="entry-row">
                                <div class="avatar" style="width:28px;height:28px;font-size:11px;flex-shrink:0;">${e.username.substring(0,1).toUpperCase()}</div>
                                <div class="duration-badge">${e.formattedDuration}</div>
                                <div class="entry-desc">
                                    <strong>${e.username}</strong>
                                    <small>${e.description != null ? e.description : 'No description'}</small>
                                </div>
                                <c:if test="${e.running}">
                                    <span class="badge badge-green pulse" style="font-size:9px;">LIVE</span>
                                </c:if>
                            </div>
                            </c:if>
                        </c:forEach>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>
        </c:if>
    </div>
</div>

<script>
let timerInterval;
let running = ${runningEntry != null ? 'true' : 'false'};
let startEpoch = ${runningEntry != null ? 'new Date(\'' + runningEntry.startTime + '\').getTime()' : 'null'};

function pad(n) { return String(n).padStart(2, '0'); }

function updateDisplay() {
    if (!running || !startEpoch) return;
    const elapsed = Math.floor((Date.now() - startEpoch) / 1000);
    const h = Math.floor(elapsed / 3600);
    const m = Math.floor((elapsed % 3600) / 60);
    const s = elapsed % 60;
    document.getElementById('timerDisplay').textContent = pad(h) + ':' + pad(m) + ':' + pad(s);
}

if (running && startEpoch) {
    updateDisplay();
    timerInterval = setInterval(updateDisplay, 1000);
}

function startTimer() {
    const desc = document.getElementById('timerDesc')?.value || '';
    fetch('/time/start', {
        method: 'POST',
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: 'description=' + encodeURIComponent(desc)
    })
    .then(r => r.json())
    .then(data => {
        if (data.success) location.reload();
        else alert('Failed to start: ' + (data.error || 'Unknown error'));
    });
}

function stopTimer() {
    fetch('/time/stop', { method: 'POST' })
    .then(r => r.json())
    .then(data => {
        if (data.success) {
            clearInterval(timerInterval);
            alert('✅ Time logged: ' + data.duration);
            location.reload();
        }
    });
}
</script>
</body>
</html>
