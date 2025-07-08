package com.example.yytfsupportsite.yytf.servlet;

import com.example.yytfsupportsite.yytf.util.DBUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.nio.file.Files;
import java.sql.*;
import java.sql.Connection;

@WebServlet("/login")
public class LoginServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // 获取用户提交的用户名和密码
        String username = request.getParameter("username");
        String password = request.getParameter("password");

        // 默认给出一个登录失败的消息
        String loginMessage = "用户名或密码错误";

        try (Connection conn = DBUtil.getConnection()) {
            // 通过用户名和密码查询数据库
            PreparedStatement ps = conn.prepareStatement("SELECT id, username FROM users WHERE username = ? AND password = ?");
            ps.setString(1, username);
            ps.setString(2, password);
            ResultSet rs = ps.executeQuery();

            // 如果查询到了对应的用户
            if (rs.next()) {
                // 登录成功，获取 userId 并将其存入 session
                int userId = rs.getInt("id");
                request.getSession().setAttribute("userId", userId);  // 保存 userId 到 session
                request.getSession().setAttribute("username", username);  // 保存用户名到 session

                // 重定向到主页
                response.sendRedirect("home.jsp");
            } else {
                // 登录失败，返回失败信息
                request.setAttribute("loginMessage", loginMessage);
                request.getRequestDispatcher("login.jsp").forward(request, response);  // 返回到登录页并显示错误消息
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().println("登录异常：" + e.getMessage());
        }
    }
}