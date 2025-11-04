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

@WebServlet("/owner/revenue")
public class OwnerRevenueServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    public static class RevenueRow {
        public int bookingId;
        public int vehicleId;
        public String vehicleName;
        public String startDate;
        public String endDate;
        public double totalAmount;
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("owner_id") == null) {
            response.sendRedirect(request.getContextPath() + "/owner/login");
            return;
        }
        int ownerId = (Integer) session.getAttribute("owner_id");

        String from = request.getParameter("from"); // yyyy-MM-dd
        String to = request.getParameter("to");     // yyyy-MM-dd

        String whereDates = "";
        if (from != null && !from.isEmpty()) {
            whereDates += " AND r.revenue_date >= ?";
        }
        if (to != null && !to.isEmpty()) {
            whereDates += " AND r.revenue_date <= ?";
        }

        double total = 0.0;
        List<RevenueRow> rows = new ArrayList<>();
        try {
            DbConnection db = new DbConnection();
            Connection con = db.makeConnection();

            String base = " FROM revenue r " +
                          "JOIN booking b ON r.booking_id = b.booking_id " +
                          "JOIN vehicle v ON r.vehicle_id = v.vehicle_id " +
                          "WHERE r.owner_id = ?" + whereDates;

            String sqlList = "SELECT r.booking_id, r.vehicle_id, v.vehicle_name, b.start_date, b.end_date, COALESCE(SUM(r.amount),0) AS total_amount "
                           + base + " GROUP BY r.booking_id, r.vehicle_id, v.vehicle_name, b.start_date, b.end_date ORDER BY b.start_date DESC";
            try (PreparedStatement ps = con.prepareStatement(sqlList)) {
                int idx = 1;
                ps.setInt(idx++, ownerId);
                if (from != null && !from.isEmpty()) ps.setString(idx++, from);
                if (to != null && !to.isEmpty()) ps.setString(idx++, to);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        RevenueRow r = new RevenueRow();
                        r.bookingId = rs.getInt("booking_id");
                        r.vehicleId = rs.getInt("vehicle_id");
                        r.vehicleName = rs.getString("vehicle_name");
                        r.startDate = String.valueOf(rs.getDate("start_date"));
                        r.endDate = String.valueOf(rs.getDate("end_date"));
                        r.totalAmount = rs.getDouble("total_amount");
                        rows.add(r);
                    }
                }
            }

            String sqlSum = "SELECT COALESCE(SUM(r.amount),0)" + base;
            try (PreparedStatement ps = con.prepareStatement(sqlSum)) {
                int idx = 1;
                ps.setInt(idx++, ownerId);
                if (from != null && !from.isEmpty()) ps.setString(idx++, from);
                if (to != null && !to.isEmpty()) ps.setString(idx++, to);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) total = rs.getDouble(1);
                }
            }
        } catch (Exception e) {
            throw new ServletException(e);
        }

        request.setAttribute("rows", rows);
        request.setAttribute("total", total);
        request.setAttribute("from", from);
        request.setAttribute("to", to);
        request.getRequestDispatcher("/owner/revenue.jsp").forward(request, response);
    }
}
