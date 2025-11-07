package com.vehicle;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.time.LocalDate;
import java.time.temporal.ChronoUnit;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/user/create_booking")
public class CreateBookingServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user_id") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        int userId = (Integer) session.getAttribute("user_id");
        int vehicleId = Integer.parseInt(request.getParameter("vehicle_id"));
        double rentPerDay = Double.parseDouble(request.getParameter("rent_per_day"));
        double rentPerHour = rentPerDay / 24.0;
        String startDateStr = request.getParameter("start_date");
        String endDateStr = request.getParameter("end_date");
        String startTimeStr = request.getParameter("start_time");
        String endTimeStr = request.getParameter("end_time");
        String pickupLocation = request.getParameter("pickup_location");
        String dropLocation = request.getParameter("drop_location");
        String bookingTime = request.getParameter("booking_time");

        java.time.LocalDateTime startDateTime = java.time.LocalDateTime.parse(startDateStr + "T" + (startTimeStr != null ? startTimeStr : "00:00"));
        java.time.LocalDateTime endDateTime = java.time.LocalDateTime.parse(endDateStr + "T" + (endTimeStr != null ? endTimeStr : "00:00"));

        long hours = Math.max(ChronoUnit.HOURS.between(startDateTime, endDateTime), 1); // minimum 1 hour
        double totalAmount = (rentPerDay / 24.0) * hours; // prorated by hour
        String duration = hours + " hours";
        String route = pickupLocation + " to " + dropLocation;

        DbConnection db = new DbConnection();
        try {
            Connection con = db.makeConnection();
            // Availability check: overlap with existing bookings
            String checkSql = "SELECT COUNT(*) FROM booking WHERE vehicle_id = ? AND (start_date <= ? AND end_date >= ?) AND status IN ('Pending','Approved','On Trip')";
            try (PreparedStatement ps = con.prepareStatement(checkSql)) {
                ps.setInt(1, vehicleId);
                ps.setString(2, endDateStr);
                ps.setString(3, startDateStr);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next() && rs.getInt(1) > 0) {
                        con.close();
                        response.sendRedirect(request.getContextPath() + "/user/booking_form?vehicle_id=" + vehicleId + "&error=unavailable");
                        return;
                    }
                }
            }

            String sql = "INSERT INTO booking (user_id, vehicle_id, start_date, end_date, total_amount, status, route, duration) VALUES (?, ?, ?, ?, ?, 'Pending', ?, ?)";
            try (PreparedStatement ps = con.prepareStatement(sql)) {
                ps.setInt(1, userId);
                ps.setInt(2, vehicleId);
                ps.setString(3, startDateStr);
                ps.setString(4, endDateStr);
                ps.setDouble(5, totalAmount);
                ps.setString(6, route);
                ps.setString(7, duration);
                ps.executeUpdate();
            }

            // Optional: persist pickup/drop/booking_time and rent_per_hour if columns exist
            try {
                String updateExtras = "UPDATE booking SET pickup_location = ?, drop_location = ?, booking_time = ?, start_time = ?, end_time = ?, rent_per_hour = ? " +
                                      "WHERE user_id = ? AND vehicle_id = ? AND start_date = ? AND end_date = ? AND total_amount = ? LIMIT 1";
                try (PreparedStatement ps = con.prepareStatement(updateExtras)) {
                    ps.setString(1, pickupLocation);
                    ps.setString(2, dropLocation);
                    ps.setString(3, bookingTime);
                    ps.setString(4, startTimeStr);
                    ps.setString(5, endTimeStr);
                    ps.setDouble(6, rentPerHour);
                    ps.setInt(7, userId);
                    ps.setInt(8, vehicleId);
                    ps.setString(9, startDateStr);
                    ps.setString(10, endDateStr);
                    ps.setDouble(11, totalAmount);
                    ps.executeUpdate();
                }
            } catch (Exception ignore) {
                // Fields may not exist yet; ignoring to avoid breaking flow
            }
            con.close();
        } catch (Exception e) {
            throw new ServletException(e);
        }

        response.sendRedirect(request.getContextPath() + "/user/dashboard?booking=success");
    }
}
