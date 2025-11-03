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

@WebServlet("/owner/dashboard")
public class OwnerDashboardServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("owner_id") == null) {
            response.sendRedirect(request.getContextPath() + "/owner/login");
            return;
        }
        int ownerId = (Integer) session.getAttribute("owner_id");

        long totalVehicles = 0;
        long pendingVehicles = 0;
        long approvedVehicles = 0;
        long rejectedVehicles = 0;
        long pendingBookings = 0;
        long approvedBookings = 0;
        double totalRevenue = 0.0;
        
        // New variables for ratings and payments
        long totalRatings = 0;
        double averageRating = 0.0;
        double revenueFromPayments = 0.0;
        long ongoingTrips = 0;
        long returnedTrips = 0;

        try {
            DbConnection db = new DbConnection();
            Connection con = db.makeConnection();

            // Vehicle statistics by approval status
            try (PreparedStatement ps = con.prepareStatement("SELECT COUNT(*) FROM vehicle WHERE owner_id = ?")) {
                ps.setInt(1, ownerId);
                try (ResultSet rs = ps.executeQuery()) { if (rs.next()) totalVehicles = rs.getLong(1); }
            }

            try (PreparedStatement ps = con.prepareStatement("SELECT COUNT(*) FROM vehicle WHERE owner_id = ? AND approval_status = 'pending'")) {
                ps.setInt(1, ownerId);
                try (ResultSet rs = ps.executeQuery()) { if (rs.next()) pendingVehicles = rs.getLong(1); }
            }

            try (PreparedStatement ps = con.prepareStatement("SELECT COUNT(*) FROM vehicle WHERE owner_id = ? AND approval_status = 'approved'")) {
                ps.setInt(1, ownerId);
                try (ResultSet rs = ps.executeQuery()) { if (rs.next()) approvedVehicles = rs.getLong(1); }
            }

            try (PreparedStatement ps = con.prepareStatement("SELECT COUNT(*) FROM vehicle WHERE owner_id = ? AND approval_status = 'rejected'")) {
                ps.setInt(1, ownerId);
                try (ResultSet rs = ps.executeQuery()) { if (rs.next()) rejectedVehicles = rs.getLong(1); }
            }

            try (PreparedStatement ps = con.prepareStatement(
                    "SELECT COUNT(*) FROM booking b JOIN vehicle v ON b.vehicle_id = v.vehicle_id WHERE v.owner_id = ? AND b.status = 'Pending'")) {
                ps.setInt(1, ownerId);
                try (ResultSet rs = ps.executeQuery()) { if (rs.next()) pendingBookings = rs.getLong(1); }
            }

            try (PreparedStatement ps = con.prepareStatement(
                    "SELECT COUNT(*) FROM booking b JOIN vehicle v ON b.vehicle_id = v.vehicle_id WHERE v.owner_id = ? AND b.status = 'Approved'")) {
                ps.setInt(1, ownerId);
                try (ResultSet rs = ps.executeQuery()) { if (rs.next()) approvedBookings = rs.getLong(1); }
            }

            try (PreparedStatement ps = con.prepareStatement(
                    "SELECT COALESCE(SUM(total_amount),0) FROM booking b JOIN vehicle v ON b.vehicle_id = v.vehicle_id WHERE v.owner_id = ? AND b.status = 'Completed'")) {
                ps.setInt(1, ownerId);
                try (ResultSet rs = ps.executeQuery()) { if (rs.next()) totalRevenue = rs.getDouble(1); }
            }
            
            // Get rating statistics for owner
            try (PreparedStatement ps = con.prepareStatement("SELECT COUNT(*) FROM ratings WHERE owner_id = ?")) {
                ps.setInt(1, ownerId);
                try (ResultSet rs = ps.executeQuery()) { if (rs.next()) totalRatings = rs.getLong(1); }
            }
            
            try (PreparedStatement ps = con.prepareStatement("SELECT COALESCE(AVG(rating), 0) FROM ratings WHERE owner_id = ?")) {
                ps.setInt(1, ownerId);
                try (ResultSet rs = ps.executeQuery()) { if (rs.next()) averageRating = rs.getDouble(1); }
            }
            
            // Get payment statistics from revenue table
            try (PreparedStatement ps = con.prepareStatement("SELECT COALESCE(SUM(amount), 0) FROM revenue WHERE owner_id = ?")) {
                ps.setInt(1, ownerId);
                try (ResultSet rs = ps.executeQuery()) { if (rs.next()) revenueFromPayments = rs.getDouble(1); }
            }
            
            // Get ongoing and returned trips count
            try (PreparedStatement ps = con.prepareStatement(
                    "SELECT COUNT(*) FROM booking b JOIN vehicle v ON b.vehicle_id = v.vehicle_id WHERE v.owner_id = ? AND b.status = 'Ongoing'")) {
                ps.setInt(1, ownerId);
                try (ResultSet rs = ps.executeQuery()) { if (rs.next()) ongoingTrips = rs.getLong(1); }
            }
            
            try (PreparedStatement ps = con.prepareStatement(
                    "SELECT COUNT(*) FROM booking b JOIN vehicle v ON b.vehicle_id = v.vehicle_id WHERE v.owner_id = ? AND b.status = 'Returned'")) {
                ps.setInt(1, ownerId);
                try (ResultSet rs = ps.executeQuery()) { if (rs.next()) returnedTrips = rs.getLong(1); }
            }
        } catch (Exception e) {
            throw new ServletException(e);
        }

        request.setAttribute("totalVehicles", totalVehicles);
        request.setAttribute("pendingVehicles", pendingVehicles);
        request.setAttribute("approvedVehicles", approvedVehicles);
        request.setAttribute("rejectedVehicles", rejectedVehicles);
        request.setAttribute("pendingBookings", pendingBookings);
        request.setAttribute("approvedBookings", approvedBookings);
        request.setAttribute("totalRevenue", totalRevenue);
        
        // New attributes for ratings and payments
        request.setAttribute("totalRatings", totalRatings);
        request.setAttribute("averageRating", averageRating);
        request.setAttribute("revenueFromPayments", revenueFromPayments);
        request.setAttribute("ongoingTrips", ongoingTrips);
        request.setAttribute("returnedTrips", returnedTrips);
        request.getRequestDispatcher("/owner/dashboard.jsp").forward(request, response);
    }
}
