<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:set var="currentPage" value="settings"/>
<!DOCTYPE html>
<html>
<head>
    <title>Nexus — Settings</title>
    <link href="https://fonts.googleapis.com/css2?family=Space+Mono:wght@400;700&family=DM+Sans:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="/css/nexus.css">
</head>
<body>
<%@ include file="sidebar.jsp" %>

<%-- TRANSFER OWNERSHIP MODAL --%>
<div class="modal-overlay" id="transferModal">
    <div class="modal">
        <div class="modal-title">Transfer Ownership</div>
        <p style="font-size:13px;color:var(--text2);margin-bottom:20px;">
            Select a member to become the new Owner. You will be downgraded to Admin.
        </p>
        <form action="/workspace/transfer-ownership" method="post">
            <div style="margin-bottom:20px;">
                <label class="form-label">SELECT NEW OWNER</label>
                <select name="newOwnerId" class="form-select" required>
                    <option value="">— Choose a member —</option>
                    <c:forEach var="m" items="${members}">
                        <c:if test="${m.role != 'OWNER'}">
                            <option value="${m.id}">${m.username} (${m.role})</option>
                        </c:if>
                    </c:forEach>
                </select>
            </div>
            <div style="background:rgba(255,101,132,0.08);border:1px solid rgba(255,101,132,0.2);border-radius:8px;padding:12px;margin-bottom:20px;">
                <div style="font-size:12px;color:var(--accent2);">⚠️ This cannot be undone. You will lose Owner privileges immediately.</div>
            </div>
            <div style="display:flex;gap:10px;justify-content:flex-end;">
                <button type="button" class="btn btn-ghost" onclick="document.getElementById('transferModal').classList.remove('open')">Cancel</button>
                <button type="submit" class="btn btn-danger">Transfer Ownership</button>
            </div>
        </form>
    </div>
</div>

<%-- DELETE WORKSPACE MODAL --%>
<div class="modal-overlay" id="deleteModal">
    <div class="modal">
        <div class="modal-title" style="color:var(--accent2);">⚠️ Delete Workspace</div>
        <p style="font-size:13px;color:var(--text2);margin-bottom:16px;">
            This will permanently delete <strong style="color:var(--text);">${tenant.name}</strong> and all its data.
        </p>
        <div style="margin-bottom:20px;">
            <label class="form-label">TYPE YOUR WORKSPACE NAME TO CONFIRM</label>
            <input type="text" id="confirmName" class="form-input" placeholder="${tenant.name}">
        </div>
        <div style="display:flex;gap:10px;justify-content:flex-end;">
            <button type="button" class="btn btn-ghost" onclick="document.getElementById('deleteModal').classList.remove('open')">Cancel</button>
            <button type="button" class="btn btn-danger" onclick="confirmDelete()">Permanently Delete</button>
        </div>
        <form id="deleteForm" action="/workspace/delete" method="post" style="display:none;"></form>
    </div>
</div>

<div class="main">
    <div class="topbar">
        <div>
            <div class="page-title">Workspace Settings</div>
            <div class="page-subtitle">Configure your workspace details and preferences.</div>
        </div>
    </div>

    <c:if test="${param.saved=='true'}">
        <div class="alert alert-success" style="margin-bottom:20px;">✅ Workspace settings saved successfully.</div>
    </c:if>
    <c:if test="${param.transferred=='true'}">
        <div class="alert alert-success" style="margin-bottom:20px;">✅ Ownership transferred successfully.</div>
    </c:if>
    <c:if test="${param.error!=null}">
        <div class="alert alert-error" style="margin-bottom:20px;">❌ Error: ${param.error}</div>
    </c:if>

    <div style="max-width:700px;">

        <%-- GENERAL --%>
        <div class="card" style="margin-bottom:20px;">
            <div class="card-header"><span class="card-title">General Settings</span></div>
            <form action="/workspace/update" method="post">
                <input type="hidden" name="id" value="${tenant.id}">
                <div class="form-group">
                    <label class="form-label">WORKSPACE NAME</label>
                    <input type="text" name="name" class="form-input" value="${tenant.name}" required>
                </div>
                <div class="form-group">
                    <label class="form-label">URL SLUG</label>
                    <div style="display:flex;align-items:center;">
                        <span style="background:var(--bg3);border:1px solid var(--border);border-right:none;padding:10px 14px;border-radius:8px 0 0 8px;font-size:13px;color:var(--text2);white-space:nowrap;">nexus.app/</span>
                        <input type="text" name="slug" class="form-input" value="${tenant.slug}" style="border-radius:0 8px 8px 0;">
                    </div>
                </div>
                <%-- WORKSPACE TYPE --%>
                <div class="form-group">
                    <label class="form-label">WORKSPACE TYPE</label>
                    <div style="display:grid;grid-template-columns:1fr 1fr;border:1px solid var(--border);border-radius:10px;overflow:hidden;">
                        <label style="cursor:pointer;">
                            <input type="radio" name="workspaceType" value="PERSONAL"
                                   ${tenant.personal?'checked':''} style="display:none;" onchange="this.form.submit()">
                            <div style="padding:14px;text-align:center;font-size:13px;font-weight:600;transition:all 0.2s;
                                background:${tenant.personal?'var(--accent3)':'var(--bg2)'};
                                color:${tenant.personal?'#0a0a0f':'var(--text2)'};">
                                🧑 Personal<div style="font-size:10px;font-weight:400;margin-top:2px;opacity:0.8;">Solo use</div>
                            </div>
                        </label>
                        <label style="cursor:pointer;">
                            <input type="radio" name="workspaceType" value="ORGANIZATION"
                                   ${tenant.organization?'checked':''} style="display:none;" onchange="this.form.submit()">
                            <div style="padding:14px;text-align:center;font-size:13px;font-weight:600;transition:all 0.2s;
                                background:${tenant.organization?'var(--accent)':'var(--bg2)'};
                                color:${tenant.organization?'white':'var(--text2)'};">
                                🏢 Organization<div style="font-size:10px;font-weight:400;margin-top:2px;opacity:0.8;">Team collaboration</div>
                            </div>
                        </label>
                    </div>
                </div>
                <button type="submit" class="btn btn-primary">Save Changes</button>
            </form>
        </div>

        <%-- PLAN INFO --%>
        <div class="card" style="margin-bottom:20px;">
            <div class="card-header">
                <span class="card-title">Current Plan</span>
                <span class="badge badge-gray">${tenant.planType}</span>
            </div>
            <div style="display:grid;grid-template-columns:repeat(3,1fr);gap:16px;margin-bottom:16px;">
                <div style="text-align:center;padding:16px;background:var(--bg3);border-radius:10px;">
                    <div style="font-size:22px;font-weight:700;font-family:'Space Mono',monospace;">10</div>
                    <div style="font-size:11px;color:var(--text2);margin-top:4px;">Max Projects</div>
                </div>
                <div style="text-align:center;padding:16px;background:var(--bg3);border-radius:10px;">
                    <div style="font-size:22px;font-weight:700;font-family:'Space Mono',monospace;">∞</div>
                    <div style="font-size:11px;color:var(--text2);margin-top:4px;">Members</div>
                </div>
                <div style="text-align:center;padding:16px;background:var(--bg3);border-radius:10px;">
                    <div style="font-size:22px;font-weight:700;font-family:'Space Mono',monospace;">1 GB</div>
                    <div style="font-size:11px;color:var(--text2);margin-top:4px;">Storage</div>
                </div>
            </div>
            <div style="font-size:12px;color:var(--text2);">
                Need more? <a href="#" style="color:var(--accent);">Upgrade to Pro →</a>
            </div>
        </div>

        <%-- QUICK LINKS --%>
        <div class="card" style="margin-bottom:20px;">
            <div class="card-header"><span class="card-title">Quick Links</span></div>
            <div style="display:flex;flex-wrap:wrap;gap:10px;">
                <a href="/workspace/members" class="btn btn-ghost">👥 Manage Members</a>
                <a href="/workspace/invite"  class="btn btn-ghost">✉️ Invite &amp; Roles</a>
                <a href="/workspace/profile" class="btn btn-ghost">👤 My Profile</a>
                <a href="/analytics"         class="btn btn-ghost">📊 Analytics</a>
            </div>
        </div>

        <%-- DANGER ZONE --%>
        <div class="card" style="border-color:rgba(255,101,132,0.3);">
            <div class="card-header"><span class="card-title" style="color:var(--accent2);">Danger Zone</span></div>
            <div style="display:flex;justify-content:space-between;align-items:center;padding:16px 0;border-bottom:1px solid var(--border);">
                <div>
                    <div style="font-size:14px;font-weight:600;">Transfer Ownership</div>
                    <div style="font-size:12px;color:var(--text2);margin-top:2px;">Hand over this workspace to another member</div>
                </div>
                <button class="btn btn-ghost" onclick="document.getElementById('transferModal').classList.add('open')">Transfer</button>
            </div>
            <div style="display:flex;justify-content:space-between;align-items:center;padding:16px 0;">
                <div>
                    <div style="font-size:14px;font-weight:600;">Delete Workspace</div>
                    <div style="font-size:12px;color:var(--text2);margin-top:2px;">Permanently delete this workspace and all data</div>
                </div>
                <button class="btn btn-danger" onclick="document.getElementById('deleteModal').classList.add('open')">Delete</button>
            </div>
        </div>
    </div>
</div>

<script>
function confirmDelete() {
    var typed    = document.getElementById('confirmName').value.trim();
    var expected = '${tenant.name}';
    if (typed !== expected) { alert('Name does not match. Please type: ' + expected); return; }
    document.getElementById('deleteForm').submit();
}
document.querySelectorAll('.modal-overlay').forEach(o =>
    o.addEventListener('click', e => { if (e.target === o) o.classList.remove('open'); }));
</script>
</body>
</html>
