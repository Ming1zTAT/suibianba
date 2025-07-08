<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*, com.example.yytfsupportsite.yytf.util.DBUtil" %>
<%
    if (session.getAttribute("userId") == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    int userId = (int) session.getAttribute("userId");
    String username = (String) session.getAttribute("username");

    String avatarPath = null;
    String displayName = "";

    try (Connection conn = DBUtil.getConnection()) {
        PreparedStatement ps = conn.prepareStatement("SELECT display_name, avatar FROM users WHERE id = ?");
        ps.setInt(1, userId);
        ResultSet rs = ps.executeQuery();
        if (rs.next()) {
            displayName = rs.getString("display_name");
            avatarPath = rs.getString("avatar");
        }
        rs.close();
        ps.close();
    } catch (SQLException e) {
        e.printStackTrace();
    }
%>
<html>
<head>
    <title>个人中心</title>
    <style>
        body {
            font-family: Arial;
            background: #f4f4f4;
            padding: 50px;
        }
        .profile {
            background: white;
            padding: 30px;
            border-radius: 8px;
            max-width: 400px;
            margin: auto;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
        }
        .profile h2 {
            margin-bottom: 20px;
        }
        .profile input[type="text"], .profile input[type="file"] {
            width: 100%;
            padding: 8px;
            margin-bottom: 15px;
        }
        .profile input[type="submit"] {
            background-color: #0088cc;
            color: white;
            padding: 10px 20px;
            border: none;
            border-radius: 20px;
            cursor: pointer;
            font-weight: bold;
        }
        .avatar {
            text-align: center;
            margin-bottom: 20px;
        }
        .avatar img {
            max-width: 120px;
            border-radius: 50%;
        }
    </style>
</head>
<body>
<div style="position: fixed; top: 10px; left: 10px; z-index: 999;">
    <button onclick="history.back()" style="padding: 6px 12px; font-size: 14px; border-radius: 5px; border: none; background-color: #4CAF50; color: white; cursor: pointer;">
        ← 返回
    </button>
</div>
<div class="profile">
    <h2>个人资料</h2>
    <div class="avatar">
        <% if (avatarPath != null) { %>
        <img src="<%= avatarPath %>" alt="头像">
        <% } else { %>
        <img src="images/default-avatar.png" alt="默认头像">
        <% } %>
    </div>
    <form action="UpdateProfileServlet" method="post" enctype="multipart/form-data">
        <label>登录用户名：</label><br>
        <input type="text" value="<%= username %>" disabled><br>
        <label>昵称：</label><br>
        <input type="text" name="displayName" value="<%= displayName != null ? displayName : "" %>" required><br>
        <label>更换头像：</label><br>
        <input type="file" name="avatar"><br>
        <input type="submit" value="保存修改">
    </form>
</div>
</body>
</html>
