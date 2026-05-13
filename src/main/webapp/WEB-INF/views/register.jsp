<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
    <title>Nexus — Create Account</title>

    <link href="https://fonts.googleapis.com/css2?family=Space+Mono:wght@400;700&family=DM+Sans:wght@300;400;500;600;700&display=swap" rel="stylesheet">

    <!-- Font Awesome -->
    <link rel="stylesheet"
          href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.2/css/all.min.css">

    <style>
        :root{
            --accent:#6c63ff;
            --accent2:#ff6584;
            --accent3:#43e97b;
            --bg:#0a0a0f;
            --bg2:#111118;
            --bg3:#1a1a24;
            --border:#2a2a3a;
            --text:#e8e8f0;
            --text2:#8888aa;
        }

        *{margin:0;padding:0;box-sizing:border-box;}

        body{
            background:var(--bg);
            color:var(--text);
            font-family:'DM Sans',sans-serif;
            min-height:100vh;
            display:flex;
            align-items:center;
            justify-content:center;
            padding:40px 20px;
        }

        body::before{
            content:'';
            position:fixed;
            inset:0;
            background:
            radial-gradient(ellipse at 20% 50%,
            rgba(108,99,255,0.10) 0%,transparent 60%);
            pointer-events:none;
        }

        .auth-box{
            width:480px;
            position:relative;
            z-index:1;
        }
