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

@WebServlet("/user/submit_rating")
public class SubmitRatingServlet extends HttpServlet {
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
        int rating = Integer.parseInt(request.getParameter("rating"));
        String review = request.getParameter("review");

        if (review == null || review.trim().isEmpty()) {
            review = null;
        }

        DbConnection db = new DbConnection();
        Connection con = null;
        
        try {
            con = db.makeConnection();
            con.setAutoCommit(false);
            
            // Get owner_id for the rating
            String getOwnerSql = "SELECT v.owner_id FROM vehicle v WHERE v.vehicle_id = ?";
            int ownerId = 0;
            
            try (PreparedStatement ps = con.prepareStatement(getOwnerSql)) {
                ps.setInt(1, vehicleId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        ownerId = rs.getInt("owner_id");
                    }
                }
            }
            
            // Insert into ratings table
            String insertRatingSql = "INSERT INTO ratings (booking_id, user_id, vehicle_id, owner_id, rating, review) " +
                                    "VALUES (?, ?, ?, ?, ?, ?)";
            
            try (PreparedStatement ps = con.prepareStatement(insertRatingSql)) {
                ps.setInt(1, bookingId);
                ps.setInt(2, userId);
                ps.setInt(3, vehicleId);
                ps.setInt(4, ownerId);
                ps.setInt(5, rating);
                ps.setString(6, review);
                ps.executeUpdate();
            }
            
            // Update booking table with rating and review
            String updateBookingSql = "UPDATE booking SET rating = ?, review = ? WHERE booking_id = ?";
            
            try (PreparedStatement ps = con.prepareStatement(updateBookingSql)) {
                ps.setInt(1, rating);
                ps.setString(2, review);
                ps.setInt(3, bookingId);
                ps.executeUpdate();
            }
            
            con.commit();
            
            // Redirect to My Trips with success message
            response.sendRedirect(request.getContextPath() + "/user/my_trips?rating_success=true");
            
        } catch (Exception e) {
            try {
                if (con != null) con.rollback();
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
