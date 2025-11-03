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

@WebServlet("/admin/maintenance")
public class AdminMaintenanceServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    public static class MaintenanceData {
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

        List<MaintenanceData> maintenanceList = new ArrayList<>();
        List<VehicleData> availableVehicles = new ArrayList<>();

        try {
            DbConnection db = new DbConnection();
            Connection con = db.makeConnection();

            // Check if maintenance table exists first
            if (tableExists(con, "maintenance")) {
                // Get all maintenance records
                String maintenanceSql = "SELECT m.maintenance_id, m.vehicle_id, m.maintenance_date, " +
                        "m.completed_date, m.maintenance_type, m.description, " +
                        "m.cost, m.status, m.created_at, " +
                        "v.vehicle_name, v.vehicle_number " +
                        "FROM maintenance m " +
                        "JOIN vehicle v ON m.vehicle_id = v.vehicle_id " +
                        "ORDER BY m.maintenance_date DESC, m.status ASC";

                try (PreparedStatement ps = con.prepareStatement(maintenanceSql);
                        ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        MaintenanceData m = new MaintenanceData();
                        m.maintenanceId = rs.getInt("maintenance_id");
                        m.vehicleId = rs.getInt("vehicle_id");
                        m.vehicleName = rs.getString("vehicle_name");
                        m.vehicleNumber = rs.getString("vehicle_number");
                        m.maintenanceDate = rs.getString("maintenance_date");
                        m.completedDate = rs.getString("completed_date");
                        m.maintenanceType = rs.getString("maintenance_type");
                        m.description = rs.getString("description");
                        m.cost = rs.getDouble("cost");
                        m.status = rs.getString("status");
                        m.createdAt = rs.getString("created_at");
                        maintenanceList.add(m);
                    }
                }
            } else {
                // Create maintenance table if it doesn't exist
                createMaintenanceTable(con);
            }

            // Get available vehicles for maintenance scheduling
            String vehiclesSql = "SELECT vehicle_id, vehicle_name, vehicle_number, vehicle_type " +
                    "FROM vehicle WHERE availability = 1 AND status = 'Approved' " +
                    "ORDER BY vehicle_name";

            try (PreparedStatement ps = con.prepareStatement(vehiclesSql);
                    ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    VehicleData v = new VehicleData();
                    v.vehicleId = rs.getInt("vehicle_id");
                    v.vehicleName = rs.getString("vehicle_name");
                    v.vehicleNumber = rs.getString("vehicle_number");
                    v.vehicleType = rs.getString("vehicle_type");
                    availableVehicles.add(v);
                }
            }

            con.close();
        } catch (Exception e) {
            e.printStackTrace();
            // Continue with empty lists if there's an error
        }

        request.setAttribute("maintenanceList", maintenanceList);
        request.setAttribute("availableVehicles", availableVehicles);
        request.getRequestDispatcher("/admin/maintenance.jsp").forward(request, response);
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

        try {
            DbConnection db = new DbConnection();
            Connection con = db.makeConnection();

            // Ensure maintenance table exists
            if (!tableExists(con, "maintenance")) {
                createMaintenanceTable(con);
            }

            if ("add".equals(action)) {
                // Add new maintenance record
                int vehicleId = Integer.parseInt(request.getParameter("vehicle_id"));
                String maintenanceDate = request.getParameter("maintenance_date");
                String maintenanceType = request.getParameter("maintenance_type");
                String description = request.getParameter("description");
                double cost = request.getParameter("cost") != null && !request.getParameter("cost").isEmpty()
                        ? Double.parseDouble(request.getParameter("cost"))
                        : 0.0;

                String sql = "INSERT INTO maintenance (vehicle_id, maintenance_date, maintenance_type, description, cost, status) "
                        +
                        "VALUES (?, ?, ?, ?, ?, 'Scheduled')";
                try (PreparedStatement ps = con.prepareStatement(sql)) {
                    ps.setInt(1, vehicleId);
                    ps.setString(2, maintenanceDate);
                    ps.setString(3, maintenanceType);
                    ps.setString(4, description);
                    ps.setDouble(5, cost);
                    ps.executeUpdate();
                }

            } else if ("update_status".equals(action)) {
                // Update maintenance status
                int maintenanceId = Integer.parseInt(request.getParameter("maintenance_id"));
                String newStatus = request.getParameter("new_status");

                String sql = "UPDATE maintenance SET status = ?";
                if ("Completed".equals(newStatus)) {
                    sql += ", completed_date = CURDATE()";
                }
                sql += " WHERE maintenance_id = ?";

                try (PreparedStatement ps = con.prepareStatement(sql)) {
                    ps.setString(1, newStatus);
                    ps.setInt(2, maintenanceId);
                    ps.executeUpdate();
                }

            } else if ("delete".equals(action)) {
                // Delete maintenance record
                int maintenanceId = Integer.parseInt(request.getParameter("maintenance_id"));
                String sql = "DELETE FROM maintenance WHERE maintenance_id = ?";
                try (PreparedStatement ps = con.prepareStatement(sql)) {
                    ps.setInt(1, maintenanceId);
                    ps.executeUpdate();
                }
            }

            con.close();
        } catch (Exception e) {
            e.printStackTrace();
            throw new ServletException(e);
        }

        response.sendRedirect(request.getContextPath() + "/admin/maintenance?success=1");
    }

    // Check if table exists
    private boolean tableExists(Connection con, String tableName) {
        try {
            String sql = "SELECT 1 FROM " + tableName + " LIMIT 1";
            try (PreparedStatement ps = con.prepareStatement(sql)) {
                ps.executeQuery();
                return true;
            }
        } catch (Exception e) {
            return false;
        }
    }

    // Create maintenance table if it doesn't exist
    private void createMaintenanceTable(Connection con) {
        try {
            String createTableSQL = "CREATE TABLE IF NOT EXISTS maintenance (" +
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
            try (PreparedStatement ps = con.prepareStatement(createTableSQL)) {
                ps.executeUpdate();
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    // Inner class for vehicle data in maintenance servlet
    public static class VehicleData {
        public int vehicleId;
        public String vehicleName;
        public String vehicleNumber;
        public String vehicleType;
    }
}
