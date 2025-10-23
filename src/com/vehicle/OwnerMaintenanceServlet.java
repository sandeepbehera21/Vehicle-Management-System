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

@WebServlet("/owner/maintenance")
public class OwnerMaintenanceServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    public static class VehicleRow {
        public int vehicleId;
        public String vehicleName;
        public String vehicleNumber;
        public String vehicleType;
        public boolean available;
    }

    public static class MaintenanceRow {
        public int maintenanceId;
        public int vehicleId;
        public String vehicleName;
        public String vehicleNumber;
        public String maintenanceDate;
        public String completedDate;
        public String maintenanceType;
        public String description;
        public double cost;
        public String status;
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
        List<MaintenanceRow> maints = new ArrayList<>();

        try {
            DbConnection db = new DbConnection();
            Connection con = db.makeConnection();

            // Ensure maintenance table exists
            ensureMaintenanceTable(con);

            // Owner vehicles
            String vsql = "SELECT vehicle_id, vehicle_name, vehicle_number, vehicle_type, availability FROM vehicle WHERE owner_id = ? ORDER BY vehicle_name";
            try (PreparedStatement ps = con.prepareStatement(vsql)) {
                ps.setInt(1, ownerId);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        VehicleRow v = new VehicleRow();
                        v.vehicleId = rs.getInt("vehicle_id");
                        v.vehicleName = rs.getString("vehicle_name");
                        v.vehicleNumber = rs.getString("vehicle_number");
                        v.vehicleType = rs.getString("vehicle_type");
                        v.available = rs.getBoolean("availability");
                        vehicles.add(v);
                    }
                }
            }

            // Owner maintenance list
            String msql = "SELECT m.maintenance_id, m.vehicle_id, v.vehicle_name, v.vehicle_number, m.maintenance_date, m.completed_date, m.maintenance_type, m.description, m.cost, m.status " +
                          "FROM maintenance m JOIN vehicle v ON m.vehicle_id = v.vehicle_id WHERE v.owner_id = ? ORDER BY m.maintenance_date DESC, m.status ASC";
            try (PreparedStatement ps = con.prepareStatement(msql)) {
                ps.setInt(1, ownerId);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        MaintenanceRow m = new MaintenanceRow();
                        m.maintenanceId = rs.getInt("maintenance_id");
                        m.vehicleId = rs.getInt("vehicle_id");
                        m.vehicleName = rs.getString("vehicle_name");
                        m.vehicleNumber = rs.getString("vehicle_number");
                        m.maintenanceDate = String.valueOf(rs.getDate("maintenance_date"));
                        m.completedDate = rs.getString("completed_date");
                        m.maintenanceType = rs.getString("maintenance_type");
                        m.description = rs.getString("description");
                        m.cost = rs.getDouble("cost");
                        m.status = rs.getString("status");
                        maints.add(m);
                    }
                }
            }

            con.close();
        } catch (Exception e) {
            throw new ServletException(e);
        }

        request.setAttribute("vehicles", vehicles);
        request.setAttribute("maintenance", maints);
        request.getRequestDispatcher("/owner/maintenance.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("owner_id") == null) {
            response.sendRedirect(request.getContextPath() + "/owner/login");
            return;
        }

        String action = request.getParameter("action");

        try {
            DbConnection db = new DbConnection();
            Connection con = db.makeConnection();
            ensureMaintenanceTable(con);

            if ("schedule".equals(action)) {
                int vehicleId = Integer.parseInt(request.getParameter("vehicle_id"));
                String maintenanceDate = request.getParameter("maintenance_date"); // yyyy-MM-dd
                String maintenanceType = request.getParameter("maintenance_type");
                String description = request.getParameter("description");
                double cost = request.getParameter("cost") != null && !request.getParameter("cost").isEmpty() ? Double.parseDouble(request.getParameter("cost")) : 0.0;

                // Insert maintenance
                String ins = "INSERT INTO maintenance (vehicle_id, maintenance_date, maintenance_type, description, cost, status) VALUES (?, ?, ?, ?, ?, 'Scheduled')";
                try (PreparedStatement ps = con.prepareStatement(ins)) {
                    ps.setInt(1, vehicleId);
                    ps.setString(2, maintenanceDate);
                    ps.setString(3, maintenanceType);
                    ps.setString(4, description);
                    ps.setDouble(5, cost);
                    ps.executeUpdate();
                }

                // Make vehicle unavailable
                try (PreparedStatement ps = con.prepareStatement("UPDATE vehicle SET availability = 0 WHERE vehicle_id = ?")) {
                    ps.setInt(1, vehicleId);
                    ps.executeUpdate();
                }

            } else if ("complete".equals(action)) {
                int maintenanceId = Integer.parseInt(request.getParameter("maintenance_id"));
                int vehicleId = Integer.parseInt(request.getParameter("vehicle_id"));

                String upd = "UPDATE maintenance SET status='Completed', completed_date = CURDATE() WHERE maintenance_id = ?";
                try (PreparedStatement ps = con.prepareStatement(upd)) {
                    ps.setInt(1, maintenanceId);
                    ps.executeUpdate();
                }

                // Make vehicle available back
                try (PreparedStatement ps = con.prepareStatement("UPDATE vehicle SET availability = 1 WHERE vehicle_id = ?")) {
                    ps.setInt(1, vehicleId);
                    ps.executeUpdate();
                }
            }

            con.close();
        } catch (Exception e) {
            throw new ServletException(e);
        }

        response.sendRedirect(request.getContextPath() + "/owner/maintenance?success=1");
    }

    private void ensureMaintenanceTable(Connection con) {
        try {
            String sql = "CREATE TABLE IF NOT EXISTS maintenance (" +
                    "maintenance_id INT PRIMARY KEY AUTO_INCREMENT, " +
                    "vehicle_id INT NOT NULL, " +
                    "maintenance_date DATE, " +
                    "completed_date DATE, " +
                    "maintenance_type ENUM('Routine','Repair','Inspection') DEFAULT 'Routine', " +
                    "description TEXT, " +
                    "cost DECIMAL(10,2) DEFAULT 0.00, " +
                    "status ENUM('Scheduled','In Progress','Completed') DEFAULT 'Scheduled', " +
                    "created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, " +
                    "FOREIGN KEY (vehicle_id) REFERENCES vehicle(vehicle_id) ON DELETE CASCADE" +
                    ")";
            try (PreparedStatement ps = con.prepareStatement(sql)) {
                ps.executeUpdate();
            }
        } catch (Exception ignore) {
        }
    }
}
