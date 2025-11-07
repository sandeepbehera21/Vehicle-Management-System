package com.vehicle;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/user/my_trips")
public class MyTripsServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user_id") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        int userId = (int) session.getAttribute("user_id");

        List<Booking> upcomingTrips = new ArrayList<>();
        List<Booking> pastTrips = new ArrayList<>();
        DbConnection db = new DbConnection();

        try {
            Connection con = db.makeConnection();
            String sql = "SELECT b.booking_id, b.vehicle_id, b.start_date, b.end_date, b.total_amount, b.status, v.vehicle_name, o.name AS owner_name, o.phone AS owner_phone, b.rating, b.review, b.route, b.duration " +
                         "FROM booking b " +
                         "JOIN vehicle v ON b.vehicle_id = v.vehicle_id " +
                         "JOIN owner o ON v.owner_id = o.owner_id " +
                         "WHERE b.user_id = ? ORDER BY b.start_date DESC";

            try (PreparedStatement ps = con.prepareStatement(sql)) {
                ps.setInt(1, userId);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        Booking trip = new Booking();
                        trip.setBooking_id(rs.getInt("booking_id"));
                        trip.setVehicle_id(rs.getInt("vehicle_id"));
                        trip.setStart_date(rs.getDate("start_date").toLocalDate());
                        trip.setEnd_date(rs.getDate("end_date").toLocalDate());
                        trip.setTotal_amount(rs.getDouble("total_amount"));
                        trip.setStatus(rs.getString("status"));
                        trip.setVehicle_name(rs.getString("vehicle_name"));
                        trip.setOwner_name(rs.getString("owner_name"));
                        trip.setOwner_phone(rs.getString("owner_phone"));
                        trip.setRating(rs.getInt("rating"));
                        trip.setReview(rs.getString("review"));
                        trip.setRoute(rs.getString("route"));
                        trip.setDuration(rs.getString("duration"));

                        if (trip.getStatus().equals("Completed") || trip.getStatus().equals("Returned")) {
                            pastTrips.add(trip);
                        } else {
                            upcomingTrips.add(trip);
                        }
                    }
                }
            }
            con.close();
        } catch (Exception e) {
            throw new ServletException(e);
        }

        request.setAttribute("upcomingTrips", upcomingTrips);
        request.setAttribute("pastTrips", pastTrips);
        request.getRequestDispatcher("/user/my_trips.jsp").forward(request, response);
    }
}
