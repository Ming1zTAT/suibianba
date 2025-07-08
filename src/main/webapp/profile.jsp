<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*, com.example.yytfsupportsite.yytf.util.DBUtil" %>
<%
    if (session.getAttribute("userId") == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    int userId = (int) session.getAttribute("userId");
    String username = (String) session.getAttribute("username");

    String message = "";
    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String newName = request.getParameter("nickname");
        Part avatarPart = request.getPart("avatar");

        Connection conn = DBUtil.getConnection();
        PreparedStatement ps = conn.prepareStatement("UPDATE users SET username = ? WHERE id = ?");
        ps.setString(1, newName);
        ps.setInt(2, userId);
        ps.executeUpdate();
        ps.close();

        // 头像上传
        if (avatarPart != null && avatarPart.getSize() > 0) {
            String uploadPath = application.getRealPath("/") + "avatars/";
            java.io.File dir = new java.io.File(uploadPath);
            if (!dir.exists()) dir.mkdirs();
            String filePath = uploadPath + newName + ".png";
            avatarPart.write(filePath);
        }

        conn.close();
        message = "资料更新成功！";
        session.setAttribute("username", newName);
    }
%>

<!DOCTYPE html>
<html>
<head>
    <title>个人中心</title>
    <meta charset="UTF-8">
    <style>
        body {
            background: linear-gradient(to bottom right, #e0f7ff, #ffffff);
            font-family: 'Segoe UI', sans-serif;
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
        }
        .profile-box {
            background: white;
            border-radius: 15px;
            padding: 40px;
            box-shadow: 0 5px 15px rgba(0,0,0,0.1);
            width: 400px;
        }
        h2 {
            text-align: center;
            color: #0088cc;
            margin-bottom: 30px;
        }
        label {
            display: block;
            margin-bottom: 8px;
            font-weight: bold;
            color: #333;
        }
        input[type="text"], input[type="file"] {
            width: 100%;
            padding: 10px;
            border-radius: 20px;
            border: 1px solid #ccc;
            margin-bottom: 20px;
        }
        input[type="submit"] {
            width: 100%;
            padding: 10px;
            border: none;
            border-radius: 25px;
            background-color: #0088cc;
            color: white;
            font-weight: bold;
            cursor: pointer;
        }
        input[type="submit"]:hover {
            background-color: #0073a8;
        }
        .message {
            text-align: center;
            color: green;
            margin-bottom: 20px;
        }
        .avatar {
            display: block;
            margin: 0 auto 20px;
            border-radius: 50%;
            width: 80px;
            height: 80px;
            object-fit: cover;
            border: 2px solid #0088cc;
        }
        .back {
            display: block;
            text-align: center;
            margin-top: 20px;
            text-decoration: none;
            color: #0088cc;
            font-weight: bold;
        }
    </style>
</head>
<body>
<div style="position: fixed; top: 10px; left: 10px; z-index: 999;">
    <button onclick="history.back()" style="padding: 6px 12px; font-size: 14px; border-radius: 5px; border: none; background-color: #4CAF50; color: white; cursor: pointer;">
        ← 返回
    </button>
</div>
<div class="profile-box">
    <h2>个人中心</h2>

    <img class="avatar" src="avatars/<%= username %>.png" alt="头像" onerror="this.src='avatars/default.png'">

    <% if (!message.isEmpty()) { %>
    <div class="message"><%= message %></div>
    <% } %>

    <form method="post" enctype="multipart/form-data">
        <label>新昵称</label>
        <input type="text" name="nickname" placeholder="请输入新昵称" required>

        <label>上传新头像</label>
        <input type="file" name="avatar" accept="image/*">

        <input type="submit" value="保存更改">
    </form>

    <a href="home.jsp" class="back">← 返回主页</a>
</div>
</body>
</html>
