package com.vehicle;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/admin/dashboard")
public class AdminDashboardServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("admin_id") == null) {
            response.sendRedirect(request.getContextPath() + "/admin/login");
            return;
        }

        try {
            DbConnection db = new DbConnection();
            Connection con = db.makeConnection();

            // Get total counts
            long totalUsers = getCount(con, "SELECT COUNT(*) FROM users");
            long totalOwners = getCount(con, "SELECT COUNT(*) FROM owner");
            long totalVehicles = getCount(con, "SELECT COUNT(*) FROM vehicle");
            long totalBookings = getCount(con, "SELECT COUNT(*) FROM booking");

            // Status columns don't exist in current schema for users/owner.
            // Treat all users/owners as active and set the others to 0 for now.
            long activeUsers = totalUsers;
            long pendingUsers = 0;
            long suspendedUsers = 0;

            long activeOwners = totalOwners;
            long pendingOwners = 0;
            long suspendedOwners = 0;

            // Get booking stats
            long pendingBookings = getCount(con, "SELECT COUNT(*) FROM booking WHERE status = 'Pending'");
            long approvedBookings = getCount(con, "SELECT COUNT(*) FROM booking WHERE status = 'Approved'");
            long completedBookings = getCount(con, "SELECT COUNT(*) FROM booking WHERE status = 'Completed'");

            // Get vehicle stats
            long availableVehicles = getCount(con, "SELECT COUNT(*) FROM vehicle WHERE availability = 1");
            long onTripVehicles = getCount(con, "SELECT COUNT(*) FROM vehicle WHERE COALESCE(status, 'Available') = 'On Trip'");
            long maintenanceVehicles = getCount(con, "SELECT COUNT(*) FROM vehicle WHERE status = 'Maintenance'");

            // Get financial stats
            double totalRevenue = getAmount(con, "SELECT COALESCE(SUM(total_amount), 0) FROM booking WHERE status = 'Completed'");
            double pendingAmount = getAmount(con, "SELECT COALESCE(SUM(total_amount), 0) FROM booking WHERE status IN ('Pending', 'Approved')");
            // No maintenance_history table in current schema; show 0 instead of failing
            double maintenanceCost = 0.0;

            // Recent activity counts
            long recentBookings = getCount(con, "SELECT COUNT(*) FROM booking WHERE created_at >= DATE_SUB(NOW(), INTERVAL 7 DAY)");
            long recentRegistrations = getCount(con, "SELECT COUNT(*) FROM (SELECT created_at FROM users WHERE created_at >= DATE_SUB(NOW(), INTERVAL 7 DAY) UNION ALL SELECT created_at FROM owner WHERE created_at >= DATE_SUB(NOW(), INTERVAL 7 DAY)) combined");

            // Set all attributes
            request.setAttribute("totalUsers", totalUsers);
            request.setAttribute("totalOwners", totalOwners);
            request.setAttribute("totalVehicles", totalVehicles);
            request.setAttribute("totalBookings", totalBookings);

            request.setAttribute("activeUsers", activeUsers);
            request.setAttribute("pendingUsers", pendingUsers);
            request.setAttribute("suspendedUsers", suspendedUsers);

            request.setAttribute("activeOwners", activeOwners);
            request.setAttribute("pendingOwners", pendingOwners);
            request.setAttribute("suspendedOwners", suspendedOwners);

            request.setAttribute("pendingBookings", pendingBookings);
            request.setAttribute("approvedBookings", approvedBookings);
            request.setAttribute("completedBookings", completedBookings);

            request.setAttribute("availableVehicles", availableVehicles);
            request.setAttribute("onTripVehicles", onTripVehicles);
            request.setAttribute("maintenanceVehicles", maintenanceVehicles);

            request.setAttribute("totalRevenue", totalRevenue);
            request.setAttribute("pendingAmount", pendingAmount);
            request.setAttribute("maintenanceCost", maintenanceCost);

            request.setAttribute("recentBookings", recentBookings);
            request.setAttribute("recentRegistrations", recentRegistrations);

        } catch (Exception e) {
            throw new ServletException(e);
        }

        request.getRequestDispatcher("/admin/dashboard.jsp").forward(request, response);
    }

    private long getCount(Connection con, String sql) throws Exception {
        try (PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            rs.next();
            return rs.getLong(1);
        }
    }

    private double getAmount(Connection con, String sql) throws Exception {
        try (PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            rs.next();
            return rs.getDouble(1);
        }
    }
}