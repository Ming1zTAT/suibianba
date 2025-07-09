package com.example.yytfsupportsite.yytf.servlet;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.*;
import java.nio.file.*;
import java.sql.*;
import com.example.yytfsupportsite.yytf.util.DBUtil;

@WebServlet("/UpdateProfileServlet")
@MultipartConfig
public class UpdateProfileServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        int userId = (int) request.getSession().getAttribute("userId");
        String displayName = request.getParameter("displayName");

        Part filePart = request.getPart("avatar");
        String avatarPath = null;

        if (filePart != null && filePart.getSize() > 0) {
            String fileName = userId + "_" + System.currentTimeMillis() + ".png";
            String uploadPath = getServletContext().getRealPath("/") + "images/user";
            File dir = new File(uploadPath);
            if (!dir.exists()) dir.mkdirs();

            avatarPath = "images/user/" + fileName;
            filePart.write(uploadPath + File.separator + fileName);
        }

        try (Connection conn = DBUtil.getConnection()) {
            String sql = avatarPath != null
                    ? "UPDATE users SET display_name = ?, avatar = ? WHERE id = ?"
                    : "UPDATE users SET display_name = ? WHERE id = ?";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setString(1, displayName);
            if (avatarPath != null) {
                ps.setString(2, avatarPath);
                ps.setInt(3, userId);
            } else {
                ps.setInt(2, userId);
            }
            ps.executeUpdate();
            request.getSession().setAttribute("display_name", displayName);
        } catch (Exception e) {
            throw new ServletException(e);
        }

        response.sendRedirect("profile.jsp");
    }
}
