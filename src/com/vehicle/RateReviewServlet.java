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

@WebServlet("/user/rate_review")
public class RateReviewServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        int bookingId = Integer.parseInt(request.getParameter("booking_id"));
        int rating = Integer.parseInt(request.getParameter("rating"));
        String review = request.getParameter("review");

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user_id") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        int userId = (int) session.getAttribute("user_id");

        DbConnection db = new DbConnection();
        Connection con = null;
        try {
            con = db.makeConnection();
            con.setAutoCommit(false);

            // Get vehicle_id and owner_id from booking
            int vehicleId = 0;
            int ownerId = 0;
            String fetchSql = "SELECT b.vehicle_id, v.owner_id FROM booking b JOIN vehicle v ON b.vehicle_id = v.vehicle_id WHERE b.booking_id = ? AND b.user_id = ?";
            try (PreparedStatement ps = con.prepareStatement(fetchSql)) {
                ps.setInt(1, bookingId);
                ps.setInt(2, userId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        vehicleId = rs.getInt("vehicle_id");
                        ownerId = rs.getInt("owner_id");
                    }
                }
            }

            // Insert into ratings table so admin/owner pages can see it
            String insertSql = "INSERT INTO ratings (booking_id, user_id, vehicle_id, owner_id, rating, review) VALUES (?, ?, ?, ?, ?, ?)";
            try (PreparedStatement ps = con.prepareStatement(insertSql)) {
                ps.setInt(1, bookingId);
                ps.setInt(2, userId);
                ps.setInt(3, vehicleId);
                ps.setInt(4, ownerId);
                ps.setInt(5, rating);
                ps.setString(6, review);
                ps.executeUpdate();
            }

            // Also persist rating/review on booking for user view
            String updateBooking = "UPDATE booking SET rating = ?, review = ? WHERE booking_id = ?";
            try (PreparedStatement ps = con.prepareStatement(updateBooking)) {
                ps.setInt(1, rating);
                ps.setString(2, review);
                ps.setInt(3, bookingId);
                ps.executeUpdate();
            }

            con.commit();
        } catch (Exception e) {
            try {
                if (con != null) con.rollback();
            } catch (Exception ignore) {}
            throw new ServletException(e);
        } finally {
            try {
                if (con != null) {
                    con.setAutoCommit(true);
                    con.close();
                }
            } catch (Exception ignore) {}
        }

        response.sendRedirect(request.getContextPath() + "/user/my_trips");
    }
}
