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
        public String status;
        public String imageUrl;
        public String ownerName;
        public String ownerEmail;
        public int ownerId;
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("admin_id") == null) {
            response.sendRedirect(request.getContextPath() + "/admin/login");
            return;
        }

        List<VehicleData> vehicles = new ArrayList<>();
        try {
            DbConnection db = new DbConnection();
            Connection con = db.makeConnection();
            
            String sql = "SELECT v.vehicle_id, v.vehicle_name, COALESCE(v.vehicle_model,'') AS vehicle_model, " +
                        "v.vehicle_type, v.vehicle_number, v.rent_per_day, v.availability, " +
                        "COALESCE(v.status,'Available') AS status, v.image_url, " +
                        "o.name AS owner_name, o.email AS owner_email, o.owner_id " +
                        "FROM vehicle v " +
                        "LEFT JOIN owner o ON v.owner_id = o.owner_id " +
                        "ORDER BY v.created_at DESC";
            
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
                    v.status = rs.getString("status");
                    v.imageUrl = rs.getString("image_url");
                    v.ownerName = rs.getString("owner_name");
                    v.ownerEmail = rs.getString("owner_email");
                    v.ownerId = rs.getInt("owner_id");
                    vehicles.add(v);
                }
            }
        } catch (Exception e) {
            throw new ServletException(e);
        }

        request.setAttribute("vehicles", vehicles);
        request.getRequestDispatcher("/admin/vehicles.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("admin_id") == null) {
            response.sendRedirect(request.getContextPath() + "/admin/login");
            return;
        }

        String action = request.getParameter("action");
        int vehicleId = Integer.parseInt(request.getParameter("vehicle_id"));

        try {
            DbConnection db = new DbConnection();
            Connection con = db.makeConnection();

            if ("delete".equals(action)) {
                String sql = "DELETE FROM vehicle WHERE vehicle_id = ?";
                try (PreparedStatement ps = con.prepareStatement(sql)) {
                    ps.setInt(1, vehicleId);
                    ps.executeUpdate();
                }
            } else if ("toggle_status".equals(action)) {
                String newStatus = request.getParameter("new_status");
                String sql = "UPDATE vehicle SET status = ? WHERE vehicle_id = ?";
                try (PreparedStatement ps = con.prepareStatement(sql)) {
                    ps.setString(1, newStatus);
                    ps.setInt(2, vehicleId);
                    ps.executeUpdate();
                }
            }
        } catch (Exception e) {
            throw new ServletException(e);
        }

        response.sendRedirect(request.getContextPath() + "/admin/vehicles");
    }
}