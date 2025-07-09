<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title>你了解塔菲吗？</title>
    <style>
        body { font-family: "微软雅黑", sans-serif; background: #fff0f5; padding: 30px; }
        h2 { color: #e91e63; text-align: center; }
        .question { margin-bottom: 20px; }
        .submit-btn {
            padding: 10px 20px;
            background: #ff69b4;
            color: white;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            display: block;
            margin: 0 auto;
        }
        .result { text-align: center; font-weight: bold; margin-top: 20px; color: #4caf50; }
    </style>
</head>
<body>
<div style="position: fixed; top: 10px; left: 10px; z-index: 999;">
    <button onclick="history.back()" style="padding: 6px 12px; font-size: 14px; border-radius: 5px; border: none; background-color: #4CAF50; color: white; cursor: pointer;">
        ← 返回
    </button>
</div>
<h2>🎯 你了解永雏塔菲吗？来答题试试！</h2>

<form id="quizForm" onsubmit="return checkAnswers()">
    <div class="question">
        1. 永雏塔菲最喜欢的动物是？<br>
        <input type="radio" name="q1" value="cat">猫<br>
        <input type="radio" name="q1" value="dog">狗<br>
        <input type="radio" name="q1" value="rabbit">兔子<br>
    </div>
    <div class="question">
        2. 塔菲的生日是哪一天？<br>
        <input type="radio" name="q2" value="6-30">6月30日<br>
        <input type="radio" name="q2" value="8-12">8月12日<br>
        <input type="radio" name="q2" value="9-22">9月22日<br>
    </div>
    <div class="question">
        3. 塔菲直播时常说的口头禅是？<br>
        <input type="radio" name="q3" value="你好喵">你好喵<br>
        <input type="radio" name="q3" value="咪嗷">咪嗷<br>
        <input type="radio" name="q3" value="哈喽大家好">哈喽大家好<br>
    </div>
    <input type="submit" value="提交答题" class="submit-btn">
</form>

<div id="result" class="result"></div>

<script>
    function checkAnswers() {
        let score = 0;
        if (document.querySelector('input[name="q1"]:checked')?.value === "rabbit") score++;
        if (document.querySelector('input[name="q2"]:checked')?.value === "8-12") score++;
        if (document.querySelector('input[name="q3"]:checked')?.value === "你好喵") score++;

        let message = "你得了 " + score + " / 3 分！";
        if (score === 3) message += " 🎉你是塔菲骨灰级粉丝！";
        else if (score === 2) message += " 😸不错，了解还算多！";
        else message += " 🐣刚入坑？欢迎加入塔菲大家庭！";

        document.getElementById("result").innerText = message;


        document.getElementById("result").innerText = message;
        return false; // 阻止表单跳转
    }
</script>
<footer class="footer">
    <p> Copyright ©魅影网络科技有限公司 <br>
        我们立足于中华人民共和国，受当地法律保护！
    </p>
</footer>
</body>
</html>
