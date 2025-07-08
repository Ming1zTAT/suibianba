package com.example.yytfsupportsite.yytf.servlet;

import com.example.yytfsupportsite.yytf.util.DBUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.*;
import java.sql.*;
import java.util.*;

@WebServlet("/ChatServlet")
@MultipartConfig
public class ChatServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
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
            response.sendRedirect("chat.jsp");
            return;
        }

        int chatWithId = -1; // 默认是群聊
        if (chatWithIdParam != null && !chatWithIdParam.isEmpty()) {
            try {
                chatWithId = Integer.parseInt(chatWithIdParam);
            } catch (NumberFormatException ignored) {}
        }

        String imageUrl = null;
        if (hasImage) {
            String uploadPath = getServletContext().getRealPath("/") + "chat_images/";
            File uploadDir = new File(uploadPath);
            if (!uploadDir.exists()) uploadDir.mkdirs();

            String fileName = System.currentTimeMillis() + "_" + imagePart.getSubmittedFileName();
            imagePart.write(uploadPath + fileName);

            imageUrl = "chat_images/" + fileName;
        }

        try (Connection conn = DBUtil.getConnection()) {
            PreparedStatement ps;
            if (chatWithId == -1) {
                ps = conn.prepareStatement(
                        "INSERT INTO chat_messages (user_id, content, image_url, timestamp) VALUES (?, ?, ?, NOW())"
                );
                ps.setInt(1, userId);
                ps.setString(2, hasText ? content : null);
                ps.setString(3, imageUrl);
            } else {
                ps = conn.prepareStatement(
                        "INSERT INTO chat_messages (user_id, content, image_url, timestamp, receiver_id) VALUES (?, ?, ?, NOW(), ?)"
                );
                ps.setInt(1, userId);
                ps.setString(2, hasText ? content : null);
                ps.setString(3, imageUrl);
                ps.setInt(4, chatWithId);
            }
            ps.executeUpdate();
            ps.close();
        } catch (Exception e) {
            e.printStackTrace();
        }

        if (chatWithId == -1) {
            response.sendRedirect("chat.jsp");
        } else {
            response.sendRedirect("chat.jsp?chatWith=" + chatWithId);
        }
    }

}
