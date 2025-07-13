
package com.example.yytfsupportsite.yytf.servlet;

import com.example.yytfsupportsite.yytf.util.DBUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.*;
import java.nio.file.Paths;
import java.sql.Connection;
import java.sql.PreparedStatement;

@WebServlet("/UpdateProfileServlet")
@MultipartConfig
public class UpdateProfileServlet extends HttpServlet {
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

        String displayName = request.getParameter("displayName");
        Part part = request.getPart("avatar");
        String avatarUrl = null;

        if (part != null && part.getSize() > 0) {
            // 设置外部路径
            String savePath = "/www/avatar";
            File saveDir = new File(savePath);
            if (!saveDir.exists()) {
                saveDir.mkdirs();
            }

            String submittedFileName = Paths.get(part.getSubmittedFileName()).getFileName().toString();
            String extension = submittedFileName.substring(submittedFileName.lastIndexOf('.'));
            String newFileName = "avatar_user_" + userId + "_" + System.currentTimeMillis() + extension;
            String fullPath = savePath + File.separator + newFileName;
            part.write(fullPath);

            // 保存数据库路径（相对路径）
            avatarUrl = "/avatar/" + newFileName;
        }

        try (Connection conn = DBUtil.getConnection()) {
            PreparedStatement ps = conn.prepareStatement("UPDATE users SET display_name=?, avatar=? WHERE id=?");
            ps.setString(1, displayName);
            ps.setString(2, avatarUrl);
            ps.setInt(3, userId);
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }

        response.sendRedirect("profile.jsp");
    }
}
