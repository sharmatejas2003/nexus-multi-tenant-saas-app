<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:set var="currentPage" value="invite"/>
<!DOCTYPE html>
<html>
<head>
    <title>Nexus — Invite Members</title>
    <link href="https://fonts.googleapis.com/css2?family=Space+Mono:wght@400;700&family=DM+Sans:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="/css/nexus.css">
</head>
<body>

<%@ include file="sidebar.jsp" %>

<div class="main">
    <div class="topbar">
        <div>
            <div class="page-title">Invite People</div>
            <div class="page-subtitle">Grow your team by sharing an invite link.</div>
        </div>
    </div>

    <div style="max-width:620px;">

        <!-- INVITE LINK CARD -->
        <div class="card" style="margin-bottom:20px;">
            <div class="card-header">
                <span class="card-title">Shareable Invite Link</span>
                <span class="badge badge-green">Active</span>
            </div>
            <p style="font-size:13px;color:var(--text2);margin-bottom:16px;">Anyone with this link can join your workspace as a Member.</p>

            <div style="display:flex;gap:0;margin-bottom:20px;">
                <input type="text" id="inviteLink" value="${inviteLink}" readonly
                    class="form-input" style="border-radius:8px 0 0 8px;font-size:12px;font-family:'Space Mono',monospace;background:var(--bg3);">
                <button onclick="copyLink()" class="btn btn-primary" style="border-radius:0 8px 8px 0;white-space:nowrap;">Copy Link</button>
            </div>

            <div id="copiedMsg" style="display:none;color:var(--accent3);font-size:13px;margin-bottom:12px;">✅ Copied to clipboard!</div>

            <div style="display:flex;gap:10px;flex-wrap:wrap;">
    <a href="https://api.whatsapp.com/send?text=Join our Nexus workspace: ${inviteLink}"
       target="_blank" class="btn btn-ghost" style="font-size:13px;gap:8px;">
        <svg width="18" height="18" viewBox="0 0 24 24" fill="#25D366">
            <path d="M17.472 14.382c-.297-.149-1.758-.867-2.03-.967-.273-.099-.471-.148-.67.15-.197.297-.767.966-.94 1.164-.173.199-.347.223-.644.075-.297-.15-1.255-.463-2.39-1.475-.883-.788-1.48-1.761-1.653-2.059-.173-.297-.018-.458.13-.606.134-.133.298-.347.446-.52.149-.174.198-.298.298-.497.099-.198.05-.371-.025-.52-.075-.149-.669-1.612-.916-2.207-.242-.579-.487-.5-.669-.51-.173-.008-.371-.01-.57-.01-.198 0-.52.074-.792.372-.272.297-1.04 1.016-1.04 2.479 0 1.462 1.065 2.875 1.213 3.074.149.198 2.096 3.2 5.077 4.487.709.306 1.262.489 1.694.625.712.227 1.36.195 1.871.118.571-.085 1.758-.719 2.006-1.413.248-.694.248-1.289.173-1.413-.074-.124-.272-.198-.57-.347m-5.421 7.403h-.004a9.87 9.87 0 01-5.031-1.378l-.361-.214-3.741.982.998-3.648-.235-.374a9.86 9.86 0 01-1.51-5.26c.001-5.45 4.436-9.884 9.888-9.884 2.64 0 5.122 1.03 6.988 2.898a9.825 9.825 0 012.893 6.994c-.003 5.45-4.437 9.884-9.885 9.884m8.413-18.297A11.815 11.815 0 0012.05 0C5.495 0 .16 5.335.157 11.892c0 2.096.547 4.142 1.588 5.945L.057 24l6.305-1.654a11.882 11.882 0 005.683 1.448h.005c6.554 0 11.89-5.335 11.893-11.893a11.821 11.821 0 00-3.48-8.413z"/>
        </svg>
        WhatsApp
    </a>
    <a href="mailto:?subject=Join our workspace on Nexus&body=Click this link to join: ${inviteLink}"
   class="btn btn-ghost" style="font-size:13px;gap:8px;">
    <svg width="18" height="18" viewBox="0 0 24 24">
        <path d="M24 5.457v13.909c0 .904-.732 1.636-1.636 1.636h-3.819V11.73L12 16.64l-6.545-4.91v9.273H1.636A1.636 1.636 0 0 1 0 19.366V5.457c0-2.023 2.309-3.178 3.927-1.964L5.455 4.64 12 9.548l6.545-4.91 1.528-1.145C21.69 2.28 24 3.434 24 5.457z" fill="#EA4335"/>
        <path d="M0 5.457c0-2.023 2.309-3.178 3.927-1.964L12 9.548V24H1.636A1.636 1.636 0 0 1 0 22.364V5.457z" fill="#34A853"/>
        <path d="M24 5.457c0-2.023-2.309-3.178-3.927-1.964L12 9.548V24h10.364A1.636 1.636 0 0 0 24 22.364V5.457z" fill="#4285F4"/>
        <path d="M0 5.457c0-2.023 2.309-3.178 3.927-1.964L12 9.548 20.073 3.493C21.69 2.28 24 3.434 24 5.457L12 14.18 0 5.457z" fill="#FBBC05"/>
    </svg>
    Gmail
</a>
</div>
        </div>

        <!-- GENERATE BY EMAIL -->
        <div class="card" style="margin-bottom:20px;">
            <div class="card-header">
                <span class="card-title">Generate Invitation Link</span>
            </div>
            <p style="font-size:13px;color:var(--text2);margin-bottom:16px;">Generate a personal invite link for a specific email address.</p>
            <div style="display:flex;gap:10px;">
                <input type="email" id="emailInput" class="form-input" placeholder="colleague@company.com">
                <button onclick="generateForEmail()" class="btn btn-primary" style="white-space:nowrap;">Generate Link</button>
            </div>
            <div id="generatedLink" style="display:none;margin-top:16px;padding:14px;background:var(--bg3);border-radius:8px;font-size:12px;font-family:'Space Mono',monospace;color:var(--accent);word-break:break-all;"></div>
        </div>

        <!-- PERMISSIONS INFO -->
        <div class="card">
            <div class="card-header">
                <span class="card-title">Role Permissions</span>
            </div>
            <table class="table">
                <thead>
                    <tr><th>PERMISSION</th><th>MEMBER</th><th>ADMIN</th><th>OWNER</th></tr>
                </thead>
                <tbody>
                    <tr><td>View Projects</td><td>✅</td><td>✅</td><td>✅</td></tr>
                    <tr><td>Create Projects</td><td>❌</td><td>✅</td><td>✅</td></tr>
                    <tr><td>Manage Members</td><td>❌</td><td>✅</td><td>✅</td></tr>
                    <tr><td>Billing & Plans</td><td>❌</td><td>❌</td><td>✅</td></tr>
                    <tr><td>Delete Workspace</td><td>❌</td><td>❌</td><td>✅</td></tr>
                </tbody>
            </table>
        </div>

    </div>
</div>

<script>
function copyLink() {
    var el = document.getElementById("inviteLink");
    navigator.clipboard.writeText(el.value);
    var msg = document.getElementById("copiedMsg");
    msg.style.display = "block";
    setTimeout(() => msg.style.display = "none", 3000);
}

function generateForEmail() {
    var email = document.getElementById("emailInput").value;
    if (!email) return;
    fetch("/workspace/invite/generate", {
        method: "POST",
        headers: {"Content-Type": "application/x-www-form-urlencoded"},
        body: "email=" + encodeURIComponent(email)
    }).then(r => r.text()).then(link => {
        var el = document.getElementById("generatedLink");
        el.style.display = "block";
        el.textContent = link;
    });
}
</script>

</body>
</html>
