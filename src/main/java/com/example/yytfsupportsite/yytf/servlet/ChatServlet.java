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
        Part imagePart = request.getPart("image");

        boolean hasText = content != null && !content.trim().isEmpty();
        boolean hasImage = imagePart != null && imagePart.getSize() > 0;

        if (!hasText && !hasImage) {
            // 如果文字和图片都为空，不保存，返回聊天室
            response.sendRedirect("chat.jsp");
            return;
        }

        String imageUrl = null;

        if (hasImage) {
            // 获取上传路径
            String uploadPath = getServletContext().getRealPath("/") + "chat_images/";
            File uploadDir = new File(uploadPath);
            if (!uploadDir.exists()) uploadDir.mkdirs();

            // 保存文件（防止重复，加入时间戳）
            String fileName = System.currentTimeMillis() + "_" + imagePart.getSubmittedFileName();
            imagePart.write(uploadPath + fileName);

            // 存数据库路径
            imageUrl = "chat_images/" + fileName;
        }

        try (Connection conn = DBUtil.getConnection()) {
            PreparedStatement ps = conn.prepareStatement(
                    "INSERT INTO chat_messages (user_id, content, image_url, timestamp) VALUES (?, ?, ?, NOW())"
            );
            ps.setInt(1, userId);
            ps.setString(2, hasText ? content : null);
            ps.setString(3, imageUrl);
            ps.executeUpdate();
            ps.close();
        } catch (Exception e) {
            e.printStackTrace();
        }

        response.sendRedirect("chat.jsp");
    }
}
