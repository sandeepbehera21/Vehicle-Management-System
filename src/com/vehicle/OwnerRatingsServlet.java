package com.vehicle;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/owner/ratings")
public class OwnerRatingsServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("owner_id") == null) {
            response.sendRedirect(request.getContextPath() + "/owner/login");
            return;
        }

        int ownerId = (int) session.getAttribute("owner_id");
        List<Map<String, Object>> ratings = new ArrayList<>();
        Map<String, Object> statistics = new HashMap<>();
        
        DbConnection db = new DbConnection();
        try {
            Connection con = db.makeConnection();
            
            // Get ratings for owner's vehicles
            String ratingsSql = "SELECT r.rating_id, r.rating, r.review, r.rating_date, " +
                               "u.name AS user_name, u.email AS user_email, " +
                               "v.vehicle_name, v.vehicle_model, v.vehicle_type, " +
                               "b.booking_id " +
                               "FROM ratings r " +
                               "JOIN users u ON r.user_id = u.user_id " +
                               "JOIN vehicle v ON r.vehicle_id = v.vehicle_id " +
                               "JOIN booking b ON r.booking_id = b.booking_id " +
                               "WHERE r.owner_id = ? " +
                               "ORDER BY r.rating_date DESC";

            try (PreparedStatement ps = con.prepareStatement(ratingsSql)) {
                ps.setInt(1, ownerId);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        Map<String, Object> rating = new HashMap<>();
                        rating.put("rating_id", rs.getInt("rating_id"));
                        rating.put("rating", rs.getInt("rating"));
                        rating.put("review", rs.getString("review"));
                        rating.put("rating_date", rs.getTimestamp("rating_date"));
                        rating.put("user_name", rs.getString("user_name"));
                        rating.put("user_email", rs.getString("user_email"));
                        rating.put("vehicle_name", rs.getString("vehicle_name"));
                        rating.put("vehicle_model", rs.getString("vehicle_model"));
                        rating.put("vehicle_type", rs.getString("vehicle_type"));
                        rating.put("booking_id", rs.getInt("booking_id"));
                        ratings.add(rating);
                    }
                }
            }
            
            // Get rating statistics for owner
            String statsSql = "SELECT " +
                             "COUNT(*) as total_ratings, " +
                             "AVG(rating) as average_rating, " +
                             "SUM(CASE WHEN rating = 5 THEN 1 ELSE 0 END) as five_star, " +
                             "SUM(CASE WHEN rating = 4 THEN 1 ELSE 0 END) as four_star, " +
                             "SUM(CASE WHEN rating = 3 THEN 1 ELSE 0 END) as three_star, " +
                             "SUM(CASE WHEN rating = 2 THEN 1 ELSE 0 END) as two_star, " +
                             "SUM(CASE WHEN rating = 1 THEN 1 ELSE 0 END) as one_star " +
                             "FROM ratings WHERE owner_id = ?";

            try (PreparedStatement ps = con.prepareStatement(statsSql)) {
                ps.setInt(1, ownerId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        statistics.put("total_ratings", rs.getInt("total_ratings"));
                        statistics.put("average_rating", rs.getDouble("average_rating"));
                        statistics.put("five_star", rs.getInt("five_star"));
                        statistics.put("four_star", rs.getInt("four_star"));
                        statistics.put("three_star", rs.getInt("three_star"));
                        statistics.put("two_star", rs.getInt("two_star"));
                        statistics.put("one_star", rs.getInt("one_star"));
                    }
                }
            }
            
            // Get vehicle-wise ratings
            String vehicleRatingsSql = "SELECT v.vehicle_name, v.vehicle_model, " +
                                      "COUNT(r.rating_id) as rating_count, " +
                                      "AVG(r.rating) as avg_rating " +
                                      "FROM vehicle v " +
                                      "LEFT JOIN ratings r ON v.vehicle_id = r.vehicle_id " +
                                      "WHERE v.owner_id = ? " +
                                      "GROUP BY v.vehicle_id, v.vehicle_name, v.vehicle_model " +
                                      "ORDER BY avg_rating DESC";
            
            List<Map<String, Object>> vehicleRatings = new ArrayList<>();
            try (PreparedStatement ps = con.prepareStatement(vehicleRatingsSql)) {
                ps.setInt(1, ownerId);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        Map<String, Object> vehicleRating = new HashMap<>();
                        vehicleRating.put("vehicle_name", rs.getString("vehicle_name"));
                        vehicleRating.put("vehicle_model", rs.getString("vehicle_model"));
                        vehicleRating.put("rating_count", rs.getInt("rating_count"));
                        vehicleRating.put("avg_rating", rs.getDouble("avg_rating"));
                        vehicleRatings.add(vehicleRating);
                    }
                }
            }
            
            con.close();
            
            request.setAttribute("vehicleRatings", vehicleRatings);
        } catch (Exception e) {
            throw new ServletException(e);
        }

        request.setAttribute("ratings", ratings);
        request.setAttribute("statistics", statistics);
        request.getRequestDispatcher("/owner/ratings.jsp").forward(request, response);
    }
}
