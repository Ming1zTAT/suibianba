<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*, com.example.yytfsupportsite.yytf.util.DBUtil" %>
<%
  if (session.getAttribute("userId") == null) {
    response.sendRedirect("login.jsp");
    return;
  }

  int userId = (int) session.getAttribute("userId");
  String username = (String) session.getAttribute("username");
  String selectedChatUserIdParam = request.getParameter("chatWith");
  int chatWithId = selectedChatUserIdParam != null ? Integer.parseInt(selectedChatUserIdParam) : -1;
%>
<html>
<head>
  <title>聊天室</title>
  <style>
    * { box-sizing: border-box; margin: 0; padding: 0; }
    body {
      font-family: Arial, sans-serif;
      background: url('images/chat/background.png') repeat;
      height: 100vh;
    }
    .container {
      display: flex;
      height: 100vh;
    }
    .sidebar {
      width: 280px;
      background-color: #e6e6e6;
      border-right: 1px solid #ccc;
      padding: 20px;
      overflow-y: auto;
    }
    .group, .friend {
      background-color: #fff;
      padding: 12px;
      margin-bottom: 10px;
      border-radius: 8px;
      cursor: pointer;
      box-shadow: 1px 1px 4px rgba(0,0,0,0.1);
    }
    .group:hover, .friend:hover {
      background-color: #d4f1ff;
    }
    .chat-area {
      flex: 1;
      display: flex;
      flex-direction: column;
      background-color: rgba(255,255,255,0.9);
    }
    .chat-header {
      padding: 15px 20px;
      border-bottom: 1px solid #ccc;
      font-weight: bold;
      font-size: 18px;
      background-color: #f8f8f8;
    }
    .chat-messages {
      flex: 1;
      padding: 20px;
      overflow-y: auto;
    }
    .message {
      margin-bottom: 15px;
      background-color: #ffffffcc;
      border-radius: 10px;
      padding: 10px 15px;
      max-width: 70%;
      box-shadow: 0 2px 5px rgba(0,0,0,0.1);
    }
    .from {
      font-weight: bold;
      color: #2f4f4f;
      display: flex;
      align-items: center;
      gap: 8px;
    }
    .from img {
      width: 32px;
      height: 32px;
      border-radius: 50%;
      object-fit: cover;
    }
    .timestamp {
      font-size: 0.8em;
      color: #999;
      margin-top: 5px;
    }
    .chat-form {
      display: flex;
      gap: 10px;
      padding: 15px 20px;
      border-top: 1px solid #ccc;
      background-color: #f9f9f9;
    }
    .chat-form input[type="text"] {
      flex: 1;
      padding: 10px;
      border-radius: 20px;
      border: 1px solid #ccc;
    }
    .chat-form input[type="file"] {
      border: none;
    }
    .chat-form input[type="submit"] {
      padding: 10px 18px;
      background-color: #0088cc;
      color: white;
      border: none;
      border-radius: 20px;
      font-weight: bold;
      cursor: pointer;
    }
    .message img.chat-img {
      max-width: 200px;
      border-radius: 8px;
      margin-top: 8px;
    }
  </style>
</head>
<body>
<div class="container">
  <!-- 左侧好友栏 -->
  <div class="sidebar">
    <div class="group" onclick="location.href='chat.jsp?chatWith=-1'">👥 群组：共产国际</div>
    <hr>
    <h4>好友列表</h4>
    <%
      Connection conn = DBUtil.getConnection();
      PreparedStatement ps = conn.prepareStatement(
              "SELECT u.id, COALESCE(u.display_name, u.username) AS show_name " +
                      "FROM users u " +
                      "WHERE u.id IN (SELECT friend_id FROM friends WHERE user_id = ? " +
                      "UNION SELECT user_id FROM friends WHERE friend_id = ?)"
      );
      ps.setInt(1, userId);
      ps.setInt(2, userId);
      ResultSet frs = ps.executeQuery();
      while (frs.next()) {
        int fid = frs.getInt("id");
        String fname = frs.getString("show_name");
    %>
    <div class="friend" onclick="location.href='chat.jsp?chatWith=<%=fid%>'">💬 <%= fname %></div>
    <%
      }
      frs.close();
      ps.close();
    %>
  </div>

  <!-- 聊天区域 -->
  <div class="chat-area">
    <div class="chat-header">
      <%
        if (chatWithId == -1) {
          out.print("群聊：共产国际");
        } else {
          PreparedStatement p = conn.prepareStatement(
                  "SELECT COALESCE(display_name, username) AS show_name FROM users WHERE id=?"
          );
          p.setInt(1, chatWithId);
          ResultSet r = p.executeQuery();
          if (r.next()) out.print("私聊：" + r.getString("show_name"));
          r.close(); p.close();
        }
      %>
    </div>

    <div class="chat-messages" id="chatBox">
      <%
        PreparedStatement ps2;
        if (chatWithId == -1) {
          ps2 = conn.prepareStatement(
                  "SELECT c.*, COALESCE(u.display_name, u.username) AS show_name, u.avatar " +
                          "FROM chat_messages c JOIN users u ON c.user_id = u.id " +
                          "WHERE c.receiver_id IS NULL ORDER BY c.timestamp ASC"
          );
        } else {
          ps2 = conn.prepareStatement(
                  "SELECT c.*, COALESCE(u.display_name, u.username) AS show_name, u.avatar " +
                          "FROM chat_messages c JOIN users u ON c.user_id = u.id " +
                          "WHERE (c.user_id=? AND c.receiver_id=?) OR (c.user_id=? AND c.receiver_id=?) " +
                          "ORDER BY c.timestamp ASC"
          );
          ps2.setInt(1, userId);
          ps2.setInt(2, chatWithId);
          ps2.setInt(3, chatWithId);
          ps2.setInt(4, userId);
        }

        ResultSet rs = ps2.executeQuery();
        while (rs.next()) {
          String senderName = rs.getString("show_name");
          String avatar = rs.getString("avatar");
          if (avatar == null || avatar.isEmpty()) {
            avatar = "images/taffy1.jpg";
          }
      %>
      <div class="message">
        <div class="from">
          <img src="<%= avatar %>" alt="头像">
          <%= senderName %>
        </div>
        <%= rs.getString("content") != null ? rs.getString("content") : "" %>
        <% if (rs.getString("image_url") != null && !rs.getString("image_url").isEmpty()) { %>
        <br><img class="chat-img" src="<%= rs.getString("image_url") %>" alt="图">
        <% } %>
        <div class="timestamp"><%= rs.getTimestamp("timestamp") %></div>
      </div>
      <%
        }
        rs.close(); ps2.close(); conn.close();
      %>
    </div>

    <!-- 消息输入区域 -->
    <form class="chat-form" method="post" action="ChatServlet" enctype="multipart/form-data">
      <input type="text" name="content" placeholder="输入消息..." id="chatInput">
      <input type="hidden" name="receiverId" value="<%= chatWithId %>">
      <input type="file" name="image">
      <input type="submit" value="发送">
    </form>
  </div>
</div>

<script>
  const chatBox = document.getElementById("chatBox");
  chatBox.scrollTop = chatBox.scrollHeight;

  const input = document.getElementById("chatInput");
  window.onload = () => {
    input.focus(); // 自动聚焦
  };
</script>
</body>
</html>
