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

@WebServlet("/owner/vehicles")
public class OwnerVehiclesServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    public static class VehicleRow {
        public int vehicleId;
        public String vehicleName;
        public String vehicleModel;
        public String vehicleType;
        public String vehicleNumber;
        public double rentPerDay;
        public boolean availability;
        public String status; // Available | On Trip | Maintenance
        public String approvalStatus; // pending | approved | rejected
        public String imageUrl;
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("owner_id") == null) {
            response.sendRedirect(request.getContextPath() + "/owner/login");
            return;
        }
        int ownerId = (Integer) session.getAttribute("owner_id");

        List<VehicleRow> vehicles = new ArrayList<>();
        try {
            DbConnection db = new DbConnection();
            Connection con = db.makeConnection();

            // Simple query - database already has the columns
            String sql = "SELECT vehicle_id, vehicle_name, COALESCE(vehicle_model,'') AS vehicle_model, vehicle_type, vehicle_number, rent_per_day, availability, COALESCE(status,'Available') AS status, COALESCE(approval_status,'pending') AS approval_status, image_url FROM vehicle WHERE owner_id = ? ORDER BY created_at DESC";

            try (PreparedStatement ps = con.prepareStatement(sql)) {
                ps.setInt(1, ownerId);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        VehicleRow v = new VehicleRow();
                        v.vehicleId = rs.getInt("vehicle_id");
                        v.vehicleName = rs.getString("vehicle_name");
                        v.vehicleModel = rs.getString("vehicle_model");
                        v.vehicleType = rs.getString("vehicle_type");
                        v.vehicleNumber = rs.getString("vehicle_number");
                        v.rentPerDay = rs.getDouble("rent_per_day");
                        v.availability = rs.getBoolean("availability");
                        v.status = rs.getString("status");
                        v.approvalStatus = rs.getString("approval_status");
                        v.imageUrl = rs.getString("image_url");
                        vehicles.add(v);
                    }
                }
            }
        } catch (Exception e) {
            throw new ServletException(e);
        }

        request.setAttribute("vehicles", vehicles);
        request.getRequestDispatcher("/owner/vehicles.jsp").forward(request, response);
    }
}
