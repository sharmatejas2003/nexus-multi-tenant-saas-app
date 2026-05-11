<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<c:set var="currentPage" value="chat"/>
<!DOCTYPE html>
<html>
<head>
    <title>Nexus — Team Chat</title>
    <link href="https://fonts.googleapis.com/css2?family=Space+Mono:wght@400;700&family=DM+Sans:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="/css/nexus.css">
    <style>
        .chat-layout { display:grid; grid-template-columns:1fr 300px; gap:20px; height:calc(100vh - 160px); }
        .chat-main { display:flex; flex-direction:column; background:var(--bg2); border:1px solid var(--border); border-radius:var(--card-radius); overflow:hidden; }
        .chat-header { padding:16px 20px; border-bottom:1px solid var(--border); display:flex; align-items:center; gap:12px; background:var(--bg3); }
        .chat-messages { flex:1; overflow-y:auto; padding:16px; display:flex; flex-direction:column; gap:12px; }
        .chat-input-area { padding:14px 16px; border-top:1px solid var(--border); background:var(--bg3); }
        .chat-input-row { display:flex; gap:10px; align-items:flex-end; }
        .chat-input { flex:1; background:var(--bg2); border:1px solid var(--border); color:var(--text); padding:10px 14px; border-radius:10px; font-size:14px; font-family:'DM Sans',sans-serif; resize:none; min-height:42px; max-height:120px; transition:border-color 0.2s; }
        .chat-input:focus { outline:none; border-color:var(--accent); }
        .chat-send-btn { width:42px; height:42px; border-radius:10px; background:var(--accent); border:none; cursor:pointer; display:flex; align-items:center; justify-content:center; font-size:18px; transition:all 0.2s; flex-shrink:0; }
        .chat-send-btn:hover { background:#5a52e0; box-shadow:0 0 16px rgba(108,99,255,0.4); }

        .msg-bubble { display:flex; gap:10px; align-items:flex-start; }
        .msg-bubble.own { flex-direction:row-reverse; }
        .msg-avatar { width:34px; height:34px; border-radius:50%; background:linear-gradient(135deg,var(--accent),var(--accent2)); display:flex; align-items:center; justify-content:center; font-weight:700; font-size:13px; color:white; flex-shrink:0; }
        .msg-content { max-width:70%; }
        .msg-meta { font-size:11px; color:var(--text2); margin-bottom:3px; }
        .msg-bubble.own .msg-meta { text-align:right; }
        .msg-text { background:var(--bg3); border:1px solid var(--border); border-radius:10px; padding:10px 14px; font-size:14px; line-height:1.5; word-break:break-word; }
        .msg-bubble.own .msg-text { background:rgba(108,99,255,0.2); border-color:rgba(108,99,255,0.4); border-radius:10px 10px 0 10px; }
        .msg-bubble:not(.own) .msg-text { border-radius:0 10px 10px 10px; }
        .msg-time { font-size:10px; color:var(--text2); margin-top:3px; }
        .msg-bubble.own .msg-time { text-align:right; }

        .sidebar-panel { display:flex; flex-direction:column; gap:14px; overflow-y:auto; }
        .announce-card { background:var(--bg2); border:1px solid var(--border); border-radius:10px; padding:14px; }
        .announce-pinned { border-color:rgba(108,99,255,0.4); background:rgba(108,99,255,0.06); }
        .announce-title { font-size:13px; font-weight:700; margin-bottom:4px; }
        .announce-body { font-size:12px; color:var(--text2); line-height:1.5; }
        .announce-priority { display:inline-block; font-size:9px; font-weight:700; letter-spacing:1px; padding:2px 7px; border-radius:4px; margin-bottom:6px; }
        .priority-URGENT { background:rgba(255,101,132,0.2); color:var(--accent2); }
        .priority-HIGH { background:rgba(249,202,36,0.2); color:#f9ca24; }
        .priority-NORMAL { background:rgba(108,99,255,0.15); color:var(--accent); }
        .priority-LOW { background:rgba(136,136,170,0.15); color:var(--text2); }

        .typing-indicator { display:none; font-size:12px; color:var(--text2); padding:4px 0; font-style:italic; }
        .online-dot { width:8px; height:8px; border-radius:50%; background:var(--accent3); display:inline-block; margin-right:4px; }
        .char-count { font-size:10px; color:var(--text2); text-align:right; margin-top:4px; }

        @media (max-width:900px) { 
            .chat-layout { grid-template-columns:1fr; height:auto; } 
            .sidebar-panel { display:none; } 
        }
    </style>
</head>
<body>
<%@ include file="sidebar.jsp" %>

<div class="main" style="padding-bottom:0;">
    <div class="topbar" style="margin-bottom:16px;">
        <div>
            <div class="page-title">💬 Team Chat</div>
            <div class="page-subtitle">
                <c:if test="${not empty tenant}">${tenant.name} &nbsp;·&nbsp;</c:if>
                <span class="online-dot"></span> General Channel
            </div>
        </div>
        <div class="topbar-actions">
            <c:if test="${isAdminOrOwner}">
                <button class="btn btn-ghost" onclick="document.getElementById('announceModal').classList.add('open')">
                    📢 Post Announcement
                </button>
            </c:if>
        </div>
    </div>

    <c:if test="${param.announced == 'true'}">
        <div class="alert alert-success" style="margin-bottom:14px;">✅ Announcement posted successfully!</div>
    </c:if>

    <div class="chat-layout">
        <!-- MAIN CHAT -->
        <div class="chat-main">
            <div class="chat-header">
                <div style="width:36px;height:36px;border-radius:10px;background:rgba(108,99,255,0.2);display:flex;align-items:center;justify-content:center;font-size:18px;">#</div>
                <div>
                    <div style="font-weight:700;font-size:14px;">general</div>
                    <div style="font-size:11px;color:var(--text2);">Everyone in the workspace</div>
                </div>
                <div style="margin-left:auto;font-size:12px;color:var(--text2);">
                    <span class="online-dot"></span> ${messages.size()} messages
                </div>
            </div>

            <div class="chat-messages" id="chatMessages">
                <c:choose>
                    <c:when test="${empty messages}">
                        <div style="text-align:center;padding:60px 20px;color:var(--text2);">
                            <div style="font-size:52px;margin-bottom:12px;opacity:0.3;">💬</div>
                            <p style="font-size:15px;font-weight:600;">No messages yet</p>
                            <p style="font-size:13px;">Be the first to say something!</p>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <c:forEach var="msg" items="${messages}">
                            <div class="msg-bubble" 
                                 id="msg-${msg.id}">
                                <div class="msg-avatar">${msg.initial}</div>
                                <div class="msg-content">
                                    <div class="msg-meta"><strong>${msg.senderUsername}</strong></div>
                                    <div class="msg-text">${msg.message}</div>
                                    <div class="msg-time">
                                        ${msg.timeAgo}
                                        <c:if test="${isAdminOrOwner}">
                                            <span style="margin-left:8px;cursor:pointer;color:var(--accent2);font-size:9px;" 
                                                  onclick="deleteMsg(${msg.id})">✕</span>
                                        </c:if>
                                    </div>
                                </div>
                            </div>
                        </c:forEach>
                    </c:otherwise>
                </c:choose>
                <div id="chatBottom"></div>
            </div>

            <div class="chat-input-area">
                <div class="typing-indicator" id="typingIndicator">Someone is typing...</div>
                <div class="chat-input-row">
                    <textarea class="chat-input" id="msgInput" 
                              placeholder="Message #general... (Enter to send)" 
                              rows="1" maxlength="2000" oninput="onType(this)"></textarea>
                    <button class="chat-send-btn" onclick="sendMessage()" title="Send">➤</button>
                </div>
                <div class="char-count" id="charCount">0/2000</div>
            </div>
        </div>

        <!-- SIDE PANEL -->
        <div class="sidebar-panel">
            <!-- Pinned Announcements -->
            <div class="card" style="padding:16px;">
                <div class="card-header" style="margin-bottom:12px;">
                    <span class="card-title" style="font-size:13px;">📌 Pinned Announcements</span>
                </div>
                <c:choose>
                    <c:when test="${empty pinnedAnnouncements}">
                        <div style="text-align:center;padding:20px;color:var(--text2);font-size:12px;">
                            No pinned announcements
                        </div>
                    </c:when>
                    <c:otherwise>
                        <c:forEach var="a" items="${pinnedAnnouncements}">
                            <div class="announce-card announce-pinned" style="margin-bottom:10px;">
                                <div class="announce-priority priority-${a.priority}">${a.priority}</div>
                                <div class="announce-title">${a.title}</div>
                                <c:if test="${not empty a.content}">
                                    <div class="announce-body">${a.content}</div>
                                </c:if>
                                <div style="font-size:10px;color:var(--text2);margin-top:6px;">
                                    ${a.createdBy} · ${a.timeAgo}
                                </div>
                            </div>
                        </c:forEach>
                    </c:otherwise>
                </c:choose>
            </div>

            <!-- Quick Links -->
            <div class="card" style="padding:16px;">
                <div class="card-title" style="font-size:13px;margin-bottom:12px;">⚡ Quick Links</div>
                <div style="display:flex;flex-direction:column;gap:6px;">
                    <a href="/projects" class="btn btn-ghost btn-sm" style="justify-content:flex-start;gap:8px;">📁 Projects</a>
                    <a href="/calendar" class="btn btn-ghost btn-sm" style="justify-content:flex-start;gap:8px;">📅 Calendar</a>
                    <a href="/time" class="btn btn-ghost btn-sm" style="justify-content:flex-start;gap:8px;">⏱ Time Tracker</a>
                    <a href="/notes" class="btn btn-ghost btn-sm" style="justify-content:flex-start;gap:8px;">📝 Notes</a>
                    <a href="/files" class="btn btn-ghost btn-sm" style="justify-content:flex-start;gap:8px;">📎 Files</a>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- Announcement Modal -->
<c:if test="${isAdminOrOwner}">
<div class="modal-overlay" id="announceModal">
    <div class="modal" style="width:500px;">
        <div class="modal-title">📢 Post Announcement</div>
        <form action="/announcements/add" method="post">
            <div class="form-group">
                <label class="form-label">TITLE *</label>
                <input type="text" name="title" class="form-input" placeholder="e.g. Server maintenance tonight" required autofocus>
            </div>
            <div class="form-group">
                <label class="form-label">MESSAGE</label>
                <textarea name="content" class="form-textarea" rows="3" placeholder="Additional details..."></textarea>
            </div>
            <div style="display:grid;grid-template-columns:1fr 1fr;gap:12px;margin-bottom:16px;">
                <div>
                    <label class="form-label">PRIORITY</label>
                    <select name="priority" class="form-select">
                        <option value="LOW">Low</option>
                        <option value="NORMAL" selected>Normal</option>
                        <option value="HIGH">High</option>
                        <option value="URGENT">Urgent</option>
                    </select>
                </div>
                <div style="display:flex;align-items:flex-end;padding-bottom:4px;">
                    <label style="display:flex;align-items:center;gap:8px;cursor:pointer;">
                        <input type="checkbox" name="pinned" value="true">
                        <span class="form-label" style="margin:0;">📌 Pin this announcement</span>
                    </label>
                </div>
            </div>
            <div style="display:flex;gap:10px;justify-content:flex-end;">
                <button type="button" class="btn btn-ghost" onclick="document.getElementById('announceModal').classList.remove('open')">Cancel</button>
                <button type="submit" class="btn btn-primary">Post Announcement</button>
            </div>
        </form>
    </div>
</div>
</c:if>

<script>
const currentUser = '${pageContext.request.userPrincipal != null ? pageContext.request.userPrincipal.name : ""}';
<c:set var="lastMsg" value="${messages[messages.size()-1]}"/>
	let lastMessageId = ${lastMessageId};

// Auto scroll
function scrollToBottom() {
    const messagesDiv = document.getElementById('chatMessages');
    messagesDiv.scrollTop = messagesDiv.scrollHeight;
}
scrollToBottom();

// Send Message
function sendMessage() {
    const input = document.getElementById('msgInput');
    const msg = input.value.trim();
    if (!msg) return;

    input.value = '';
    updateCharCount(input);

    fetch('/chat/send', {
        method: 'POST',
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: 'message=' + encodeURIComponent(msg)
    })
    .then(r => r.json())
    .then(data => {
        if (data.success) {
            appendMessage(data, true);
            scrollToBottom();
        }
    })
    .catch(err => console.error(err));
}

// Append new message
function appendMessage(data, isOwn) {
    const container = document.getElementById('chatMessages');
    const bottom = document.getElementById('chatBottom');

    const div = document.createElement('div');
    div.className = `msg-bubble ${isOwn ? 'own' : ''}`;
    div.id = `msg-${data.id}`;
    div.innerHTML = `
        <div class="msg-avatar">${data.initial}</div>
        <div class="msg-content">
            <div class="msg-meta"><strong>${data.sender}</strong></div>
            <div class="msg-text">${escapeHtml(data.message)}</div>
            <div class="msg-time">${data.timeAgo}</div>
        </div>
    `;
    container.insertBefore(div, bottom);
}

function escapeHtml(text) {
    const div = document.createElement('div');
    div.textContent = text;
    return div.innerHTML;
}

// Poll for new messages
function pollMessages() {
    fetch('/chat/messages')
    .then(r => r.json())
    .then(msgs => {
        if (msgs.length === 0) return;
        
        const latestId = msgs[msgs.length - 1].id;
        if (latestId > lastMessageId) {
            const newMessages = msgs.filter(m => m.id > lastMessageId);
            newMessages.forEach(m => {
                if (m.sender !== currentUser) {
                    appendMessage(m, false);
                }
            });
            lastMessageId = latestId;
            scrollToBottom();
        }
    })
    .catch(() => {});
}

setInterval(pollMessages, 3000);

// Delete Message
function deleteMsg(id) {
    if (!confirm('Delete this message?')) return;
    
    fetch('/chat/delete/' + id, { method: 'POST' })
    .then(r => r.json())
    .then(data => {
        if (data.success) {
            const el = document.getElementById('msg-' + id);
            if (el) el.remove();
        }
    });
}

// Input handlers
function onType(el) {
    el.style.height = 'auto';
    el.style.height = Math.min(el.scrollHeight, 120) + 'px';
    updateCharCount(el);
}

function updateCharCount(el) {
    document.getElementById('charCount').textContent = el.value.length + '/2000';
}

document.getElementById('msgInput').addEventListener('keydown', function(e) {
    if (e.key === 'Enter' && !e.shiftKey) {
        e.preventDefault();
        sendMessage();
    }
});

// Modal handling
document.querySelectorAll('.modal-overlay').forEach(overlay => {
    overlay.addEventListener('click', e => {
        if (e.target === overlay) overlay.classList.remove('open');
    });
});
</script>
</body>
</html>