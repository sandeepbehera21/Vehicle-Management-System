package com.vehicle;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.util.UUID;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/user/process_payment")
public class ProcessPaymentServlet extends HttpServlet {
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
        String paymentMethod = request.getParameter("payment_method");

        DbConnection db = new DbConnection();
        Connection con = null;
        
        try {
            con = db.makeConnection();
            con.setAutoCommit(false); // Start transaction
            
            // Generate transaction ID
            String transactionId = "TXN" + System.currentTimeMillis() + UUID.randomUUID().toString().substring(0, 8).toUpperCase();
            
            // Get owner_id for revenue tracking
            String getOwnerSql = "SELECT v.owner_id, v.vehicle_name FROM vehicle v WHERE v.vehicle_id = ?";
            int ownerId = 0;
            String vehicleName = "";
            
            try (PreparedStatement ps = con.prepareStatement(getOwnerSql)) {
                ps.setInt(1, vehicleId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        ownerId = rs.getInt("owner_id");
                        vehicleName = rs.getString("vehicle_name");
                    }
                }
            }
            
            // Insert payment record
            String paymentSql = "INSERT INTO payments (booking_id, user_id, vehicle_id, rent_charges, late_fee, " +
                               "security_deposit_adjustment, total_amount, payment_method, payment_status, transaction_id) " +
                               "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
            
            try (PreparedStatement ps = con.prepareStatement(paymentSql)) {
                ps.setInt(1, bookingId);
                ps.setInt(2, userId);
                ps.setInt(3, vehicleId);
                ps.setDouble(4, rentCharges);
                ps.setDouble(5, lateFee);
                ps.setDouble(6, -securityDeposit); // Negative because it's a refund
                ps.setDouble(7, finalAmount);
                ps.setString(8, paymentMethod);
                ps.setString(9, "Completed");
                ps.setString(10, transactionId);
                ps.executeUpdate();
            }
            
            // Update booking status and return details
            String updateBookingSql = "UPDATE booking SET status = 'Returned', actual_return_date = ?, " +
                                     "late_fee = ?, payment_method = ?, payment_status = 'Paid' " +
                                     "WHERE booking_id = ?";
            
            try (PreparedStatement ps = con.prepareStatement(updateBookingSql)) {
                ps.setTimestamp(1, Timestamp.valueOf(LocalDateTime.now()));
                ps.setDouble(2, lateFee);
                ps.setString(3, paymentMethod);
                ps.setInt(4, bookingId);
                ps.executeUpdate();
            }
            
            // Update vehicle availability
            String updateVehicleSql = "UPDATE vehicle SET availability = TRUE WHERE vehicle_id = ?";
            try (PreparedStatement ps = con.prepareStatement(updateVehicleSql)) {
                ps.setInt(1, vehicleId);
                ps.executeUpdate();
            }
            
            // Add revenue records for owner
            if (rentCharges > 0) {
                String revenueSql = "INSERT INTO revenue (owner_id, booking_id, vehicle_id, amount, revenue_date, revenue_type) " +
                                   "VALUES (?, ?, ?, ?, CURDATE(), 'Rental')";
                try (PreparedStatement ps = con.prepareStatement(revenueSql)) {
                    ps.setInt(1, ownerId);
                    ps.setInt(2, bookingId);
                    ps.setInt(3, vehicleId);
                    ps.setDouble(4, rentCharges);
                    ps.executeUpdate();
                }
            }
            
            if (lateFee > 0) {
                String lateFeeRevenueSql = "INSERT INTO revenue (owner_id, booking_id, vehicle_id, amount, revenue_date, revenue_type) " +
                                          "VALUES (?, ?, ?, ?, CURDATE(), 'Late_Fee')";
                try (PreparedStatement ps = con.prepareStatement(lateFeeRevenueSql)) {
                    ps.setInt(1, ownerId);
                    ps.setInt(2, bookingId);
                    ps.setInt(3, vehicleId);
                    ps.setDouble(4, lateFee);
                    ps.executeUpdate();
                }
            }
            
            con.commit(); // Commit transaction
            
            // Set attributes for success page
            request.setAttribute("transaction_id", transactionId);
            request.setAttribute("booking_id", bookingId);
            request.setAttribute("vehicle_id", vehicleId);
            request.setAttribute("vehicle_name", vehicleName);
            request.setAttribute("final_amount", finalAmount);
            request.setAttribute("payment_method", paymentMethod);
            request.setAttribute("hours_used", hoursUsed);
            
            request.getRequestDispatcher("/user/payment_success.jsp").forward(request, response);
            
        } catch (Exception e) {
            try {
                if (con != null) con.rollback(); // Rollback on error
            } catch (Exception rollbackEx) {
                rollbackEx.printStackTrace();
            }
            throw new ServletException(e);
        } finally {
            try {
                if (con != null) {
                    con.setAutoCommit(true);
                    con.close();
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.sendRedirect(request.getContextPath() + "/user/my_trips");
    }
}
