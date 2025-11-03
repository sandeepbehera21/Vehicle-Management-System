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

@WebServlet("/admin/vehicles")
public class AdminVehiclesServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    public static class VehicleData {
        public int vehicleId;
        public String vehicleName;
        public String vehicleModel;
        public String vehicleType;
        public String vehicleNumber;
        public double rentPerDay;
        public boolean availability;
        public String vehicleStatus;
        public String approvalStatus;
        public String imageUrl;
        public String ownerName;
        public String ownerEmail;
        public int ownerId;
        public String createdAt;
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("admin_id") == null) {
            response.sendRedirect(request.getContextPath() + "/admin/login");
            return;
        }

        List<VehicleData> vehicles = new ArrayList<>();
        try {
            DbConnection db = new DbConnection();
            Connection con = db.makeConnection();

            // ✅ FIXED QUERY (matches your actual schema with approval_status)
            String sql = "SELECT v.vehicle_id, v.vehicle_name, v.vehicle_model, v.vehicle_type, v.vehicle_number, v.rent_per_day, v.availability, v.vehicle_status, v.approval_status, v.image_url, v.created_at, o.owner_id, o.name AS owner_name, o.email AS owner_email FROM vehicle v JOIN owner o ON v.owner_id = o.owner_id ORDER BY v.created_at DESC";

            System.out.println("DEBUG: Executing SQL: " + sql);

            try (PreparedStatement ps = con.prepareStatement(sql);
                    ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    VehicleData v = new VehicleData();
                    v.vehicleId = rs.getInt("vehicle_id");
                    v.vehicleName = rs.getString("vehicle_name");
                    v.vehicleModel = rs.getString("vehicle_model");
                    v.vehicleType = rs.getString("vehicle_type");
                    v.vehicleNumber = rs.getString("vehicle_number");
                    v.rentPerDay = rs.getDouble("rent_per_day");
                    v.availability = rs.getBoolean("availability");
                    v.vehicleStatus = rs.getString("vehicle_status");
                    v.approvalStatus = rs.getString("approval_status");
                    v.imageUrl = rs.getString("image_url");
                    v.createdAt = rs.getString("created_at");
                    v.ownerName = rs.getString("owner_name");
                    v.ownerEmail = rs.getString("owner_email");
                    v.ownerId = rs.getInt("owner_id");
                    vehicles.add(v);
                }
            }
            con.close();
        } catch (Exception e) {
            e.printStackTrace();
            throw new ServletException("Database error in AdminVehiclesServlet: " + e.getMessage(), e);
        }

        request.setAttribute("vehicles", vehicles);
        request.getRequestDispatcher("/admin/vehicle_management.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("admin_id") == null) {
            response.sendRedirect(request.getContextPath() + "/admin/login");
            return;
        }

        String action = request.getParameter("action");
        String vehicleIdParam = request.getParameter("vehicle_id");

        if (vehicleIdParam == null || vehicleIdParam.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/admin/vehicles?error=Invalid vehicle ID");
            return;
        }

        int vehicleId = Integer.parseInt(vehicleIdParam);

        try {
            DbConnection db = new DbConnection();
            Connection con = db.makeConnection();

            if ("delete".equals(action)) {
                String sql = "DELETE FROM vehicle WHERE vehicle_id = ?";
                try (PreparedStatement ps = con.prepareStatement(sql)) {
                    ps.setInt(1, vehicleId);
                    ps.executeUpdate();
                }
            } else if ("toggle_availability".equals(action)) {
                String currentStatus = getCurrentAvailability(con, vehicleId);
                String newStatus = "1".equals(currentStatus) ? "0" : "1";

                String sql = "UPDATE vehicle SET availability = ? WHERE vehicle_id = ?";
                try (PreparedStatement ps = con.prepareStatement(sql)) {
                    ps.setString(1, newStatus);
                    ps.setInt(2, vehicleId);
                    ps.executeUpdate();
                }
            } else if ("update_vehicle_status".equals(action)) {
                String newStatus = request.getParameter("new_vehicle_status");
                String sql = "UPDATE vehicle SET vehicle_status = ? WHERE vehicle_id = ?";
                try (PreparedStatement ps = con.prepareStatement(sql)) {
                    ps.setString(1, newStatus);
                    ps.setInt(2, vehicleId);
                    ps.executeUpdate();
                }
            } else if ("approve".equals(action)) {
                String sql = "UPDATE vehicle SET approval_status = 'Approved' WHERE vehicle_id = ?";
                try (PreparedStatement ps = con.prepareStatement(sql)) {
                    ps.setInt(1, vehicleId);
                    ps.executeUpdate();
                }
            } else if ("reject".equals(action)) {
                String sql = "UPDATE vehicle SET approval_status = 'Rejected' WHERE vehicle_id = ?";
                try (PreparedStatement ps = con.prepareStatement(sql)) {
                    ps.setInt(1, vehicleId);
                    ps.executeUpdate();
                }
            }

            con.close();
        } catch (Exception e) {
            e.printStackTrace();
            throw new ServletException(e);
        }

        response.sendRedirect(request.getContextPath() + "/admin/vehicles?success=1");
    }

    private String getCurrentAvailability(Connection con, int vehicleId) throws Exception {
        String sql = "SELECT availability FROM vehicle WHERE vehicle_id = ?";
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, vehicleId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getString("availability");
                }
            }
        }
        return "1";
    }
}
