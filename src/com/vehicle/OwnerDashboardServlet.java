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
        long pendingBookings = 0;
        long approvedBookings = 0;
        double totalRevenue = 0.0;

        try {
            DbConnection db = new DbConnection();
            Connection con = db.makeConnection();

            try (PreparedStatement ps = con.prepareStatement("SELECT COUNT(*) FROM vehicle WHERE owner_id = ?")) {
                ps.setInt(1, ownerId);
                try (ResultSet rs = ps.executeQuery()) { if (rs.next()) totalVehicles = rs.getLong(1); }
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
        } catch (Exception e) {
            throw new ServletException(e);
        }

        request.setAttribute("totalVehicles", totalVehicles);
        request.setAttribute("pendingBookings", pendingBookings);
        request.setAttribute("approvedBookings", approvedBookings);
        request.setAttribute("totalRevenue", totalRevenue);
        request.getRequestDispatcher("/owner/dashboard.jsp").forward(request, response);
    }
}
