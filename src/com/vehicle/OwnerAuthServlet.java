package com.vehicle;

import java.io.IOException;
import java.sql.*;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

/**
 * Owner authentication and registration servlet.
 * URL patterns: /owner/register, /owner/login
 */
public class OwnerAuthServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    public void init() throws ServletException {
        // Ensure table exists and columns are up-to-date
        try (Connection con = new DbConnection().makeConnection();
             Statement st = con.createStatement()) {
            // Create table if missing (latest schema)
            st.executeUpdate(
                "CREATE TABLE IF NOT EXISTS owner (" +
                "owner_id INT AUTO_INCREMENT PRIMARY KEY, " +
                "name VARCHAR(100) NOT NULL, " +
                "email VARCHAR(150) UNIQUE NOT NULL, " +
                "password VARCHAR(255) NOT NULL, " +
                "phone VARCHAR(20), " +
                "address VARCHAR(255), " +
                "approved BOOLEAN DEFAULT FALSE, " +
                "created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP" +
                ") ENGINE=InnoDB DEFAULT CHARSET=utf8mb4"
            );
            // Bring older schemas up to date (MySQL 8+ supports IF NOT EXISTS)
            st.executeUpdate("ALTER TABLE owner ADD COLUMN IF NOT EXISTS phone VARCHAR(20)");
            st.executeUpdate("ALTER TABLE owner ADD COLUMN IF NOT EXISTS address VARCHAR(255)");
            st.executeUpdate("ALTER TABLE owner ADD COLUMN IF NOT EXISTS approved BOOLEAN DEFAULT FALSE");
        } catch (Exception e) {
            throw new ServletException("Failed to ensure owner table", e);
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String path = request.getServletPath();
        if ("/owner/register".equals(path)) {
            request.getRequestDispatcher("/owner/owner_register.jsp").forward(request, response);
        } else if ("/owner/login".equals(path)) {
            request.getRequestDispatcher("/owner/owner_login.jsp").forward(request, response);
        } else {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String path = request.getServletPath();
        try (Connection con = new DbConnection().makeConnection()) {
            if ("/owner/register".equals(path)) {
                String name = request.getParameter("name");
                String email = request.getParameter("email");
                String password = request.getParameter("password");
                String phone = request.getParameter("phone");
                String address = request.getParameter("address");

                String sql = "INSERT INTO owner(name, email, password, phone, address, approved) VALUES(?,?,?,?,?,?)";
                try (PreparedStatement ps = con.prepareStatement(sql)) {
                    ps.setString(1, name);
                    ps.setString(2, email);
                    ps.setString(3, password); // For demo; ideally hash
                    ps.setString(4, phone);
                    ps.setString(5, address);
                    ps.setBoolean(6, true); // auto-approve for demo
                    ps.executeUpdate();
                }
                request.setAttribute("message", "Registration successful. Please login.");
                request.getRequestDispatcher("/owner/owner_login.jsp").forward(request, response);
                return;
            }

            if ("/owner/login".equals(path)) {
                String email = request.getParameter("email");
                String password = request.getParameter("password");
                String sql = "SELECT owner_id, name, approved FROM owner WHERE email=? AND password=?";
                try (PreparedStatement ps = con.prepareStatement(sql)) {
                    ps.setString(1, email);
                    ps.setString(2, password);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) {
                            if (!rs.getBoolean("approved")) {
                                request.setAttribute("message", "Your account is awaiting approval.");
                                request.getRequestDispatcher("/owner/owner_login.jsp").forward(request, response);
                                return;
                            }
                            HttpSession session = request.getSession(true);
                            session.setAttribute("owner_id", rs.getInt("owner_id"));
                            session.setAttribute("owner_email", email);
                            session.setAttribute("owner_name", rs.getString("name"));
                            // Go to Owner Dashboard
                            request.getRequestDispatcher("/owner/dashboard.jsp").forward(request, response);
                        } else {
                            request.setAttribute("message", "Invalid email or password");
                            request.getRequestDispatcher("/owner/owner_login.jsp").forward(request, response);
                        }
                    }
                }
                return;
            }
        } catch (Exception e) {
            throw new ServletException(e);
        }
        response.sendError(HttpServletResponse.SC_NOT_FOUND);
    }
}
