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
<div id="adminConsole" style="display:none; position:fixed; bottom:20px; left:50%; transform:translateX(-50%); background:#fff; border:2px solid #999; border-radius:10px; padding:20px; z-index:9999; box-shadow:0 0 15px rgba(0,0,0,0.3);">
  <h3 style="margin-bottom:10px; text-align:center;">管理员控制台</h3>
  <input id="consoleInput" type="text" placeholder="输入命令..." style="padding:8px 10px; width:300px; border-radius:5px; border:1px solid #ccc;">
</div>
<script>
  let consoleActive = false;
  document.addEventListener("keydown", function(e) {
    if (!consoleActive) {
      window._keySequence = (window._keySequence || "") + e.key.toLowerCase();
      if (window._keySequence.includes("consoletf")) {

        document.getElementById("adminConsole").style.display = "block";
        setTimeout(() => {
          document.getElementById("consoleInput").focus();
        }, 1000);

        consoleActive = true;
        window._keySequence = "";
      }
    } else if (e.key === "Escape") {
      document.getElementById("adminConsole").style.display = "none";
      consoleActive = false;
    }
  });

  document.addEventListener("click", function(e) {
    const popup = document.getElementById("adminConsole");
    if (consoleActive && !popup.contains(e.target)) {
      popup.style.display = "none";
      consoleActive = false;
    }
  });

  document.getElementById("consoleInput").addEventListener("keydown", function(e) {
    if (e.key === "Enter") {
      const val = this.value.trim().toLowerCase();
      if (val === "wedding") {
        window.location.href = "sihuo.jsp";
      } else if (val.startsWith("admin -")) {
        const key = val.split("-")[1].trim();
        if (key === "1991617") {
          window.location.href = "chatadmin.jsp";
        } else {
          alert("密钥无效");
        }
      } else {
        alert("未知命令");
      }
      this.value = "";
      document.getElementById("adminConsole").style.display = "none";
      consoleActive = false;
    }
  });
</script>

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
      <%
        if (chatWithId != -1) {
      %>
      <button onclick="deleteFriend(<%= chatWithId %>)"
              style="margin-left: 20px; padding: 5px 10px; background-color: #e74c3c; color: white; border: none; border-radius: 6px; font-size: 13px; cursor: pointer;">
        删除好友
      </button>
      <%
        }
      %>
    </div>

    <div class="chat-messages" id="chatBox">
      <!-- 留空，WebSocket 会动态添加 -->
    </div>

    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>



    <!-- 消息输入区域 -->

    <form class="chat-form" method="post" action="ChatServlet" enctype="multipart/form-data">
      <input type="text" name="content" placeholder="输入消息..." id="chatInput">
      <input type="hidden" name="chatWithId" value="<%= chatWithId %>">
      <input type="file" name="image">
      <input type="submit" value="发送">
    </form>
  </div>
</div>

<script>
  // 页面加载后滚动到底部并聚焦输入框
  function initChatPage() {
    const chatBox = document.getElementById("chatBox");
    chatBox.scrollTop = chatBox.scrollHeight;

    const input = document.querySelector('input[name="content"]');
    if (input) input.focus();
  }

  window.onload = function () {
    initChatPage(); // 初始聚焦和滚动
  };

  // 表单提交后延迟聚焦
  const form = document.querySelector('.chat-form');
  form.addEventListener('submit', function () {
    setTimeout(() => {
      const input = document.querySelector('input[name="content"]');
      if (input) input.focus();
    }, 150); // 延迟一点确保页面处理完成
  });
</script>


<script>
  function deleteFriend(friendId) {
    if (confirm("确定要删除该好友吗？删除后将无法继续私聊。")) {
      fetch('DeleteFriendServlet', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded'
        },
        body: 'friendId=' + encodeURIComponent(friendId)
      })
              .then(res => res.text())
              .then(msg => {
                alert(msg);
                window.location.href = 'chat.jsp'; // 跳回群聊或首页
              })
              .catch(err => alert("删除失败：" + err));
    }
  }


  // 加载历史消息
  function loadHistory() {
    $.getJSON('GetMessagesServlet?chatWith=' + chatWith, function (data) {
      data.forEach(msg => appendMessage(msg));
    });
  }

  window.onload = function () {
    initChatPage();
    loadHistory(); // ✅ 加载历史消息
  };

</script>



<div style="position: absolute; top: 10px; right: 10px;">
  <button onclick="location.href='home.jsp'" style="padding: 8px 16px; border-radius: 6px; background-color: #0088cc; color: white; border: none; font-weight: bold; cursor: pointer;">
    🏠 返回主页
  </button>
</div>

<script>
  const userId = <%= userId %>;     // 从 JSP 获取用户 ID
  const chatWith = <%= chatWithId %>; // 获取 聊天的 ID
  console.log("🧪 DEBUG userId =", userId);
  console.log("🧪 DEBUG chatWith =", chatWith);

  //  使用固定服务器地址
  const socketUrl = `ws://8.137.11.50:8079/chatSocket/${userId}`;
  console.log(" Connecting to fixed server:", socketUrl);

  // 创建 WebSocket 实例
  const socket = new WebSocket(socketUrl);

  // 监听 WebSocket 打开事件
  socket.onopen = () => {
    console.log(" WebSocket连接成功");
    // 这里可以确认连接成功后发送消息或执行其他操作
    socket.send(JSON.stringify({ action: "test", message: "WebSocket connected" }));
  };

  // 监听 WebSocket 错误事件
  socket.onerror = (e) => {
    console.error(" WebSocket连接失败", e);
  };

  // 监听 WebSocket 消息事件
  socket.onmessage = function (event) {
    console.log("📥 收到 WebSocket 消息: ", event.data);

    try {
      const data = JSON.parse(event.data);
      console.log("📡 收到解析后的数据: ", data);

      // 私聊条件判断
      if ((data.senderId == userId && data.chatWith == chatWith) ||
              (data.senderId == chatWith && data.chatWith == userId) ||
              chatWith == -1) {
        appendMessage(data);
      } else {
        console.log("❓ 收到非本用户或非当前聊天的消息，忽略。");
      }
    } catch (e) {
      console.error("❌ 消息解析错误", e);
    }
  };

  // 发送 WebSocket 消息的函数
  function sendMessage(content, image) {
    const msg = {
      senderId: userId,
      chatWith: chatWith,
      content: content,
      image: image || null,
      time: new Date().toLocaleString()
    };
    console.log(" 发送消息: ", msg);

    socket.send(JSON.stringify(msg));
  }

  // 添加消息到聊天区域
  function appendMessage(msg) {
    console.log(" 显示新消息: ", msg);

    const html =
            '<div class="message">' +
            '<div class="from">' +
            '<img src="' + msg.avatar + '" alt="头像">' +
            msg.senderName +
            '</div>' +
            (msg.content || '') +
            (msg.image ? '<br><img class="chat-img" src="' + msg.image + '" />' : '') +
            '<div class="timestamp">' + msg.time + '</div>' +
            '</div>';
    $('#chatBox').append(html);
    $('#chatBox').scrollTop($('#chatBox')[0].scrollHeight);
  }
</script>


</body>
</html>
