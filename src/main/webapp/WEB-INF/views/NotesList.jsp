<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:set var="currentPage" value="notes"/>
<!DOCTYPE html>
<html>
<head>
    <title>Nexus — Notes</title>
    <link href="https://fonts.googleapis.com/css2?family=Space+Mono:wght@400;700&family=DM+Sans:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="/css/nexus.css">
</head>
<body>

<%@ include file="sidebar.jsp" %>

<div class="main">
    <div class="topbar">
        <div>
            <div class="page-title">Notes</div>
            <div class="page-subtitle">Collaborative workspace notepad for your team.</div>
        </div>
        <div class="topbar-actions">
            <button class="btn btn-primary" onclick="document.getElementById('addNoteModal').classList.add('open')">+ New Note</button>
        </div>
    </div>

    <!-- ADD NOTE MODAL -->
    <div class="modal-overlay" id="addNoteModal">
        <div class="modal">
            <div class="modal-title">Create Note</div>
            <form action="/notes/save" method="post">
                <div style="margin-bottom:14px;">
                    <label class="form-label">TITLE</label>
                    <input type="text" name="title" class="form-input" placeholder="Note title..." required autofocus>
                </div>
                <div style="margin-bottom:20px;">
                    <label class="form-label">CONTENT</label>
                    <textarea name="content" class="form-textarea" rows="5" placeholder="Write your note here..." style="resize:vertical;"></textarea>
                </div>
                <div style="display:flex;gap:10px;justify-content:flex-end;">
                    <button type="button" class="btn btn-ghost" onclick="document.getElementById('addNoteModal').classList.remove('open')">Cancel</button>
                    <button type="submit" class="btn btn-primary">Save Note</button>
                </div>
            </form>
        </div>
    </div>

    <!-- NOTES GRID -->
    <c:choose>
        <c:when test="${empty notes}">
            <div class="card">
                <div class="empty-state">
                    <div class="empty-icon">📝</div>
                    <p>No notes yet. Create your first one!</p>
                    <button class="btn btn-primary" style="margin-top:16px;" onclick="document.getElementById('addNoteModal').classList.add('open')">+ New Note</button>
                </div>
            </div>
        </c:when>
        <c:otherwise>
            <div style="display:grid;grid-template-columns:repeat(auto-fill,minmax(280px,1fr));gap:16px;">
                <c:forEach var="note" items="${notes}" varStatus="s">
                <div class="card" style="position:relative;cursor:pointer;transition:border-color 0.2s;" onmouseover="this.style.borderColor='var(--accent)'" onmouseout="this.style.borderColor='var(--border)'">
                    <div style="display:flex;justify-content:space-between;align-items:flex-start;margin-bottom:10px;">
                        <div style="font-weight:600;font-size:15px;flex:1;">${note.title}</div>
                        <div style="display:flex;gap:6px;margin-left:8px;">
                            <form action="/notes/delete/${note.id}" method="post" onsubmit="return confirm('Delete note?')">
                                <button class="btn btn-danger" style="padding:4px 8px;font-size:11px;">✕</button>
                            </form>
                        </div>
                    </div>
                    <div style="font-size:13px;color:var(--text2);line-height:1.6;max-height:100px;overflow:hidden;">${note.content}</div>
                    <div style="margin-top:14px;padding-top:12px;border-top:1px solid var(--border);display:flex;justify-content:space-between;align-items:center;">
                        <span style="font-size:11px;color:var(--text2);">Note #${note.id}</span>
                        <span class="badge badge-purple" style="font-size:10px;">Saved</span>
                    </div>
                </div>
                </c:forEach>
            </div>
        </c:otherwise>
    </c:choose>

</div>

</body>
</html>
