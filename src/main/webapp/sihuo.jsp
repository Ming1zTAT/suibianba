<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
  <title>我们的婚礼邀请函</title>
  <style>
    body {
      font-family: 'Georgia', serif;
      background: #fef9f4;
      color: #444;
      margin: 0;
      padding: 0;
    }
    .container {
      max-width: 700px;
      margin: 60px auto;
      background: white;
      padding: 50px;
      box-shadow: 0 10px 25px rgba(0,0,0,0.1);
      border-radius: 15px;
      text-align: center;
    }
    .header {
      font-size: 36px;
      color: #c58a44;
      margin-bottom: 20px;
      font-weight: bold;
    }
    .names {
      font-size: 28px;
      margin: 30px 0;
      color: #8c5e3c;
    }
    .heart {
      font-size: 32px;
      color: #e44d5f;
      margin: 10px 0;
    }
    .details {
      font-size: 18px;
      margin-top: 30px;
      line-height: 1.8;
    }
    .footer {
      margin-top: 50px;
      font-style: italic;
      font-size: 16px;
      color: #888;
    }
    .border-line {
      width: 100px;
      height: 3px;
      background-color: #c58a44;
      margin: 30px auto;
      border-radius: 2px;
    }
    .rsvp {
      margin-top: 30px;
      font-size: 16px;
      background-color: #c58a44;
      color: white;
      padding: 10px 20px;
      border-radius: 25px;
      display: inline-block;
      text-decoration: none;
    }
    .rsvp:hover {
      background-color: #a46f34;
    }
  </style>
  <style>
    body {
      font-family: 'Arial Rounded MT Bold', sans-serif;
      background: linear-gradient(to right, #ffe0f0, #fff7fa);
      text-align: center;
      padding: 40px;
    }

    .confirm-button {
      background-color: #ff6f91;
      border: none;
      color: white;
      padding: 10px 22px;
      font-size: 16px;
      border-radius: 24px;
      cursor: pointer;
      margin-top: 20px;
      box-shadow: 0 2px 6px rgba(0,0,0,0.2);
      transition: all 0.3s ease;
    }

    .confirm-button:hover {
      background-color: #ff4f70;
      transform: scale(1.05);
    }

    /* 模态框遮罩层 */
    .modal {
      display: none;
      position: fixed;
      z-index: 9999;
      left: 0; top: 0;
      width: 100%; height: 100%;
      background-color: rgba(0,0,0,0.4);
    }

    /* 模态框内容 */
    .modal-content {
      background-color: #fff;
      margin: 12% auto;
      padding: 15px;
      border-radius: 12px;
      width: 320px;
      max-width: 90%;
      box-shadow: 0 6px 20px rgba(0,0,0,0.25);
      position: relative;
      animation: fadeIn 0.4s ease;
    }

    @keyframes fadeIn {
      from { opacity: 0; transform: translateY(-20px); }
      to   { opacity: 1; transform: translateY(0); }
    }

    .modal-content img {
      max-width: 90%;
      border-radius: 8px;
      margin-top: 10px;
    }

    .close-btn {
      position: absolute;
      top: 8px;
      right: 12px;
      font-size: 20px;
      font-weight: bold;
      color: #aaa;
      cursor: pointer;
    }

    .close-btn:hover {
      color: #ff4d4d;
    }

    .modal-text {
      font-size: 15px;
      color: #555;
      margin-top: 8px;
    }
  </style>
</head>
<body>
<div class="container">
  <div class="header">婚礼邀请函</div>
  <div class="border-line"></div>
  <div class="names">
    李孟都&nbsp; <span class="heart">❤</span> &nbsp;陆依韵
  </div>
  <div class="details">
    我们怀着无比喜悦的心情，<br>
    诚邀您参加我们的婚礼庆典。<br><br>
    日期：2026年02月1日<br>
    时间：下午 5:00<br>
    地点：待定<br>
  </div>
  <div class="border-line"></div>
  <div class="footer">
    您的到来将是我们最珍贵的祝福<br>
    敬候您的光临！
  </div>
  <br>
  <button class="confirm-button" onclick="openModal()">确认出席</button>

  <!-- 模态框结构 -->
  <div id="myModal" class="modal">
    <div class="modal-content">
      <span class="close-btn" onclick="closeModal()">&times;</span>
      <img src="images/IMG_4120.JPG" alt="感谢您的随礼！">
      <p style="margin-top: 10px;">感谢您的随礼！<br>
        我们期待与您共度这美好时光！❤️</p>
    </div>
  </div>

  <!-- 弹窗控制脚本 -->
  <script>
    function openModal() {
      document.getElementById("myModal").style.display = "block";
    }

    function closeModal() {
      document.getElementById("myModal").style.display = "none";
    }

    // 点击遮罩层也关闭
    window.onclick = function(event) {
      const modal = document.getElementById("myModal");
      if (event.target === modal) {
        modal.style.display = "none";
      }
    }
  </script>

</div>
</body>
</html>
