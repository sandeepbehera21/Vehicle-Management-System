package com.vehicle;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.time.temporal.ChronoUnit;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/user/return_vehicle")
public class ReturnVehicleServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user_id") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        int bookingId = Integer.parseInt(request.getParameter("booking_id"));
        int userId = (int) session.getAttribute("user_id");

        DbConnection db = new DbConnection();
        try {
            Connection con = db.makeConnection();
            
            // Get booking details with vehicle and owner information
            String sql = "SELECT b.booking_id, b.vehicle_id, b.start_date, b.end_date, b.total_amount, " +
                        "b.pickup_location, b.drop_location, b.rent_per_hour, b.security_deposit, " +
                        "v.vehicle_name, v.vehicle_model, v.vehicle_type, v.image_url, v.rent_per_day, " +
                        "o.name AS owner_name, o.phone AS owner_phone, b.created_at " +
                        "FROM booking b " +
                        "JOIN vehicle v ON b.vehicle_id = v.vehicle_id " +
                        "JOIN owner o ON v.owner_id = o.owner_id " +
                        "WHERE b.booking_id = ? AND b.user_id = ? AND b.status IN ('Ongoing','Approved')";

            try (PreparedStatement ps = con.prepareStatement(sql)) {
                ps.setInt(1, bookingId);
                ps.setInt(2, userId);
                
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        // Calculate actual duration and fare
                        Timestamp startTime = rs.getTimestamp("created_at");
                        LocalDateTime startDateTime = startTime.toLocalDateTime();
                        LocalDateTime currentDateTime = LocalDateTime.now();
                        
                        long hoursUsed = ChronoUnit.HOURS.between(startDateTime, currentDateTime);
                        if (hoursUsed < 1) hoursUsed = 1; // Minimum 1 hour charge
                        
                        double rentPerHour = rs.getDouble("rent_per_hour");
                        if (rentPerHour == 0) {
                            rentPerHour = rs.getDouble("rent_per_day") / 24; // Fallback calculation
                        }
                        
                        double totalFare = hoursUsed * rentPerHour;
                        double securityDeposit = rs.getDouble("security_deposit");
                        
                        // Calculate late fee if returned after expected end date
                        LocalDateTime expectedEndTime = rs.getDate("end_date").toLocalDate().atTime(23, 59);
                        double lateFee = 0.0;
                        if (currentDateTime.isAfter(expectedEndTime)) {
                            long lateHours = ChronoUnit.HOURS.between(expectedEndTime, currentDateTime);
                            lateFee = lateHours * rentPerHour * 1.5; // 1.5x rate for late hours
                        }
                        
                        // Set all attributes for the JSP
                        request.setAttribute("booking_id", rs.getInt("booking_id"));
                        request.setAttribute("vehicle_id", rs.getInt("vehicle_id"));
                        request.setAttribute("vehicle_name", rs.getString("vehicle_name"));
                        request.setAttribute("vehicle_model", rs.getString("vehicle_model"));
                        request.setAttribute("vehicle_type", rs.getString("vehicle_type"));
                        request.setAttribute("image_url", rs.getString("image_url"));
                        request.setAttribute("pickup_location", rs.getString("pickup_location"));
                        request.setAttribute("drop_location", rs.getString("drop_location"));
                        request.setAttribute("start_date", rs.getDate("start_date"));
                        request.setAttribute("end_date", rs.getDate("end_date"));
                        request.setAttribute("start_time", startDateTime);
                        request.setAttribute("return_time", currentDateTime);
                        request.setAttribute("hours_used", hoursUsed);
                        request.setAttribute("rent_per_hour", rentPerHour);
                        request.setAttribute("total_fare", totalFare);
                        request.setAttribute("late_fee", lateFee);
                        request.setAttribute("security_deposit", securityDeposit);
                        request.setAttribute("final_amount", totalFare + lateFee);
                        request.setAttribute("owner_name", rs.getString("owner_name"));
                        request.setAttribute("owner_phone", rs.getString("owner_phone"));
                        
                        request.getRequestDispatcher("/user/return_confirmation.jsp").forward(request, response);
                    } else {
                        response.sendRedirect(request.getContextPath() + "/user/my_trips?error=invalid_booking");
                    }
                }
            }
            con.close();
        } catch (Exception e) {
            throw new ServletException(e);
        }
    }
}
