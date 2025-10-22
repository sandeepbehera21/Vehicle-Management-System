package com.vehicle;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Timestamp;
import java.time.LocalDateTime;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/user/payment")
public class PaymentServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user_id") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        int userId = (int) session.getAttribute("user_id");
        int bookingId = Integer.parseInt(request.getParameter("booking_id"));
        int vehicleId = Integer.parseInt(request.getParameter("vehicle_id"));
        double rentCharges = Double.parseDouble(request.getParameter("rent_charges"));
        double lateFee = Double.parseDouble(request.getParameter("late_fee"));
        double securityDeposit = Double.parseDouble(request.getParameter("security_deposit"));
        double finalAmount = Double.parseDouble(request.getParameter("final_amount"));
        long hoursUsed = Long.parseLong(request.getParameter("hours_used"));

        // Get vehicle and owner details for display
        DbConnection db = new DbConnection();
        try {
            Connection con = db.makeConnection();
            
            String sql = "SELECT v.vehicle_name, v.vehicle_model, v.image_url, o.name AS owner_name " +
                        "FROM vehicle v " +
                        "JOIN owner o ON v.owner_id = o.owner_id " +
                        "WHERE v.vehicle_id = ?";

            try (PreparedStatement ps = con.prepareStatement(sql)) {
                ps.setInt(1, vehicleId);
                
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        request.setAttribute("booking_id", bookingId);
                        request.setAttribute("vehicle_id", vehicleId);
                        request.setAttribute("vehicle_name", rs.getString("vehicle_name"));
                        request.setAttribute("vehicle_model", rs.getString("vehicle_model"));
                        request.setAttribute("image_url", rs.getString("image_url"));
                        request.setAttribute("owner_name", rs.getString("owner_name"));
                        request.setAttribute("rent_charges", rentCharges);
                        request.setAttribute("late_fee", lateFee);
                        request.setAttribute("security_deposit", securityDeposit);
                        request.setAttribute("final_amount", finalAmount);
                        request.setAttribute("hours_used", hoursUsed);
                        
                        request.getRequestDispatcher("/user/payment.jsp").forward(request, response);
                    } else {
                        response.sendRedirect(request.getContextPath() + "/user/my_trips?error=vehicle_not_found");
                    }
                }
            }
            con.close();
        } catch (Exception e) {
            throw new ServletException(e);
        }
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // Redirect GET requests to POST
        response.sendRedirect(request.getContextPath() + "/user/my_trips");
    }
}
