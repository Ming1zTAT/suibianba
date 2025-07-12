package com.example.yytfsupportsite.yytf.servlet;

import com.example.yytfsupportsite.yytf.util.DBUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import com.example.yytfsupportsite.yytf.websocket.ChatWebSocket;

import java.io.*;
import java.sql.*;

@WebServlet("/ChatServlet")
@MultipartConfig
public class ChatServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession();

        Integer userId = (Integer) session.getAttribute("userId");
        if (userId == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        String content = request.getParameter("content");
        String chatWithIdParam = request.getParameter("chatWithId");
        Part imagePart = request.getPart("image");

        boolean hasText = content != null && !content.trim().isEmpty();
        boolean hasImage = imagePart != null && imagePart.getSize() > 0;

        if (!hasText && !hasImage) {
            if (chatWithIdParam != null && !chatWithIdParam.equals("-1")) {
                response.sendRedirect("chat.jsp?chatWith=" + chatWithIdParam);
            } else {
                response.sendRedirect("chat.jsp");
            }
            return;
        }

        int chatWithId = -1; // 默认是群聊
        if (chatWithIdParam != null && !chatWithIdParam.isEmpty()) {
            try {
                chatWithId = Integer.parseInt(chatWithIdParam);
            } catch (NumberFormatException ignored) {}
        }

        // 处理图片上传
        String imageUrl = null;
        if (hasImage) {
            String uploadPath = getServletContext().getRealPath("/") + "chat_images/";
            File uploadDir = new File(uploadPath);
            if (!uploadDir.exists()) uploadDir.mkdirs();

            String fileName = System.currentTimeMillis() + "_" + imagePart.getSubmittedFileName();
            String fullPath = uploadPath + fileName;
            imagePart.write(fullPath);

            imageUrl = "chat_images/" + fileName;
        }

        // 存入数据库
        try (Connection conn = DBUtil.getConnection()) {
            PreparedStatement ps;
            if (chatWithId == -1) {
                // 群聊：没有 receiver_id
                ps = conn.prepareStatement(
                        "INSERT INTO chat_messages (user_id, content, image_url, timestamp) " +
                                "VALUES (?, ?, ?, NOW())"
                );
                ps.setInt(1, userId);
                ps.setString(2, hasText ? content : null);
                ps.setString(3, imageUrl);
            } else {
                // 私聊：有 receiver_id
                ps = conn.prepareStatement(
                        "INSERT INTO chat_messages (user_id, content, image_url, timestamp, receiver_id) " +
                                "VALUES (?, ?, ?, NOW(), ?)"
                );
                ps.setInt(1, userId);
                ps.setString(2, hasText ? content : null);
                ps.setString(3, imageUrl);
                ps.setInt(4, chatWithId);
            }
            ps.executeUpdate();
            ps.close();
            // 获取发送者昵称和头像
            String senderName = (String) session.getAttribute("displayName");
            if (senderName == null) senderName = (String) session.getAttribute("username");

            String avatar = (String) session.getAttribute("avatar");
            if (avatar == null || avatar.isEmpty()) avatar = "images/taffy1.jpg";

// 当前时间
            String now = new java.sql.Timestamp(System.currentTimeMillis()).toString();

// 推送消息
            ChatWebSocket.pushMessage(
                    userId,
                    chatWithId == -1 ? null : chatWithId,
                    senderName,
                    avatar,
                    hasText ? content : "",
                    imageUrl != null ? imageUrl : "",
                    now
            );

        } catch (Exception e) {
            e.printStackTrace();
        }

        // 重定向回聊天页面
        if (chatWithId == -1) {
            response.sendRedirect("chat.jsp");
        } else {
            response.sendRedirect("chat.jsp?chatWith=" + chatWithId);
        }
    }
}
