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

@WebServlet("/admin/owners")
public class AdminOwnersServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    public static class OwnerData {
        public int ownerId;
        public String name;
        public String email;
        public String phone;
        public String address;
        public boolean approved;
        public String createdAt;
        public int totalVehicles;
        public double totalEarnings;
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("admin_id") == null) {
            response.sendRedirect(request.getContextPath() + "/admin/login");
            return;
        }

        List<OwnerData> owners = new ArrayList<>();
        try {
            DbConnection db = new DbConnection();
            Connection con = db.makeConnection();
            
            String sql = "SELECT o.owner_id, o.name, o.email, o.phone, o.address, o.approved, " +
                        "o.created_at, COUNT(v.vehicle_id) as total_vehicles, " +
                        "COALESCE(SUM(CASE WHEN b.status = 'completed' THEN b.total_amount * 0.1 ELSE 0 END), 0) as total_earnings " +
                        "FROM owner o " +
                        "LEFT JOIN vehicle v ON o.owner_id = v.owner_id " +
                        "LEFT JOIN booking b ON v.vehicle_id = b.vehicle_id " +
                        "GROUP BY o.owner_id, o.name, o.email, o.phone, o.address, o.approved, o.created_at " +
                        "ORDER BY o.created_at DESC";
            
            try (PreparedStatement ps = con.prepareStatement(sql);
                 ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    OwnerData o = new OwnerData();
                    o.ownerId = rs.getInt("owner_id");
                    o.name = rs.getString("name");
                    o.email = rs.getString("email");
                    o.phone = rs.getString("phone");
                    o.address = rs.getString("address");
                    o.approved = rs.getBoolean("approved");
                    o.createdAt = rs.getString("created_at");
                    o.totalVehicles = rs.getInt("total_vehicles");
                    o.totalEarnings = rs.getDouble("total_earnings");
                    owners.add(o);
                }
            }
        } catch (Exception e) {
            throw new ServletException(e);
        }

        request.setAttribute("owners", owners);
        request.getRequestDispatcher("/admin/owners.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("admin_id") == null) {
            response.sendRedirect(request.getContextPath() + "/admin/login");
            return;
        }

        String action = request.getParameter("action");
        int ownerId = Integer.parseInt(request.getParameter("owner_id"));

        try {
            DbConnection db = new DbConnection();
            Connection con = db.makeConnection();

            if ("approve".equals(action)) {
                String sql = "UPDATE owner SET approved = true WHERE owner_id = ?";
                try (PreparedStatement ps = con.prepareStatement(sql)) {
                    ps.setInt(1, ownerId);
                    ps.executeUpdate();
                }
            } else if ("disapprove".equals(action)) {
                String sql = "UPDATE owner SET approved = false WHERE owner_id = ?";
                try (PreparedStatement ps = con.prepareStatement(sql)) {
                    ps.setInt(1, ownerId);
                    ps.executeUpdate();
                }
            } else if ("delete".equals(action)) {
                // First delete associated vehicles
                String deleteVehiclesSql = "DELETE FROM vehicle WHERE owner_id = ?";
                try (PreparedStatement ps = con.prepareStatement(deleteVehiclesSql)) {
                    ps.setInt(1, ownerId);
                    ps.executeUpdate();
                }
                
                // Then delete the owner
                String deleteOwnerSql = "DELETE FROM owner WHERE owner_id = ?";
                try (PreparedStatement ps = con.prepareStatement(deleteOwnerSql)) {
                    ps.setInt(1, ownerId);
                    ps.executeUpdate();
                }
            }
        } catch (Exception e) {
            throw new ServletException(e);
        }

        response.sendRedirect(request.getContextPath() + "/admin/owners");
    }
}
