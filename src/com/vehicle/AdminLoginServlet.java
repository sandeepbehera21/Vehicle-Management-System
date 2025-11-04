package com.vehicle;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
@WebServlet("/admin/login")
public class AdminLoginServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.getRequestDispatcher("/admin/admin_login.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String email = request.getParameter("email");
        if (email == null || email.isEmpty()) {
            email = request.getParameter("username");
        }
        String password = request.getParameter("password");

        if (email == null || password == null || email.isEmpty() || password.isEmpty()) {
            request.setAttribute("error", "Email and password are required.");
            request.getRequestDispatcher("/admin/admin_login.jsp").forward(request, response);
            return;
        }

        try {
            DbConnection db = new DbConnection();
            try (Connection con = db.makeConnection();
                 PreparedStatement ps = con.prepareStatement(
                         "SELECT admin_id, name, email FROM admin WHERE email = ? AND password = ? LIMIT 1")) {
                ps.setString(1, email);
                ps.setString(2, password);

                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        HttpSession session = request.getSession();
                        session.setAttribute("admin_id", rs.getInt("admin_id"));
                        session.setAttribute("admin_username", rs.getString("email"));
                        session.setAttribute("admin_name", rs.getString("name"));
                        session.setAttribute("admin_email", rs.getString("email"));
                        response.sendRedirect(request.getContextPath() + "/admin/dashboard");
                        return;
                    }
                }
            }
        } catch (ClassNotFoundException | SQLException e) {
            throw new ServletException(e);
        }

        request.setAttribute("error", "Invalid email or password.");
        request.getRequestDispatcher("/admin/admin_login.jsp").forward(request, response);
    }
}
