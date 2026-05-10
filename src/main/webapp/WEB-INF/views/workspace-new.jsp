<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:set var="currentPage" value="settings"/>
<!DOCTYPE html>
<html>
<head>
    <title>Nexus — Create New Workspace</title>
    <link href="https://fonts.googleapis.com/css2?family=Space+Mono:wght@400;700&family=DM+Sans:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="/css/nexus.css">
    <style>
        .mode-tabs{display:grid;grid-template-columns:1fr 1fr;border:1px solid var(--border);border-radius:10px;overflow:hidden;margin-bottom:20px;}
        .mode-tab{padding:14px;text-align:center;cursor:pointer;font-size:13px;font-weight:600;color:var(--text2);background:var(--bg2);border:none;transition:all 0.2s;font-family:'DM Sans',sans-serif;}
        .mode-tab.active{background:var(--accent);color:white;}
        .feature-box{border:1px solid var(--border);border-radius:10px;padding:14px;margin-bottom:16px;font-size:12px;color:var(--text2);line-height:2;}
        .feature-box.personal{border-color:rgba(67,233,123,0.3);background:rgba(67,233,123,0.05);}
        .feature-box.org{border-color:rgba(108,99,255,0.3);background:rgba(108,99,255,0.05);}
    </style>
</head>
<body>
<%@ include file="sidebar.jsp" %>

<div class="main">
    <div class="topbar">
        <div>
            <a href="/dashboard" class="btn btn-ghost" style="margin-bottom:8px;font-size:12px;padding:6px 12px;">← Back</a>
            <div class="page-title">Create New Workspace</div>
            <div class="page-subtitle">You can have multiple workspaces — personal and organizational.</div>
        </div>
    </div>

    <c:if test="${param.error != null}">
        <div class="alert alert-error" style="margin-bottom:20px;">❌ Something went wrong. Please try again.</div>
    </c:if>

    <div style="max-width:520px;">
        <div class="card">
            <div class="card-header">
                <span class="card-title">New Workspace</span>
            </div>

            <div class="mode-tabs">
                <button type="button" class="mode-tab active" id="tabPersonal" onclick="selectMode('PERSONAL')">
                    🧑 Personal
                </button>
                <button type="button" class="mode-tab" id="tabOrg" onclick="selectMode('ORGANIZATION')">
                    🏢 Organization
                </button>
            </div>

            <div class="feature-box personal" id="featPersonal">
                ✅ Private notes &amp; tasks &nbsp;·&nbsp; ✅ Personal kanban &nbsp;·&nbsp; ✅ File vault
            </div>
            <div class="feature-box org" id="featOrg" style="display:none;">
                🚀 Team projects &nbsp;·&nbsp; 👥 Unlimited members &nbsp;·&nbsp; 🔔 Notifications &nbsp;·&nbsp; 📊 Analytics
            </div>

            <form action="/workspace/create-new" method="post">
                <input type="hidden" name="workspaceType" id="wsTypeInput" value="PERSONAL">

                <div class="form-group">
                    <label class="form-label" id="wsLabel">WORKSPACE NAME</label>
                    <input type="text" name="workspaceName" id="wsNameInput"
                           class="form-input" placeholder="e.g. My Side Projects" required autofocus>
                </div>

                <button type="submit" class="btn btn-primary" id="submitBtn" style="width:100%;">
                    Create Personal Workspace →
                </button>
            </form>

            <div style="margin-top:16px;padding:14px;background:var(--bg3);border-radius:8px;font-size:12px;color:var(--text2);">
                💡 You can switch between workspaces anytime from the sidebar.
                Your existing workspace and data stay intact.
            </div>
        </div>
    </div>
</div>

<script>
function selectMode(mode) {
    const isPersonal = mode === 'PERSONAL';
    document.getElementById('wsTypeInput').value = mode;
    document.getElementById('tabPersonal').classList.toggle('active', isPersonal);
    document.getElementById('tabOrg').classList.toggle('active', !isPersonal);
    document.getElementById('featPersonal').style.display = isPersonal ? '' : 'none';
    document.getElementById('featOrg').style.display = isPersonal ? 'none' : '';
    document.getElementById('wsLabel').textContent = isPersonal ? 'WORKSPACE NAME' : 'ORGANIZATION NAME';
    document.getElementById('wsNameInput').placeholder = isPersonal ? 'e.g. My Side Projects' : 'e.g. Acme Corp';
    document.getElementById('submitBtn').textContent = isPersonal
        ? 'Create Personal Workspace →' : 'Create Organization Workspace →';
}
</script>
</body>
</html>
