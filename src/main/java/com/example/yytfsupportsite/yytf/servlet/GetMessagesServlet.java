package com.example.yytfsupportsite.yytf.servlet;

import com.example.yytfsupportsite.yytf.util.DBUtil;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

@WebServlet("/GetMessagesServlet")
public class GetMessagesServlet extends HttpServlet {
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        response.setContentType("application/json;charset=UTF-8");

        int userId = (int) request.getSession().getAttribute("userId");
        int chatWithId = Integer.parseInt(request.getParameter("chatWith"));

        try (Connection conn = DBUtil.getConnection()) {
            PreparedStatement ps;
            if (chatWithId == -1) {  // 群聊
                ps = conn.prepareStatement(
                        "SELECT c.*, u.display_name, u.avatar FROM chat_messages c JOIN users u ON c.user_id = u.id " +
                                "WHERE c.receiver_id IS NULL ORDER BY c.timestamp ASC"
                );
            } else {  // 私聊
                ps = conn.prepareStatement(
                        "SELECT c.*, u.display_name, u.avatar FROM chat_messages c JOIN users u ON c.user_id = u.id " +
                                "WHERE (c.user_id=? AND c.receiver_id=?) OR (c.user_id=? AND c.receiver_id=?) " +
                                "ORDER BY c.timestamp ASC"
                );
                ps.setInt(1, userId);
                ps.setInt(2, chatWithId);
                ps.setInt(3, chatWithId);
                ps.setInt(4, userId);
            }

            ResultSet rs = ps.executeQuery();
            StringBuilder json = new StringBuilder("[");
            boolean first = true;
            while (rs.next()) {
                if (!first) json.append(",");
                json.append("{")
                        .append("\"sender\":\"").append(rs.getString("display_name")).append("\",")
                        .append("\"content\":\"").append(rs.getString("content") == null ? "" : rs.getString("content")).append("\",")
                        .append("\"image\":\"").append(rs.getString("image_url") == null ? "" : rs.getString("image_url")).append("\",")
                        .append("\"time\":\"").append(rs.getTimestamp("timestamp")).append("\",")
                        .append("\"avatar\":\"").append(rs.getString("avatar") == null ? "" : rs.getString("avatar")).append("\"")
                        .append("}");
                first = false;
            }
            json.append("]");
            rs.close();
            ps.close();

            response.getWriter().write(json.toString());

        } catch (Exception e) {
            response.getWriter().write("[]");
            e.printStackTrace();
        }
    }
}


