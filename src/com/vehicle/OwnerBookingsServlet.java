package com.vehicle;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/owner/bookings")
public class OwnerBookingsServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("owner_id") == null) {
            response.sendRedirect(request.getContextPath() + "/owner/login");
            return;
        }
        int ownerId = (int) session.getAttribute("owner_id");

        List<Booking> bookingList = new ArrayList<>();
        DbConnection db = new DbConnection();

        try {
            Connection con = db.makeConnection();
            String sql = "SELECT b.booking_id, b.start_date, b.end_date, b.total_amount, b.status, v.vehicle_name, u.name AS user_name " +
                         "FROM booking b " +
                         "JOIN vehicle v ON b.vehicle_id = v.vehicle_id " +
                         "JOIN users u ON b.user_id = u.user_id " +
                         "WHERE v.owner_id = ? ORDER BY b.created_at DESC";

            try (PreparedStatement ps = con.prepareStatement(sql)) {
                ps.setInt(1, ownerId);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        Booking booking = new Booking();
                        booking.setBooking_id(rs.getInt("booking_id"));
                        booking.setStart_date(rs.getDate("start_date").toLocalDate());
                        booking.setEnd_date(rs.getDate("end_date").toLocalDate());
                        booking.setTotal_amount(rs.getDouble("total_amount"));
                        booking.setStatus(rs.getString("status"));
                        booking.setVehicle_name(rs.getString("vehicle_name"));
                        booking.setUser_name(rs.getString("user_name"));
                        bookingList.add(booking);
                    }
                }
            }
            con.close();
        } catch (Exception e) {
            throw new ServletException(e);
        }

        request.setAttribute("bookings", bookingList);
        request.getRequestDispatcher("/owner/bookings.jsp").forward(request, response);
    }
}
