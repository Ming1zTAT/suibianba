package com.example.yytfsupportsite.yytf.servlet;

import com.example.yytfsupportsite.yytf.util.DBUtil;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.*;

@WebServlet("/SendPrivateMessageServlet")
public class SendPrivateMessageServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        int senderId = (int) request.getSession().getAttribute("userId");
        int receiverId = Integer.parseInt(request.getParameter("receiverId"));
        String content = request.getParameter("content");

        try (Connection conn = DBUtil.getConnection()) {
            PreparedStatement ps = conn.prepareStatement(
                    "INSERT INTO private_messages (sender_id, receiver_id, content) VALUES (?, ?, ?)");
            ps.setInt(1, senderId);
            ps.setInt(2, receiverId);
            ps.setString(3, content);
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
        response.sendRedirect("chat.jsp?friendId=" + receiverId);
    }
}
