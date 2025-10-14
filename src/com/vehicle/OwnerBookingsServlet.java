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

    public static class BookingRow {
        public int bookingId;
        public int vehicleId;
        public String vehicleName;
        public String vehicleType;
        public String imageUrl;
        public String startDate;
        public String endDate;
        public double totalAmount;
        public String status;
        public int userId;
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("owner_id") == null) {
            response.sendRedirect(request.getContextPath() + "/owner/login");
            return;
        }
        int ownerId = (Integer) session.getAttribute("owner_id");

        List<BookingRow> rows = new ArrayList<>();
        try {
            DbConnection db = new DbConnection();
            Connection con = db.makeConnection();
            String sql = "SELECT b.booking_id, b.user_id, b.vehicle_id, b.start_date, b.end_date, b.total_amount, b.status, " +
                         "v.vehicle_name, v.vehicle_type, v.image_url " +
                         "FROM booking b JOIN vehicle v ON b.vehicle_id = v.vehicle_id " +
                         "WHERE v.owner_id = ? ORDER BY b.created_at DESC";
            try (PreparedStatement ps = con.prepareStatement(sql)) {
                ps.setInt(1, ownerId);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        BookingRow br = new BookingRow();
                        br.bookingId = rs.getInt("booking_id");
                        br.userId = rs.getInt("user_id");
                        br.vehicleId = rs.getInt("vehicle_id");
                        br.startDate = String.valueOf(rs.getDate("start_date"));
                        br.endDate = String.valueOf(rs.getDate("end_date"));
                        br.totalAmount = rs.getDouble("total_amount");
                        br.status = rs.getString("status");
                        br.vehicleName = rs.getString("vehicle_name");
                        br.vehicleType = rs.getString("vehicle_type");
                        br.imageUrl = rs.getString("image_url");
                        rows.add(br);
                    }
                }
            }
        } catch (Exception e) {
            throw new ServletException(e);
        }

        request.setAttribute("bookings", rows);
        request.getRequestDispatcher("/owner/bookings.jsp").forward(request, response);
    }
}
