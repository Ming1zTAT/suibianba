package com.example.yytfsupportsite.yytf.servlet;

import com.example.yytfsupportsite.yytf.util.DBUtil;
import com.google.gson.Gson;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@WebServlet("/GetMessagesServlet")
public class GetMessagesServlet extends HttpServlet {
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession();
        Integer userId = (Integer) session.getAttribute("userId");
        if (userId == null) { resp.sendError(403); return; }

        String chatWithStr = req.getParameter("chatWith");
        int chatWith = chatWithStr != null ? Integer.parseInt(chatWithStr) : -1;

        List<Map<String, Object>> msgs = new ArrayList<>();
        try (Connection c = DBUtil.getConnection()) {
            PreparedStatement ps;
            if (chatWith == -1) {
                ps = c.prepareStatement(
                        "SELECT c.id, c.user_id, c.receiver_id, c.content, c.image_url, c.timestamp, u.display_name, u.username, u.avatar " +
                                "FROM chat_messages c JOIN users u ON c.user_id=u.id " +
                                "WHERE c.receiver_id IS NULL ORDER BY c.timestamp ASC"
                );
            } else {
                ps = c.prepareStatement(
                        "SELECT c.id, c.user_id, c.receiver_id, c.content, c.image_url, c.timestamp, u.display_name, u.username, u.avatar " +
                                "FROM chat_messages c JOIN users u ON c.user_id=u.id " +
                                "WHERE (c.user_id=? AND c.receiver_id=?) OR (c.user_id=? AND c.receiver_id=?) ORDER BY c.timestamp ASC"
                );
                ps.setInt(1, userId);
                ps.setInt(2, chatWith);
                ps.setInt(3, chatWith);
                ps.setInt(4, userId);
            }
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Map<String, Object> m = new HashMap<>();
                String name = rs.getString("display_name");
                if (name == null) name = rs.getString("username");
                m.put("senderName", name);
                String avatar = rs.getString("avatar");
                m.put("avatar", avatar != null && !avatar.isEmpty() ? avatar : "images/taffy1.jpg");
                m.put("content", rs.getString("content"));
                m.put("image", rs.getString("image_url"));
                m.put("time", rs.getTimestamp("timestamp").toString());
                msgs.add(m);
            }
        } catch (Exception e) {
            resp.sendError(500);
            return;
        }
        resp.setContentType("application/json;charset=UTF-8");
        resp.getWriter().write(new Gson().toJson(msgs));  // 记得引入Gson依赖
    }
}
