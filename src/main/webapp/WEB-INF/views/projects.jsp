<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:set var="currentPage" value="projects"/>
<!DOCTYPE html>
<html>
<head>
    <title>Nexus — Projects</title>
    <link href="https://fonts.googleapis.com/css2?family=Space+Mono:wght@400;700&family=DM+Sans:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="/css/nexus.css">
</head>
<body>
<%@ include file="sidebar.jsp" %>
<div class="main">
    <div class="topbar">
        <div>
            <div class="page-title">Projects</div>
            <div class="page-subtitle">Manage and track all workspace projects.</div>
        </div>
        <div class="topbar-actions">
            <button class="btn btn-primary" onclick="document.getElementById('addModal').classList.add('open')">+ New Project</button>
        </div>
    </div>

    <c:if test="${param.success=='created'}"><div class="alert alert-success">✅ Project created successfully!</div></c:if>
    <c:if test="${param.error!=null}"><div class="alert alert-error">❌ Error: ${param.error}</div></c:if>

    <!-- ADD PROJECT MODAL -->
    <div class="modal-overlay" id="addModal">
        <div class="modal">
            <div class="modal-title">🚀 Create New Project</div>
            <form action="/projects/add" method="post">
                <div class="form-group">
                    <label class="form-label">PROJECT NAME *</label>
                    <input type="text" name="name" class="form-input" placeholder="e.g. Q4 Marketing Campaign" required autofocus>
                </div>
                <div class="form-group">
                    <label class="form-label">DESCRIPTION</label>
                    <textarea name="description" class="form-textarea" rows="2" placeholder="What is this project about?" style="resize:vertical;"></textarea>
                </div>
                <div class="form-group">
                    <label class="form-label">DEADLINE</label>
                    <input type="date" name="deadline" class="form-input">
                </div>
                <div style="display:flex;gap:10px;justify-content:flex-end;margin-top:20px;">
                    <button type="button" class="btn btn-ghost" onclick="document.getElementById('addModal').classList.remove('open')">Cancel</button>
                    <button type="submit" class="btn btn-primary">Create Project →</button>
                </div>
            </form>
        </div>
    </div>

    <!-- PROJECTS TABLE -->
    <div class="card" style="padding:0;overflow:hidden;">
        <div style="padding:20px 24px;border-bottom:1px solid var(--border);display:flex;justify-content:space-between;align-items:center;">
            <span class="card-title">All Projects <span class="badge badge-purple" style="margin-left:8px;">${projects.size()}</span></span>
            <div style="display:flex;gap:8px;">
                <button class="btn btn-ghost btn-sm active" onclick="toggleView('table')" id="tableViewBtn">≡ Table</button>
                <button class="btn btn-ghost btn-sm" onclick="toggleView('grid')" id="gridViewBtn">⊞ Grid</button>
            </div>
        </div>

        <c:choose>
            <c:when test="${empty projects}">
                <div class="empty-state" style="padding:60px 20px;">
                    <div class="empty-icon">📁</div>
                    <p>No projects yet.</p>
                    <button class="btn btn-primary" style="margin-top:16px;" onclick="document.getElementById('addModal').classList.add('open')">+ New Project</button>
                </div>
            </c:when>
            <c:otherwise>
                <div id="tableView">
                    <table class="table">
                        <thead><tr><th>#</th><th>PROJECT</th><th>STATUS</th><th>DEADLINE</th><th>ACTIONS</th></tr></thead>
                        <tbody>
                            <c:forEach var="p" items="${projects}" varStatus="s">
                            <tr>
                                <td style="color:var(--text2);font-family:'Space Mono',monospace;font-size:12px;">${s.count}</td>
                                <td>
                                    <div style="display:flex;align-items:center;gap:12px;">
                                        <div style="width:36px;height:36px;border-radius:9px;background:rgba(108,99,255,0.15);display:flex;align-items:center;justify-content:center;flex-shrink:0;">📁</div>
                                        <div>
                                            <div style="font-weight:600;">${p.name}</div>
                                            <div style="font-size:11px;color:var(--text2);">#${p.id}</div>
                                        </div>
                                    </div>
                                </td>
                                <td>
                                    <c:choose>
                                        <c:when test="${p.status=='COMPLETED'}"><span class="badge badge-green">Completed</span></c:when>
                                        <c:when test="${p.status=='PAUSED'}"><span class="badge badge-gray">Paused</span></c:when>
                                        <c:when test="${p.status=='ARCHIVED'}"><span class="badge badge-gray">Archived</span></c:when>
                                        <c:otherwise><span class="badge badge-purple">Active</span></c:otherwise>
                                    </c:choose>
                                </td>
                                <td style="font-size:12px;color:var(--text2);">
                                    <c:choose>
                                        <c:when test="${p.deadline!=null}">${p.deadline.toLocalDate()}</c:when>
                                        <c:otherwise>—</c:otherwise>
                                    </c:choose>
                                </td>
                                <td>
                                    <div style="display:flex;gap:6px;">
                                        <a href="/projects/view/${p.id}" class="btn btn-ghost btn-sm">View →</a>
                                        <form action="/projects/delete/${p.id}" method="post" onsubmit="return confirm('Delete project?')">
                                            <button class="btn btn-danger btn-sm">Del</button>
                                        </form>
                                    </div>
                                </td>
                            </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </div>

                <div id="gridView" style="display:none;padding:20px;">
                    <div style="display:grid;grid-template-columns:repeat(auto-fill,minmax(260px,1fr));gap:16px;">
                        <c:forEach var="p" items="${projects}">
                        <div class="card fade-in" style="cursor:pointer;transition:all 0.2s;"
                             onmouseover="this.style.borderColor='var(--accent)';this.style.transform='translateY(-2px)'"
                             onmouseout="this.style.borderColor='var(--border)';this.style.transform='translateY(0)'"
                             onclick="location.href='/projects/view/${p.id}'">
                            <div style="display:flex;justify-content:space-between;align-items:flex-start;margin-bottom:12px;">
                                <div style="font-size:28px;">📁</div>
                                <c:choose>
                                    <c:when test="${p.status=='COMPLETED'}"><span class="badge badge-green">Done</span></c:when>
                                    <c:when test="${p.status=='PAUSED'}"><span class="badge badge-gray">Paused</span></c:when>
                                    <c:otherwise><span class="badge badge-purple">Active</span></c:otherwise>
                                </c:choose>
                            </div>
                            <div style="font-weight:700;font-size:15px;margin-bottom:4px;">${p.name}</div>
                            <div style="font-size:11px;color:var(--text2);margin-bottom:12px;">#${p.id}</div>
                            <c:if test="${not empty p.description}">
                                <div style="font-size:12px;color:var(--text2);margin-bottom:12px;line-height:1.4;overflow:hidden;max-height:40px;">${p.description}</div>
                            </c:if>
                        </div>
                        </c:forEach>
                    </div>
                </div>
            </c:otherwise>
        </c:choose>
    </div>
</div>

<script>
document.querySelectorAll('.modal-overlay').forEach(o => o.addEventListener('click', e => { if(e.target===o) o.classList.remove('open'); }));
if(window.location.search.includes('new=true')) document.getElementById('addModal').classList.add('open');

function toggleView(type) {
    document.getElementById('tableView').style.display = type==='table'?'block':'none';
    document.getElementById('gridView').style.display = type==='grid'?'block':'none';
    document.getElementById('tableViewBtn').classList.toggle('active', type==='table');
    document.getElementById('gridViewBtn').classList.toggle('active', type==='grid');
}
</script>
</body>
</html>
