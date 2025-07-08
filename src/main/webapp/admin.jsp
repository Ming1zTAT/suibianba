<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*,com.example.yytfsupportsite.yytf.util.DBUtil"%>
<html>
<head>
  <meta charset="UTF-8">
  <title>管理员后台</title>
  <style>
    body { font-family: Arial; margin: 20px; }
    table { width: 90%; border-collapse: collapse; margin-bottom: 40px; }
    th, td { border: 1px solid #ccc; padding: 8px; text-align: center; }
    th { background-color: #f2f2f2; }
    h2 { margin-top: 40px; }
  </style>
</head>
<body>
<div style="position: fixed; top: 10px; left: 10px; z-index: 999;">
  <button onclick="history.back()" style="padding: 6px 12px; font-size: 14px; border-radius: 5px; border: none; background-color: #4CAF50; color: white; cursor: pointer;">
    ← 返回
  </button>
</div>
<h1>🛠 管理员后台</h1>

<!-- 用户管理 -->
<h2>👤 用户列表</h2>
<table>
  <tr><th>ID</th><th>用户名</th><th>操作</th></tr>
  <%
    try (Connection conn = DBUtil.getConnection()) {
      Statement stmt = conn.createStatement();
      ResultSet rs = stmt.executeQuery("SELECT * FROM users");
      while (rs.next()) {
  %>
  <tr>
    <td><%= rs.getInt("id") %></td>
    <td><%= rs.getString("username") %></td>
    <td>
      <form method="post" action="deleteUser" onsubmit="return confirm('确定删除该用户？')">
        <input type="hidden" name="userId" value="<%= rs.getInt("id") %>">
        <input type="submit" value="删除">
      </form>
    </td>
  </tr>
  <%
      }
    } catch (Exception e) {
      out.println("加载用户失败：" + e.getMessage());
    }
  %>
</table>

<!-- 留言管理 -->
<h2>💬 留言列表</h2>
<table>
  <tr><th>ID</th><th>用户</th><th>内容</th><th>时间</th><th>操作</th></tr>
  <%
    try (Connection conn = DBUtil.getConnection()) {
      String sql = "SELECT posts.id, users.username, posts.content, posts.created_at " +
              "FROM posts JOIN users ON posts.user_id = users.id";
      PreparedStatement ps = conn.prepareStatement(sql);
      ResultSet rs = ps.executeQuery();
      while (rs.next()) {
  %>
  <tr>
    <td><%= rs.getInt("id") %></td>
    <td><%= rs.getString("username") %></td>
    <td><%= rs.getString("content") %></td>
    <td><%= rs.getTimestamp("created_at") %></td>
    <td>
      <form method="post" action="deletePost" onsubmit="return confirm('确定删除该留言？')">
        <input type="hidden" name="postId" value="<%= rs.getInt("id") %>">
        <input type="submit" value="删除">
      </form>
    </td>
  </tr>
  <%
      }
    } catch (Exception e) {
      out.println("加载留言失败：" + e.getMessage());
    }
  %>
</table>
</body>
</html>
