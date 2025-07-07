<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*,com.example.yytfsupportsite.yytf.util.DBUtil"%>
<%
    String birthday = "1867年8月12日";
    request.setAttribute("birthday",birthday);

%>
<%
    String username = (String) session.getAttribute("username");
    if (username == null) {
        response.sendRedirect("login.jsp");  // 如果没有登录，重定向到登录页面
        return;
    }

    Integer userId = (Integer) session.getAttribute("userId");  // 获取用户ID
    if (userId == null) {
        response.sendRedirect("login.jsp");  // 如果 userId 为 null，重定向到登录页面
        return;
    }
%>
<html>
<head>
    <meta charset="UTF-8">
    <title>永雏塔菲后援会</title>
    <link rel="stylesheet" href="css/style.css">
</head>
<script>
    function pad(n) {
        return n < 10 ? '0' + n : n;
    }

    function updateCountdown() {
        const now = new Date();
        const year = (now.getMonth() > 7 || (now.getMonth() === 7 && now.getDate() >= 12))
            ? now.getFullYear() + 1 : now.getFullYear();
        const target = new Date(year + "-08-12T00:00:00");
        const diff = target - now;

        if (diff <= 0) {
            document.getElementById("countdown").innerHTML = "🎉 生日快乐，塔菲喵！";
            return;
        }

        const days = Math.floor(diff / (1000 * 60 * 60 * 24));
        const hours = Math.floor((diff / (1000 * 60 * 60)) % 24);
        const minutes = Math.floor((diff / (1000 * 60)) % 60);
        const seconds = Math.floor((diff / 1000) % 60);

        let html = "🎂 距离永雏塔菲生日还有 <strong>" + pad(days) + "</strong> 天 ";
        html += "<strong>" + pad(hours) + "</strong> 小时 ";
        html += "<strong>" + pad(minutes) + "</strong> 分 ";
        html += "<strong>" + pad(seconds) + "</strong> 秒！";

        document.getElementById("countdown").innerHTML = html;
    }

    setInterval(updateCountdown, 1000);
    updateCountdown();
</script>

<script>
    let eggBuffer = "";

    document.addEventListener("keydown", function(e) {
        // 拼接输入字符，支持 Shift（大小写）
        eggBuffer += e.key;
        if (eggBuffer.length > 20) {
            eggBuffer = eggBuffer.slice(-20); // 控制长度
        }

        if (eggBuffer.includes("taffymiao")) {
            showEasterEgg();
            eggBuffer = "";  // 重置防止多次触发
        }
    });

    function showEasterEgg() {
        // 弹出彩蛋内容
        const egg = document.createElement("div");
        egg.innerHTML = `
            <div style="
                position: fixed;
                top: 20%;
                left: 50%;
                transform: translate(-50%, -20%);
                background-color: #fff0f5;
                padding: 30px;
                border: 2px dashed #ff69b4;
                border-radius: 12px;
                text-align: center;
                z-index: 9999;
                font-size: 20px;
                font-weight: bold;
                box-shadow: 0 0 20px rgba(255, 105, 180, 0.5);
                animation: fadeIn 0.5s ease;
            ">
                🎊 彩蛋触发成功！<br>“塔菲喵最棒！应援永不停歇！”
            </div>
        `;
        document.body.appendChild(egg);

        // 自动移除
        setTimeout(() => egg.remove(), 5000);
    }
</script>

<style>
    @keyframes fadeIn {
        from { opacity: 0; transform: scale(0.9); }
        to { opacity: 1; transform: scale(1); }
    }
</style>


<body>
<div style="position: absolute; top: 20px; right: 30px;">
    <form action="profile.jsp" method="get">
        <input type="submit" value="个人中心" style="padding: 6px 12px; border-radius: 20px; border: none; background-color: #0088cc; color: white; font-weight: bold;">
    </form>
</div>

<div class="container">
    <h2>🎉 欢迎，<%= username %>！</h2>
    <p style="text-align:center; color:#888;">你已成功加入永雏塔菲后援会 🧁</p>
    <div id="countdown" style="text-align: center; font-size: 18px; margin: 20px auto; padding: 10px; background-color: #fff8f8; border-radius: 8px; border: 1px solid #ffd6e0;">
        🎂 正在加载倒计时...
    </div>

    <div style="text-align: center; margin-bottom: 20px;">
        <a href="about.jsp" class="btn-about">了解永雏塔菲</a>
    </div>

    <div class="chat-entry">
        <a href="chat.jsp">💬 进入聊天室</a>
    </div>


    <!-- 留言发布表单 -->
    <form method="post" action="postMessage">
        <textarea name="content" rows="4" placeholder="说点什么..."></textarea>
        <input type="submit" value="发布">
    </form>

    <!-- 留言展示区域 -->
    <div class="message-board">
        <h3>💬 留言板</h3>
        <ul class="message-list">
            <%
                try (Connection conn = DBUtil.getConnection()) {
                    String query = "SELECT posts.content, posts.created_at, posts.likes, users.username " +
                            "FROM posts " +
                            "JOIN users ON posts.user_id = users.id " +
                            "WHERE posts.status = 'active' " +
                            "ORDER BY posts.created_at DESC";
                    PreparedStatement ps = conn.prepareStatement(query);
                    ResultSet rs = ps.executeQuery();
                    while (rs.next()) {
            %>
            <li>
                <div class="message-item">
                    <div class="username"><strong><%= rs.getString("username") %>：</strong></div>
                    <div class="content"><%= rs.getString("content") %></div>
                    <div class="time">🕒 <%= rs.getTimestamp("created_at") %></div>
                    <div class="likes">👍 <%= rs.getInt("likes") %> 赞</div>
                </div>
            </li>
            <%
                    }
                } catch (Exception e) {
                    out.println("<li style='color:red;'>留言加载失败：" + e.getMessage() + "</li>");
                }
            %>
        </ul>

        <div style="text-align: center; margin: 30px 0;">
            <a href="quiz.jsp" class="btn-about">🎮 粉丝知识小测试</a>
        </div>


    </div>
    <!-- 应援图墙区域 -->
    <div class="gallery-section">
        <h3 style="text-align: center; margin-top: 40px;">📷 粉丝应援图墙</h3>
        <div class="image-gallery">
            <!-- 你可以在这里添加图片 -->
            <img src="images/taffy1.jpg" alt="应援图1">
            <img src="images/taffy2.jpg" alt="应援图2">
            <img src="images/taffy3.jpg" alt="应援图3">
            <!-- 更多图片可以继续添加 -->
        </div>
    </div>



</div>
</body>
</html>
