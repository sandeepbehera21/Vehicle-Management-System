package com.vehicle;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/owner/bookings/action")
public class OwnerBookingActionServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("owner_id") == null) {
            response.sendRedirect(request.getContextPath() + "/owner/login");
            return;
        }

        String action = request.getParameter("action"); // approve | reject | complete
        int bookingId = Integer.parseInt(request.getParameter("booking_id"));
        int vehicleId = Integer.parseInt(request.getParameter("vehicle_id"));

        try {
            DbConnection db = new DbConnection();
            Connection con = db.makeConnection();

            if ("approve".equalsIgnoreCase(action)) {
                try (PreparedStatement ps = con.prepareStatement("UPDATE booking SET status='Approved' WHERE booking_id=?")) {
                    ps.setInt(1, bookingId);
                    ps.executeUpdate();
                }
                // Ensure vehicle not available
                try (PreparedStatement ps = con.prepareStatement("UPDATE vehicle SET availability=false WHERE vehicle_id=?")) {
                    ps.setInt(1, vehicleId);
                    ps.executeUpdate();
                }
            } else if ("reject".equalsIgnoreCase(action)) {
                try (PreparedStatement ps = con.prepareStatement("UPDATE booking SET status='Rejected' WHERE booking_id=?")) {
                    ps.setInt(1, bookingId);
                    ps.executeUpdate();
                }
                // Free the vehicle
                try (PreparedStatement ps = con.prepareStatement("UPDATE vehicle SET availability=true WHERE vehicle_id=?")) {
                    ps.setInt(1, vehicleId);
                    ps.executeUpdate();
                }
            } else if ("complete".equalsIgnoreCase(action)) {
                try (PreparedStatement ps = con.prepareStatement("UPDATE booking SET status='Completed' WHERE booking_id=?")) {
                    ps.setInt(1, bookingId);
                    ps.executeUpdate();
                }
                // Keep availability true after completion
                try (PreparedStatement ps = con.prepareStatement("UPDATE vehicle SET availability=true WHERE vehicle_id=?")) {
                    ps.setInt(1, vehicleId);
                    ps.executeUpdate();
                }
            }

            response.sendRedirect(request.getContextPath() + "/owner/bookings");
        } catch (Exception e) {
            throw new ServletException(e);
        }
    }
}
