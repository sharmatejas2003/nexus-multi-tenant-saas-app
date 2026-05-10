<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<c:set var="currentPage" value="projects"/>
<!DOCTYPE html>
<html>
<head>
    <title>Nexus — ${project.name}</title>
    <link href="https://fonts.googleapis.com/css2?family=Space+Mono:wght@400;700&family=DM+Sans:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="/css/nexus.css">
    <style>
        .kanban-board { display:grid; grid-template-columns:repeat(4,1fr); gap:14px; margin-bottom:24px; }
        .kanban-col { background:var(--bg3); border-radius:12px; padding:14px; min-height:200px; }
        .kanban-col-header { font-size:11px; font-weight:700; letter-spacing:1px; color:var(--text2); margin-bottom:12px; display:flex; justify-content:space-between; align-items:center; }
        .kanban-card {
            background:var(--bg2); border:1px solid var(--border); border-radius:10px;
            padding:12px; margin-bottom:8px; cursor:pointer; transition:all 0.2s;
        }
        .kanban-card:hover { border-color:var(--accent); transform:translateY(-1px); }
        .kanban-card-title { font-size:13px; font-weight:600; margin-bottom:6px; }
        .priority-dot { width:6px; height:6px; border-radius:50%; display:inline-block; margin-right:4px; }
        .p-low { background:#43e97b; }
        .p-medium { background:#f9ca24; }
        .p-high { background:#ff6584; }
        .p-critical { background:#ff0000; }
        .file-card {
            display:flex; align-items:center; gap:12px; padding:10px;
            background:var(--bg3); border-radius:8px; margin-bottom:8px;
            border:1px solid transparent; transition:border-color 0.2s;
        }
        .file-card:hover { border-color:var(--border); }
        .drop-zone {
            border:2px dashed var(--border); border-radius:10px; padding:24px;
            text-align:center; color:var(--text2); font-size:13px;
            transition:all 0.2s; cursor:pointer;
        }
        .drop-zone:hover, .drop-zone.drag-over { border-color:var(--accent); background:rgba(108,99,255,0.05); color:var(--accent); }
        .input { background:var(--bg3); border:1px solid var(--border); color:var(--text); padding:10px 14px; border-radius:8px; font-size:14px; font-family:'DM Sans',sans-serif; width:100%; margin-bottom:10px; transition:border-color 0.2s; }
        .input:focus { outline:none; border-color:var(--accent); box-shadow:0 0 0 3px rgba(108,99,255,0.15); }
        .tab-btn { padding:8px 16px; border-radius:8px; font-size:13px; font-weight:600; cursor:pointer; border:none; background:transparent; color:var(--text2); transition:all 0.2s; }
        .tab-btn.active { background:var(--bg3); color:var(--text); }
    </style>
</head>
<body>

<%@ include file="sidebar.jsp" %>

<div class="main">
    <div class="topbar">
        <div>
            <a href="/projects" class="btn btn-ghost" style="margin-bottom:8px;font-size:12px;padding:6px 12px;">← Back to Projects</a>
            <div class="page-title">${project.name}</div>
            <div class="page-subtitle">
                Project #${project.id} &nbsp;·&nbsp;
                <c:choose>
                    <c:when test="${project.status == 'COMPLETED'}"><span class="badge badge-green">Completed</span></c:when>
                    <c:when test="${project.status == 'PAUSED'}"><span class="badge badge-gray">Paused</span></c:when>
                    <c:otherwise><span class="badge badge-purple">Active</span></c:otherwise>
                </c:choose>
            </div>
        </div>
        <div class="topbar-actions">
            <button class="btn btn-ghost" onclick="document.getElementById('addTaskModal').classList.add('open')">+ Add Task</button>
            <button class="btn btn-ghost" onclick="document.getElementById('uploadModal').classList.add('open')">📎 Upload File</button>
        </div>
    </div>

    <!-- STATS ROW -->
    <div style="display:grid;grid-template-columns:repeat(5,1fr);gap:14px;margin-bottom:24px;">
        <div class="stat-card purple">
            <div class="stat-label">TOTAL TASKS</div>
            <div class="stat-value">${tasks.size()}</div>
        </div>
        <div class="stat-card green">
            <div class="stat-label">DONE</div>
            <div class="stat-value">${tasksDone}</div>
        </div>
        <div class="stat-card blue">
            <div class="stat-label">IN PROGRESS</div>
            <div class="stat-value">${tasksInProgress}</div>
        </div>
        <div class="stat-card red">
            <div class="stat-label">OVERDUE</div>
            <div class="stat-value">${tasksOverdue}</div>
        </div>
        <div class="stat-card purple">
            <div class="stat-label">PROGRESS</div>
            <div class="stat-value" style="font-size:24px;">${taskProgress}%</div>
            <div class="progress-bar" style="margin-top:8px;"><div class="progress-fill" style="width:${taskProgress}%;"></div></div>
        </div>
    </div>

    <!-- TABS -->
    <div style="display:flex;gap:4px;margin-bottom:20px;background:var(--bg2);border:1px solid var(--border);border-radius:10px;padding:4px;width:fit-content;">
        <button class="tab-btn active" id="tabKanban" onclick="showTab('kanban')">Kanban Board</button>
        <button class="tab-btn" id="tabList" onclick="showTab('list')">List View</button>
        <button class="tab-btn" id="tabFiles" onclick="showTab('files')">Files (${attachments.size()})</button>
        <button class="tab-btn" id="tabInfo" onclick="showTab('info')">Info</button>
    </div>

    <!-- KANBAN BOARD -->
    <div id="tabContent-kanban">
        <div class="kanban-board">
            <c:set var="colStatuses" value="TODO,IN_PROGRESS,IN_REVIEW,DONE" />

            <!-- TODO -->
            <div class="kanban-col">
                <div class="kanban-col-header">
                    <span>TODO</span>
                    <span class="badge badge-gray" style="font-size:10px;">
                        <c:set var="c" value="0"/>
                        <c:forEach var="t" items="${tasks}"><c:if test="${t.status == 'TODO'}"><c:set var="c" value="${c+1}"/></c:if></c:forEach>
                        ${c}
                    </span>
                </div>
                <c:forEach var="task" items="${tasks}">
                    <c:if test="${task.status == 'TODO'}">
                        <div class="kanban-card" onclick="openEditModal(${task.id},'${task.title}','${task.status}','${task.priority}')">
                            <div class="kanban-card-title">${task.title}</div>
                            <div style="display:flex;align-items:center;gap:6px;flex-wrap:wrap;">
                                <span class="priority-dot p-${task.priority.toLowerCase()}"></span>
                                <span style="font-size:10px;color:var(--text2);">${task.priority}</span>
                                <c:if test="${task.assignedUsername != null}">
                                    <span style="margin-left:auto;font-size:10px;background:rgba(108,99,255,0.1);color:var(--accent);padding:2px 6px;border-radius:4px;">${task.assignedUsername.substring(0,1).toUpperCase()}</span>
                                </c:if>
                            </div>
                        </div>
                    </c:if>
                </c:forEach>
                <button class="btn btn-ghost" style="width:100%;font-size:11px;padding:6px;margin-top:4px;" onclick="document.getElementById('addTaskModal').classList.add('open')">+ Add</button>
            </div>

            <!-- IN_PROGRESS -->
            <div class="kanban-col">
                <div class="kanban-col-header">
                    <span>IN PROGRESS</span>
                    <span class="badge badge-purple" style="font-size:10px;">
                        <c:set var="c2" value="0"/>
                        <c:forEach var="t" items="${tasks}"><c:if test="${t.status == 'IN_PROGRESS'}"><c:set var="c2" value="${c2+1}"/></c:if></c:forEach>
                        ${c2}
                    </span>
                </div>
                <c:forEach var="task" items="${tasks}">
                    <c:if test="${task.status == 'IN_PROGRESS'}">
                        <div class="kanban-card" onclick="openEditModal(${task.id},'${task.title}','${task.status}','${task.priority}')">
                            <div class="kanban-card-title">${task.title}</div>
                            <div style="display:flex;align-items:center;gap:6px;">
                                <span class="priority-dot p-${task.priority.toLowerCase()}"></span>
                                <span style="font-size:10px;color:var(--text2);">${task.priority}</span>
                                <c:if test="${task.assignedUsername != null}">
                                    <span style="margin-left:auto;font-size:10px;background:rgba(108,99,255,0.1);color:var(--accent);padding:2px 6px;border-radius:4px;">${task.assignedUsername.substring(0,1).toUpperCase()}</span>
                                </c:if>
                            </div>
                        </div>
                    </c:if>
                </c:forEach>
            </div>

            <!-- IN_REVIEW / OVERDUE -->
            <div class="kanban-col">
                <div class="kanban-col-header">
                    <span>IN REVIEW</span>
                    <span class="badge badge-gray" style="font-size:10px;">
                        <c:set var="c3" value="0"/>
                        <c:forEach var="t" items="${tasks}"><c:if test="${t.status == 'IN_REVIEW' || t.status == 'OVERDUE'}"><c:set var="c3" value="${c3+1}"/></c:if></c:forEach>
                        ${c3}
                    </span>
                </div>
                <c:forEach var="task" items="${tasks}">
                    <c:if test="${task.status == 'IN_REVIEW' || task.status == 'OVERDUE'}">
                        <div class="kanban-card" style="${task.status == 'OVERDUE' ? 'border-color:rgba(255,101,132,0.4);' : ''}" onclick="openEditModal(${task.id},'${task.title}','${task.status}','${task.priority}')">
                            <div class="kanban-card-title">${task.title}</div>
                            <div style="display:flex;align-items:center;gap:6px;">
                                <c:if test="${task.status == 'OVERDUE'}"><span style="font-size:9px;color:var(--accent2);">⚠️ OVERDUE</span></c:if>
                                <c:if test="${task.status != 'OVERDUE'}"><span style="font-size:10px;color:var(--text2);">${task.priority}</span></c:if>
                            </div>
                        </div>
                    </c:if>
                </c:forEach>
            </div>

            <!-- DONE -->
            <div class="kanban-col">
                <div class="kanban-col-header">
                    <span>DONE</span>
                    <span class="badge badge-green" style="font-size:10px;">
                        <c:set var="c4" value="0"/>
                        <c:forEach var="t" items="${tasks}"><c:if test="${t.status == 'DONE'}"><c:set var="c4" value="${c4+1}"/></c:if></c:forEach>
                        ${c4}
                    </span>
                </div>
                <c:forEach var="task" items="${tasks}">
                    <c:if test="${task.status == 'DONE'}">
                        <div class="kanban-card" style="opacity:0.6;" onclick="openEditModal(${task.id},'${task.title}','${task.status}','${task.priority}')">
                            <div class="kanban-card-title" style="text-decoration:line-through;">${task.title}</div>
                            <span style="font-size:10px;color:var(--accent3);">✓ Completed</span>
                        </div>
                    </c:if>
                </c:forEach>
            </div>
        </div>
    </div>

    <!-- LIST VIEW -->
    <div id="tabContent-list" style="display:none;">
        <div class="card" style="padding:0;overflow:hidden;">
            <table class="table">
                <thead><tr><th>TASK</th><th>STATUS</th><th>PRIORITY</th><th>ASSIGNED TO</th><th>DUE DATE</th><th>ACTIONS</th></tr></thead>
                <tbody>
                    <c:forEach var="task" items="${tasks}">
                    <tr>
                        <td style="font-weight:600;">${task.title}</td>
                        <td>
                            <c:choose>
                                <c:when test="${task.status == 'DONE'}"><span class="badge badge-green">Done</span></c:when>
                                <c:when test="${task.status == 'IN_PROGRESS'}"><span class="badge badge-purple">In Progress</span></c:when>
                                <c:when test="${task.status == 'OVERDUE'}"><span class="badge badge-red">Overdue</span></c:when>
                                <c:otherwise><span class="badge badge-gray">${task.status}</span></c:otherwise>
                            </c:choose>
                        </td>
                        <td>
                            <span class="priority-dot p-${task.priority.toLowerCase()}"></span>
                            <span style="font-size:13px;">${task.priority}</span>
                        </td>
                        <td style="font-size:13px;color:var(--text2);">${task.assignedUsername != null ? task.assignedUsername : '—'}</td>
                        <td style="font-size:12px;color:var(--text2);">${task.dueDate != null ? task.dueDate : '—'}</td>
                        <td>
                            <div style="display:flex;gap:6px;">
                                <button class="btn btn-ghost" style="padding:4px 10px;font-size:11px;"
                                    onclick="openEditModal(${task.id},'${task.title}','${task.status}','${task.priority}')">Edit</button>
                                <form action="/tasks/delete/${task.id}" method="post">
                                    <input type="hidden" name="projectId" value="${project.id}"/>
                                    <button class="btn btn-danger" style="padding:4px 10px;font-size:11px;">Del</button>
                                </form>
                            </div>
                        </td>
                    </tr>
                    </c:forEach>
                    <c:if test="${empty tasks}">
                        <tr><td colspan="6" style="text-align:center;color:var(--text2);padding:40px;">No tasks yet.</td></tr>
                    </c:if>
                </tbody>
            </table>
        </div>
    </div>

    <!-- FILES TAB -->
    <div id="tabContent-files" style="display:none;">
        <div class="grid-2">
            <!-- UPLOAD SECTION -->
            <div class="card">
                <div class="card-header"><span class="card-title">Upload Files</span></div>
                <form action="/files/upload" method="post" enctype="multipart/form-data">
                    <input type="hidden" name="entityType" value="PROJECT"/>
                    <input type="hidden" name="entityId" value="${project.id}"/>
                    <input type="hidden" name="redirectTo" value="/projects/view/${project.id}?tab=files"/>
                    <div class="drop-zone" id="dropZone" onclick="document.getElementById('fileInput').click()">
                        <div style="font-size:32px;margin-bottom:8px;">📎</div>
                        <div>Click to upload or drag & drop</div>
                        <div style="font-size:11px;margin-top:4px;">Max 20MB per file</div>
                    </div>
                    <input type="file" id="fileInput" name="file" style="display:none;" onchange="handleFileSelect(this)">
                    <div id="selectedFile" style="display:none;margin-top:12px;padding:10px;background:var(--bg3);border-radius:8px;font-size:13px;"></div>
                    <button type="submit" class="btn btn-primary" style="width:100%;margin-top:12px;">Upload</button>
                </form>
            </div>

            <!-- FILES LIST -->
            <div class="card">
                <div class="card-header">
                    <span class="card-title">Project Files</span>
                    <span class="badge badge-purple">${attachments.size()}</span>
                </div>
                <c:choose>
                    <c:when test="${empty attachments}">
                        <div class="empty-state" style="padding:30px 20px;">
                            <div class="empty-icon">📂</div>
                            <p>No files uploaded yet.</p>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <c:forEach var="f" items="${attachments}">
                        <div class="file-card">
                            <span style="font-size:24px;">${f.fileIcon}</span>
                            <div style="flex:1;min-width:0;">
                                <div style="font-size:13px;font-weight:600;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;">${f.originalName}</div>
                                <div style="font-size:11px;color:var(--text2);">${f.formattedSize} · ${f.uploadedByUsername}</div>
                            </div>
                            <div style="display:flex;gap:6px;">
                                <a href="/files/preview/${f.id}" target="_blank" class="btn btn-ghost" style="padding:4px 8px;font-size:11px;">View</a>
                                <a href="/files/download/${f.id}" class="btn btn-ghost" style="padding:4px 8px;font-size:11px;">⬇</a>
                                <form action="/files/delete/${f.id}" method="post" onsubmit="return confirm('Delete file?')">
                                    <input type="hidden" name="redirectTo" value="/projects/view/${project.id}?tab=files"/>
                                    <button class="btn btn-danger" style="padding:4px 8px;font-size:11px;">✕</button>
                                </form>
                            </div>
                        </div>
                        </c:forEach>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>
    </div>

    <!-- INFO TAB -->
    <div id="tabContent-info" style="display:none;">
        <div class="grid-2">
            <div class="card">
                <div class="card-title" style="margin-bottom:16px;">Edit Project</div>
                <form action="/projects/update/${project.id}" method="post">
                    <div style="margin-bottom:12px;">
                        <label class="form-label">PROJECT NAME</label>
                        <input type="text" name="name" class="form-input" value="${project.name}" required>
                    </div>
                    <div style="margin-bottom:12px;">
                        <label class="form-label">DESCRIPTION</label>
                        <textarea name="description" class="form-textarea" rows="3">${project.description}</textarea>
                    </div>
                    <div style="margin-bottom:20px;">
                        <label class="form-label">STATUS</label>
                        <select name="status" class="form-select">
                            <option value="ACTIVE" ${project.status == 'ACTIVE' ? 'selected' : ''}>Active</option>
                            <option value="PAUSED" ${project.status == 'PAUSED' ? 'selected' : ''}>Paused</option>
                            <option value="COMPLETED" ${project.status == 'COMPLETED' ? 'selected' : ''}>Completed</option>
                            <option value="ARCHIVED" ${project.status == 'ARCHIVED' ? 'selected' : ''}>Archived</option>
                        </select>
                    </div>
                    <button type="submit" class="btn btn-primary">Save Changes</button>
                </form>
            </div>
            <div class="card" style="border-color:rgba(255,101,132,0.3);">
                <div class="card-title" style="color:var(--accent2);margin-bottom:16px;">Danger Zone</div>
                <form action="/projects/delete/${project.id}" method="post"
                      onsubmit="return confirm('Delete this project and all tasks?')">
                    <button type="submit" class="btn btn-danger" style="width:100%;justify-content:center;">
                        🗑 Delete Project
                    </button>
                </form>
            </div>
        </div>
    </div>
</div>

<!-- ADD TASK MODAL -->
<div class="modal-overlay" id="addTaskModal">
    <div class="modal" style="width:520px;">
        <div class="modal-title">➕ Add New Task</div>
        <form action="/tasks/save" method="post" enctype="multipart/form-data">
            <input type="hidden" name="projectId" value="${project.id}"/>
            <div style="margin-bottom:12px;">
                <label class="form-label">TASK TITLE *</label>
                <input name="title" class="form-input" placeholder="What needs to be done?" required autofocus/>
            </div>
            <div style="margin-bottom:12px;">
                <label class="form-label">DESCRIPTION</label>
                <textarea name="description" class="form-textarea" rows="2" placeholder="Additional details..."></textarea>
            </div>
            <div style="display:grid;grid-template-columns:1fr 1fr;gap:12px;margin-bottom:12px;">
                <div>
                    <label class="form-label">STATUS</label>
                    <select name="status" class="form-select">
                        <option value="TODO">TODO</option>
                        <option value="IN_PROGRESS">IN PROGRESS</option>
                        <option value="IN_REVIEW">IN REVIEW</option>
                        <option value="DONE">DONE</option>
                    </select>
                </div>
                <div>
                    <label class="form-label">PRIORITY</label>
                    <select name="priority" class="form-select">
                        <option value="LOW">LOW</option>
                        <option value="MEDIUM" selected>MEDIUM</option>
                        <option value="HIGH">HIGH</option>
                        <option value="CRITICAL">CRITICAL</option>
                    </select>
                </div>
            </div>
            <div style="display:grid;grid-template-columns:1fr 1fr;gap:12px;margin-bottom:12px;">
                <div>
                    <label class="form-label">ASSIGN TO</label>
                    <select name="assignedTo" class="form-select">
                        <option value="">— Unassigned —</option>
                        <c:forEach var="m" items="${workspaceMembers}">
                            <option value="${m.id}">${m.username}</option>
                        </c:forEach>
                    </select>
                </div>
                <div>
                    <label class="form-label">DUE DATE</label>
                    <input type="datetime-local" name="dueDate" class="form-input"/>
                </div>
            </div>
            <div style="margin-bottom:16px;">
                <label class="form-label">ATTACH FILES</label>
                <input type="file" name="files" multiple class="form-input" style="padding:6px;">
            </div>
            <div style="display:flex;gap:10px;justify-content:flex-end;">
                <button type="button" class="btn btn-ghost" onclick="document.getElementById('addTaskModal').classList.remove('open')">Cancel</button>
                <button type="submit" class="btn btn-primary">Add Task</button>
            </div>
        </form>
    </div>
</div>

<!-- EDIT TASK MODAL -->
<div class="modal-overlay" id="editTaskModal">
    <div class="modal">
        <div class="modal-title">✏️ Edit Task</div>
        <form action="/tasks/update" method="post">
            <input type="hidden" name="id" id="editId"/>
            <input type="hidden" name="projectId" value="${project.id}"/>
            <div style="margin-bottom:12px;">
                <label class="form-label">TITLE</label>
                <input name="title" id="editTitle" class="form-input" required/>
            </div>
            <div style="display:grid;grid-template-columns:1fr 1fr;gap:12px;margin-bottom:12px;">
                <div>
                    <label class="form-label">STATUS</label>
                    <select name="status" id="editStatus" class="form-select">
                        <option value="TODO">TODO</option>
                        <option value="IN_PROGRESS">IN PROGRESS</option>
                        <option value="IN_REVIEW">IN REVIEW</option>
                        <option value="DONE">DONE</option>
                    </select>
                </div>
                <div>
                    <label class="form-label">PRIORITY</label>
                    <select name="priority" id="editPriority" class="form-select">
                        <option value="LOW">LOW</option>
                        <option value="MEDIUM">MEDIUM</option>
                        <option value="HIGH">HIGH</option>
                        <option value="CRITICAL">CRITICAL</option>
                    </select>
                </div>
            </div>
            <div style="display:flex;gap:10px;justify-content:flex-end;margin-top:16px;">
                <button type="button" class="btn btn-ghost" onclick="document.getElementById('editTaskModal').classList.remove('open')">Cancel</button>
                <button type="submit" class="btn btn-primary">Update Task</button>
            </div>
        </form>
    </div>
</div>

<!-- UPLOAD MODAL -->
<div class="modal-overlay" id="uploadModal">
    <div class="modal">
        <div class="modal-title">📎 Upload File</div>
        <form action="/files/upload" method="post" enctype="multipart/form-data">
            <input type="hidden" name="entityType" value="PROJECT"/>
            <input type="hidden" name="entityId" value="${project.id}"/>
            <input type="hidden" name="redirectTo" value="/projects/view/${project.id}"/>
            <div style="margin-bottom:16px;">
                <input type="file" name="file" class="form-input" style="padding:8px;" required>
            </div>
            <div style="display:flex;gap:10px;justify-content:flex-end;">
                <button type="button" class="btn btn-ghost" onclick="document.getElementById('uploadModal').classList.remove('open')">Cancel</button>
                <button type="submit" class="btn btn-primary">Upload</button>
            </div>
        </form>
    </div>
</div>

<script>
function showTab(name) {
    ['kanban','list','files','info'].forEach(t => {
        document.getElementById('tabContent-' + t).style.display = t === name ? 'block' : 'none';
        document.getElementById('tab' + t.charAt(0).toUpperCase() + t.slice(1)).classList.toggle('active', t === name);
    });
}

function openEditModal(id, title, status, priority) {
    document.getElementById('editTaskModal').classList.add('open');
    document.getElementById('editId').value = id;
    document.getElementById('editTitle').value = title;
    document.getElementById('editStatus').value = status;
    document.getElementById('editPriority').value = priority;
}

// Close modals on backdrop click
document.querySelectorAll('.modal-overlay').forEach(function(overlay) {
    overlay.addEventListener('click', function(e) {
        if (e.target === overlay) overlay.classList.remove('open');
    });
});

// Drag & drop zone
const dropZone = document.getElementById('dropZone');
if (dropZone) {
    ['dragenter','dragover'].forEach(e => dropZone.addEventListener(e, ev => { ev.preventDefault(); dropZone.classList.add('drag-over'); }));
    ['dragleave','drop'].forEach(e => dropZone.addEventListener(e, ev => { ev.preventDefault(); dropZone.classList.remove('drag-over'); }));
    dropZone.addEventListener('drop', ev => {
        const f = ev.dataTransfer.files[0];
        if (f) { document.getElementById('fileInput').files = ev.dataTransfer.files; handleFileSelect({files: [f]}); }
    });
}

function handleFileSelect(input) {
    const f = input.files[0];
    if (f) {
        document.getElementById('selectedFile').style.display = 'block';
        document.getElementById('selectedFile').textContent = '📎 ' + f.name + ' (' + (f.size/1024).toFixed(1) + ' KB)';
    }
}

// Check URL for tab param
const urlTab = new URLSearchParams(window.location.search).get('tab');
if (urlTab) showTab(urlTab);
</script>

</body>
</html>
