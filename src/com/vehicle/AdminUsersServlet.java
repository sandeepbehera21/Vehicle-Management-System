package com.vehicle;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/admin/users")
public class AdminUsersServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    public static class UserData {
        public int userId;
        public String name;
        public String email;
        public String phone;
        public String address;
        public boolean approved;
        public String createdAt;
        public int totalBookings;
        public double totalSpent;
        public String lastBookingDate;
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("admin_id") == null) {
            response.sendRedirect(request.getContextPath() + "/admin/login");
            return;
        }

        List<UserData> users = new ArrayList<>();
        try {
            DbConnection db = new DbConnection();
            Connection con = db.makeConnection();
            
            String sql = "SELECT u.user_id, u.name, u.email, u.phone, u.address, u.approved, " +
                        "u.created_at, COUNT(b.booking_id) as total_bookings, " +
                        "COALESCE(SUM(CASE WHEN b.status = 'Completed' THEN b.total_amount ELSE 0 END), 0) as total_spent, " +
                        "MAX(b.created_at) as last_booking_date " +
                        "FROM users u " +
                        "LEFT JOIN booking b ON u.user_id = b.user_id " +
                        "GROUP BY u.user_id, u.name, u.email, u.phone, u.address, u.approved, u.created_at " +
                        "ORDER BY u.created_at DESC";
            
            try (PreparedStatement ps = con.prepareStatement(sql);
                 ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    UserData u = new UserData();
                    u.userId = rs.getInt("user_id");
                    u.name = rs.getString("name");
                    u.email = rs.getString("email");
                    u.phone = rs.getString("phone");
                    u.address = rs.getString("address");
                    u.approved = rs.getBoolean("approved");
                    u.createdAt = rs.getString("created_at");
                    u.totalBookings = rs.getInt("total_bookings");
                    u.totalSpent = rs.getDouble("total_spent");
                    u.lastBookingDate = rs.getString("last_booking_date");
                    users.add(u);
                }
            }
        } catch (Exception e) {
            throw new ServletException(e);
        }

        request.setAttribute("users", users);
        request.getRequestDispatcher("/admin/users.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("admin_id") == null) {
            response.sendRedirect(request.getContextPath() + "/admin/login");
            return;
        }

        String action = request.getParameter("action");
        int userId = Integer.parseInt(request.getParameter("user_id"));

        try {
            DbConnection db = new DbConnection();
            Connection con = db.makeConnection();

            if ("approve".equals(action)) {
                String sql = "UPDATE users SET approved = true WHERE user_id = ?";
                try (PreparedStatement ps = con.prepareStatement(sql)) {
                    ps.setInt(1, userId);
                    ps.executeUpdate();
                }
            } else if ("disapprove".equals(action)) {
                String sql = "UPDATE users SET approved = false WHERE user_id = ?";
                try (PreparedStatement ps = con.prepareStatement(sql)) {
                    ps.setInt(1, userId);
                    ps.executeUpdate();
                }
            } else if ("delete".equals(action)) {
                // First delete associated bookings
                String deleteBookingsSql = "DELETE FROM booking WHERE user_id = ?";
                try (PreparedStatement ps = con.prepareStatement(deleteBookingsSql)) {
                    ps.setInt(1, userId);
                    ps.executeUpdate();
                }
                
                // Then delete the user
                String deleteUserSql = "DELETE FROM users WHERE user_id = ?";
                try (PreparedStatement ps = con.prepareStatement(deleteUserSql)) {
                    ps.setInt(1, userId);
                    ps.executeUpdate();
                }
            }
        } catch (Exception e) {
            throw new ServletException(e);
        }

        response.sendRedirect(request.getContextPath() + "/admin/users");
    }
}
