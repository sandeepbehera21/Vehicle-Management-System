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

@WebServlet("/admin/dashboard")
public class AdminDashboardServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
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

            // Status columns were planned but are not part of the current schema.
            // Treat all users/owners as active and set the others to 0 for now.
            long activeUsers = totalUsers;
            long pendingUsers = 0;
            long suspendedUsers = 0;

            long activeOwners = totalOwners;
            long pendingOwners = 0;
            long suspendedOwners = 0;

            // Get booking stats only if the status column exists
            long pendingBookings = safeCount(con,
                    "SELECT COUNT(*) FROM booking WHERE status = 'Pending'",
                    "SELECT COUNT(*) FROM booking");
            long approvedBookings = safeCount(con,
                    "SELECT COUNT(*) FROM booking WHERE status = 'Approved'",
                    "SELECT COUNT(*) FROM booking");
            long completedBookings = safeCount(con,
                    "SELECT COUNT(*) FROM booking WHERE status = 'Completed'",
                    "SELECT COUNT(*) FROM booking");

            // Vehicle table uses `availability` only; other status columns are not present
            long availableVehicles = getCount(con, "SELECT COUNT(*) FROM vehicle WHERE availability = 1");
            long onTripVehicles = 0; // Not tracked in current schema
            long maintenanceVehicles = 0; // Not tracked in current schema

            // Vehicle approval workflow not yet implemented in current schema
            long pendingVehicles = 0;
            long approvedVehicles = totalVehicles;
            long rejectedVehicles = 0;

            // Get financial stats
            double totalRevenue = safeAmount(con,
                    "SELECT COALESCE(SUM(total_amount), 0) FROM booking WHERE status = 'Completed'",
                    "SELECT COALESCE(SUM(total_amount), 0) FROM booking");
            double pendingAmount = safeAmount(con,
                    "SELECT COALESCE(SUM(total_amount), 0) FROM booking WHERE status IN ('Pending', 'Approved')",
                    "SELECT COALESCE(SUM(total_amount), 0) FROM booking");
            double maintenanceCost = 0.0; // No maintenance history table yet

            // Recent activity counts should guard against missing columns
            long recentBookings = getCount(con,
                    "SELECT COUNT(*) FROM booking WHERE created_at >= DATE_SUB(NOW(), INTERVAL 7 DAY)");
            long recentRegistrations = getFallbackRecentRegistrations(con, totalUsers);

            // Get rating statistics
            long totalRatings = safeCount(con,
                    "SELECT COUNT(*) FROM ratings",
                    "SELECT 0");
            double averageRating = safeAmount(con,
                    "SELECT COALESCE(AVG(rating), 0) FROM ratings",
                    "SELECT 0");

            // Get payment statistics
            double totalPayments = safeAmount(con,
                    "SELECT COALESCE(SUM(total_amount), 0) FROM payments WHERE payment_status = 'Completed'",
                    "SELECT 0");
            long ongoingTrips = safeCount(con,
                    "SELECT COUNT(*) FROM booking WHERE status = 'Ongoing'",
                    "SELECT 0");
            long returnedTrips = safeCount(con,
                    "SELECT COUNT(*) FROM booking WHERE status = 'Returned'",
                    "SELECT 0");

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

            request.setAttribute("pendingVehicles", pendingVehicles);
            request.setAttribute("approvedVehicles", approvedVehicles);
            request.setAttribute("rejectedVehicles", rejectedVehicles);

            request.setAttribute("totalRevenue", totalRevenue);
            request.setAttribute("pendingAmount", pendingAmount);
            request.setAttribute("maintenanceCost", maintenanceCost);

            request.setAttribute("recentBookings", recentBookings);
            request.setAttribute("recentRegistrations", recentRegistrations);
            
            // New attributes for ratings and payments
            request.setAttribute("totalRatings", totalRatings);
            request.setAttribute("averageRating", averageRating);
            request.setAttribute("totalPayments", totalPayments);
            request.setAttribute("ongoingTrips", ongoingTrips);
            request.setAttribute("returnedTrips", returnedTrips);

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

    private long safeCount(Connection con, String primarySql, String fallbackSql) throws Exception {
        try {
            return getCount(con, primarySql);
        } catch (SQLException ex) {
            if (isMissingColumn(ex)) {
                return getCount(con, fallbackSql);
            }
            throw ex;
        }
    }

    private double safeAmount(Connection con, String primarySql, String fallbackSql) throws Exception {
        try {
            return getAmount(con, primarySql);
        } catch (SQLException ex) {
            if (isMissingColumn(ex)) {
                return getAmount(con, fallbackSql);
            }
            throw ex;
        }
    }

    private double getAmount(Connection con, String sql) throws Exception {
        try (PreparedStatement ps = con.prepareStatement(sql);
                ResultSet rs = ps.executeQuery()) {
            rs.next();
            return rs.getDouble(1);
        }
    }

    private long getFallbackRecentRegistrations(Connection con, long totalUsers) throws Exception {
        try {
            return getCount(con,
                    "SELECT COUNT(*) FROM users WHERE created_at >= DATE_SUB(NOW(), INTERVAL 7 DAY)");
        } catch (SQLException ex) {
            if (isMissingColumn(ex)) {
                return totalUsers;
            }
            throw ex;
        }
    }

    private boolean isMissingColumn(SQLException ex) {
        return ex.getMessage() != null && ex.getMessage().contains("Unknown column");
    }
}
