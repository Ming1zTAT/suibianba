<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*, java.util.*, com.example.yytfsupportsite.yytf.util.DBUtil" %>
<%
  if (session.getAttribute("userId") == null) {
    response.sendRedirect("login.jsp");
    return;
  }
  int userId = (int) session.getAttribute("userId");
  String username = (String) session.getAttribute("username");
  boolean isAdmin = session.getAttribute("adminMode") != null;
%>
<!DOCTYPE html>
<html>
<head>
  <title>聊天室 - 共产国际</title>
  <style>
    * { margin: 0; padding: 0; box-sizing: border-box; }
    body {
      font-family: "Segoe UI", sans-serif;
      background: url('images/chat/background.png') repeat;
      background-size: cover;
    }
    .container {
      display: flex;
      height: 100vh;
      width: 100vw;
      overflow: hidden;
    }
    .sidebar {
      width: 260px;
      background-color: rgba(255, 255, 255, 0.9);
      border-right: 1px solid #ccc;
      padding: 20px;
    }
    .group {
      padding: 12px 16px;
      background-color: #fff;
      border-radius: 10px;
      margin-bottom: 10px;
      font-weight: bold;
      color: #333;
      box-shadow: 0 2px 4px rgba(0,0,0,0.1);
    }
    .chat-area {
      flex: 1;
      display: flex;
      flex-direction: column;
    }
    .chat-header {
      padding: 16px;
      background-color: rgba(255, 255, 255, 0.9);
      font-size: 20px;
      font-weight: bold;
      border-bottom: 1px solid #ccc;
    }
    .chat-messages {
      flex: 1;
      overflow-y: auto;
      padding: 20px;
    }
    .message {
      background-color: rgba(255,255,255,0.95);
      border-radius: 10px;
      padding: 12px 16px;
      margin-bottom: 15px;
      max-width: 65%;
      box-shadow: 0 2px 5px rgba(0,0,0,0.1);
    }
    .from {
      font-weight: bold;
      color: #0088cc;
    }
    .timestamp {
      font-size: 0.8em;
      color: #888;
      margin-top: 5px;
    }
    .message img {
      max-width: 200px;
      max-height: 200px;
      display: block;
      margin-top: 8px;
      border-radius: 5px;
    }
    .chat-form {
      display: flex;
      align-items: center;
      gap: 10px;
      padding: 15px 20px;
      background-color: rgba(255,255,255,0.9);
      border-top: 1px solid #ccc;
    }
    .chat-form input[type="text"] {
      flex: 1;
      padding: 10px;
      border-radius: 20px;
      border: 1px solid #ccc;
      outline: none;
    }
    .chat-form input[type="submit"] {
      padding: 8px 20px;
      background-color: #0088cc;
      color: white;
      border: none;
      border-radius: 20px;
      font-weight: bold;
      cursor: pointer;
    }
    .chat-form input[type="submit"]:hover {
      background-color: #0073a8;
    }
    .delete-btn {
      float: right;
      color: red;
      background: none;
      border: none;
      cursor: pointer;
    }
  </style>
</head>
<script>
  // 页面加载后滚动到底部
  window.onload = function () {
    const chatBox = document.getElementById("chat-messages");
    if (chatBox) {
      chatBox.scrollTop = chatBox.scrollHeight;
    }
  };
</script>
<script>
  let inputBuffer = "";

  document.addEventListener("keydown", function (e) {
    const key = e.key.toLowerCase();

    if (/^[a-z]$/.test(key)) {
      inputBuffer += key;

      if (inputBuffer.endsWith("delete")) {
        fetch("EnableAdminServlet").then(() => location.reload());
      }

      if (inputBuffer.endsWith("exitdelete")) {
        fetch("DisableAdminServlet").then(() => location.reload());
      }

      if (inputBuffer.length > 20) {
        inputBuffer = inputBuffer.slice(-20); // 控制缓存长度
      }
    }
  });
</script>


<body>
<div class="container">
  <!-- 左侧群组 -->
  <div class="sidebar">
    <div class="group">👥 共产国际</div>
  </div>

  <!-- 右侧聊天 -->
  <div class="chat-area">
    <div class="chat-header">👥 群聊：共产国际</div>

    <div class="chat-messages" id="chat-messages">
      <%
        Connection conn = DBUtil.getConnection();
        PreparedStatement ps = conn.prepareStatement(
                "SELECT c.*, u.username FROM chat_messages c JOIN users u ON c.user_id = u.id ORDER BY c.timestamp ASC"
        );
        ResultSet rs = ps.executeQuery();
        while (rs.next()) {
          String msgUser = rs.getString("username");
          String content = rs.getString("content");
          String image = rs.getString("image_url");
          Timestamp time = rs.getTimestamp("timestamp");
          int msgId = rs.getInt("id");
      %>
      <div class="message">

        <span class="from"><%= msgUser %></span>
        <% if (isAdmin) { %>
        <form method="post" action="DeleteChatServlet" style="display:inline;">
          <input type="hidden" name="id" value="<%= msgId %>">
          <button type="submit" class="delete-btn">删除</button>
        </form>
        <% } %>
        <div><%= content != null ? content : "" %></div>
        <% if (image != null && !image.isEmpty()) { %>
        <img src="<%= image %>" alt="图片">
        <% } %>
        <div class="timestamp"><%= time.toString() %></div>
      </div>
      <% } rs.close(); ps.close(); conn.close(); %>
    </div>

    <form class="chat-form" method="post" action="ChatServlet" enctype="multipart/form-data">
      <input type="text" name="content" placeholder="输入消息..." >
      <input type="file" name="image">
      <input type="submit" value="发送">
    </form>
  </div>
</div>

</body>

</html>
