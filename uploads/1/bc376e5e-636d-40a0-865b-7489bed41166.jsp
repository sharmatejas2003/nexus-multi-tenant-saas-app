<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:set var="currentPage" value="files"/>
<!DOCTYPE html>
<html>
<head>
    <title>Nexus — Files</title>
    <link href="https://fonts.googleapis.com/css2?family=Space+Mono:wght@400;700&family=DM+Sans:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="/css/nexus.css">
    <style>
        .file-grid { display:grid; grid-template-columns:repeat(auto-fill,minmax(220px,1fr)); gap:14px; }
        .file-item {
            background:var(--bg2); border:1px solid var(--border); border-radius:12px;
            padding:16px; transition:all 0.2s; cursor:default;
        }
        .file-item:hover { border-color:var(--accent); transform:translateY(-2px); }
        .file-icon-big { font-size:36px; margin-bottom:10px; display:block; }
        .file-name { font-size:13px; font-weight:600; margin-bottom:4px; word-break:break-all; }
        .file-meta { font-size:11px; color:var(--text2); }
        .drop-zone {
            border:2px dashed var(--border); border-radius:12px; padding:40px 20px;
            text-align:center; color:var(--text2); transition:all 0.2s; cursor:pointer;
            margin-bottom:24px;
        }
        .drop-zone:hover, .drop-zone.drag-over {
            border-color:var(--accent); background:rgba(108,99,255,0.05); color:var(--accent);
        }
        .upload-progress { display:none; margin-top:12px; }
    </style>
</head>
<body>

<%@ include file="sidebar.jsp" %>

<div class="main">
    <div class="topbar">
        <div>
            <div class="page-title">Files</div>
            <div class="page-subtitle">All files uploaded across your workspace.</div>
        </div>
        <div class="topbar-actions">
            <button class="btn btn-primary" onclick="document.getElementById('fileInput').click()">+ Upload File</button>
        </div>
    </div>

    <!-- SUCCESS/ERROR BANNERS -->
    <c:if test="${param.uploaded == 'true'}">
        <div style="background:rgba(67,233,123,0.1);border:1px solid rgba(67,233,123,0.3);border-radius:8px;padding:12px 16px;margin-bottom:20px;font-size:13px;color:var(--accent3);">✅ File uploaded successfully!</div>
    </c:if>
    <c:if test="${param.deleted == 'true'}">
        <div style="background:rgba(67,233,123,0.1);border:1px solid rgba(67,233,123,0.3);border-radius:8px;padding:12px 16px;margin-bottom:20px;font-size:13px;color:var(--accent3);">✅ File deleted.</div>
    </c:if>
    <c:if test="${param.error != null}">
        <div style="background:rgba(255,101,132,0.1);border:1px solid rgba(255,101,132,0.3);border-radius:8px;padding:12px 16px;margin-bottom:20px;font-size:13px;color:var(--accent2);">❌ Error: ${param.error}</div>
    </c:if>

    <!-- DROP ZONE UPLOAD -->
    <div class="drop-zone" id="dropZone" onclick="document.getElementById('fileInput').click()">
        <div style="font-size:40px;margin-bottom:10px;">☁️</div>
        <div style="font-size:15px;font-weight:600;">Drop files here or click to upload</div>
        <div style="font-size:12px;margin-top:6px;">Supports images, PDFs, documents, zip files · Max 20MB</div>
    </div>

    <!-- Hidden upload form -->
    <form id="uploadForm" action="/files/upload" method="post" enctype="multipart/form-data" style="display:none;">
        <input type="file" id="fileInput" name="file" onchange="submitUpload()">
        <input type="hidden" name="entityType" value="GENERAL">
        <input type="hidden" name="entityId" value="0">
        <input type="hidden" name="redirectTo" value="/files">
    </form>

    <div id="uploadProgress" class="upload-progress">
        <div style="background:var(--bg2);border:1px solid var(--border);border-radius:8px;padding:16px;display:flex;align-items:center;gap:12px;">
            <div style="font-size:20px;">⏳</div>
            <div>
                <div style="font-size:13px;font-weight:600;">Uploading...</div>
                <div class="progress-bar" style="margin-top:6px;width:200px;"><div class="progress-fill" style="width:60%;animation:progress 1.5s ease-in-out infinite alternate;"></div></div>
            </div>
        </div>
    </div>

    <!-- STATS -->
    <div style="display:grid;grid-template-columns:repeat(3,1fr);gap:16px;margin-bottom:24px;">
        <div class="stat-card purple">
            <div class="stat-label">TOTAL FILES</div>
            <div class="stat-value">${files.size()}</div>
        </div>
        <div class="stat-card blue">
            <div class="stat-label">STORAGE USED</div>
            <div class="stat-value" style="font-size:20px;margin-top:8px;">
                <c:set var="totalBytes" value="0"/>
                <c:forEach var="f" items="${files}"><c:set var="totalBytes" value="${totalBytes + f.fileSize}"/></c:forEach>
                <c:choose>
                    <c:when test="${totalBytes < 1024}"><fmt:formatNumber value="${totalBytes}"/>B</c:when>
                    <c:when test="${totalBytes < 1048576}"><fmt:formatNumber value="${totalBytes/1024}" maxFractionDigits="1"/>KB</c:when>
                    <c:otherwise><fmt:formatNumber value="${totalBytes/1048576}" maxFractionDigits="1"/>MB</c:otherwise>
                </c:choose>
            </div>
        </div>
        <div class="stat-card green">
            <div class="stat-label">PLAN LIMIT</div>
            <div class="stat-value" style="font-size:20px;margin-top:8px;">1GB</div>
            <div class="stat-sub"><a href="/workspace/settings" style="color:var(--accent);text-decoration:none;">Upgrade →</a></div>
        </div>
    </div>

    <!-- FILES GRID -->
    <div class="card" style="padding:0;overflow:hidden;">
        <div style="padding:20px 24px;border-bottom:1px solid var(--border);display:flex;justify-content:space-between;align-items:center;">
            <span class="card-title">All Files <span class="badge badge-purple" style="margin-left:8px;">${files.size()}</span></span>
            <div style="display:flex;gap:8px;">
                <input type="text" id="searchInput" placeholder="Search files..." class="form-input" style="width:200px;padding:6px 12px;font-size:12px;" oninput="filterFiles(this.value)">
            </div>
        </div>

        <c:choose>
            <c:when test="${empty files}">
                <div class="empty-state" style="padding:60px 20px;">
                    <div class="empty-icon">📂</div>
                    <p>No files uploaded yet. Upload your first file!</p>
                </div>
            </c:when>
            <c:otherwise>
                <div style="padding:20px;">
                    <div class="file-grid" id="fileGrid">
                        <c:forEach var="f" items="${files}">
                        <div class="file-item" data-name="${f.originalName.toLowerCase()}">
                            <span class="file-icon-big">${f.fileIcon}</span>
                            <div class="file-name">${f.originalName}</div>
                            <div class="file-meta">${f.formattedSize}</div>
                            <div class="file-meta" style="margin-bottom:12px;">${f.uploadedByUsername}</div>
                            <div style="display:flex;gap:6px;flex-wrap:wrap;">
                                <a href="/files/preview/${f.id}" target="_blank" class="btn btn-ghost" style="padding:5px 10px;font-size:11px;">👁 View</a>
                                <a href="/files/download/${f.id}" class="btn btn-ghost" style="padding:5px 10px;font-size:11px;">⬇ Download</a>
                                <form action="/files/delete/${f.id}" method="post" onsubmit="return confirm('Delete this file?')" style="margin-left:auto;">
                                    <input type="hidden" name="redirectTo" value="/files">
                                    <button class="btn btn-danger" style="padding:5px 10px;font-size:11px;">✕</button>
                                </form>
                            </div>
                        </div>
                        </c:forEach>
                    </div>
                </div>
            </c:otherwise>
        </c:choose>
    </div>
</div>

<style>
@keyframes progress { from { width:30%; } to { width:90%; } }
</style>

<script>
const dropZone = document.getElementById('dropZone');
['dragenter','dragover'].forEach(e => dropZone.addEventListener(e, ev => { ev.preventDefault(); dropZone.classList.add('drag-over'); }));
['dragleave','drop'].forEach(e => dropZone.addEventListener(e, ev => { ev.preventDefault(); dropZone.classList.remove('drag-over'); }));
dropZone.addEventListener('drop', ev => {
    const files = ev.dataTransfer.files;
    if (files.length > 0) {
        document.getElementById('fileInput').files = files;
        submitUpload();
    }
});

function submitUpload() {
    const f = document.getElementById('fileInput').files[0];
    if (!f) return;
    if (f.size > 20 * 1024 * 1024) {
        alert('File too large. Maximum size is 20MB.');
        return;
    }
    document.getElementById('uploadProgress').style.display = 'block';
    document.getElementById('uploadForm').submit();
}

function filterFiles(query) {
    const items = document.querySelectorAll('.file-item');
    items.forEach(item => {
        const name = item.getAttribute('data-name') || '';
        item.style.display = name.includes(query.toLowerCase()) ? '' : 'none';
    });
}
</script>

</body>
</html>
