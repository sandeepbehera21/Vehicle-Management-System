<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%@ page import="com.vehicle.AdminVehiclesServlet.VehicleData" %>
<%
    HttpSession userSession = request.getSession(false);
    if (userSession == null || userSession.getAttribute("admin_id") == null) {
        response.sendRedirect(request.getContextPath() + "/admin/login");
        return;
    }
    
    List<VehicleData> vehicles = (List<VehicleData>) request.getAttribute("vehicles");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Vehicle Management - Admin Panel</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
        }
        
        .container {
            max-width: 1400px;
            margin: 0 auto;
            padding: 20px;
        }
        
        .header {
            background: rgba(255, 255, 255, 0.95);
            backdrop-filter: blur(10px);
            border-radius: 20px;
            padding: 30px;
            margin-bottom: 30px;
            box-shadow: 0 8px 32px rgba(31, 38, 135, 0.37);
            border: 1px solid rgba(255, 255, 255, 0.18);
        }
        
        .header-content {
            display: flex;
            justify-content: space-between;
            align-items: center;
            flex-wrap: wrap;
            gap: 20px;
        }
        
        .header h1 {
            color: #333;
            font-size: 2.5em;
            font-weight: 700;
            display: flex;
            align-items: center;
            gap: 15px;
        }
        
        .nav-buttons {
            display: flex;
            gap: 15px;
            flex-wrap: wrap;
        }
        
        .btn {
            padding: 12px 24px;
            border: none;
            border-radius: 10px;
            text-decoration: none;
            font-weight: 600;
            transition: all 0.3s ease;
            cursor: pointer;
            display: inline-flex;
            align-items: center;
            gap: 8px;
        }
        
        .btn-primary {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
        }
        
        .btn-primary:hover {
            transform: translateY(-2px);
            box-shadow: 0 5px 15px rgba(102, 126, 234, 0.4);
        }
        
        .btn-secondary {
            background: rgba(255, 255, 255, 0.2);
            color: #333;
            border: 1px solid rgba(0, 0, 0, 0.1);
        }
        
        .btn-secondary:hover {
            background: rgba(255, 255, 255, 0.3);
            transform: translateY(-2px);
        }
        
        .content-card {
            background: rgba(255, 255, 255, 0.95);
            backdrop-filter: blur(10px);
            border-radius: 20px;
            padding: 40px;
            box-shadow: 0 8px 32px rgba(31, 38, 135, 0.37);
            border: 1px solid rgba(255, 255, 255, 0.18);
        }
        
        .vehicles-grid {
            display: grid;
            gap: 20px;
            grid-template-columns: repeat(auto-fill, minmax(400px, 1fr));
            margin-bottom: 30px;
        }
        
        .vehicle-card {
            background: linear-gradient(135deg, #f5f7fa 0%, #c3cfe2 100%);
            border-radius: 15px;
            padding: 20px;
            border: 2px solid transparent;
            transition: all 0.3s ease;
            position: relative;
            overflow: hidden;
        }
        
        .vehicle-card:hover {
            border-color: #667eea;
            transform: translateY(-5px);
            box-shadow: 0 10px 25px rgba(102, 126, 234, 0.3);
        }
        
        .vehicle-header {
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
            margin-bottom: 15px;
        }
        
        .vehicle-info h3 {
            color: #333;
            font-size: 1.4em;
            margin-bottom: 5px;
        }
        
        .vehicle-info p {
            color: #666;
            font-size: 0.9em;
            margin: 2px 0;
        }
        
        .status-badge {
            padding: 6px 12px;
            border-radius: 20px;
            font-size: 0.8em;
            font-weight: 600;
            text-transform: uppercase;
        }
        
        .status-available {
            background: #d4edda;
            color: #155724;
        }
        
        .status-rented {
            background: #fff3cd;
            color: #856404;
        }
        
        .status-maintenance {
            background: #f8d7da;
            color: #721c24;
        }
        
        .vehicle-details {
            margin: 15px 0;
        }
        
        .detail-row {
            display: flex;
            justify-content: space-between;
            margin: 8px 0;
            padding: 8px 0;
            border-bottom: 1px solid rgba(0,0,0,0.1);
        }
        
        .detail-label {
            font-weight: 600;
            color: #555;
        }
        
        .detail-value {
            color: #333;
        }
        
        .vehicle-image {
            width: 100%;
            height: 200px;
            object-fit: cover;
            border-radius: 10px;
            margin-bottom: 15px;
        }
        
        .owner-info {
            background: rgba(255, 255, 255, 0.7);
            padding: 10px;
            border-radius: 8px;
            margin-bottom: 15px;
        }
        
        .owner-info h4 {
            color: #333;
            margin-bottom: 5px;
        }
        
        .actions {
            display: flex;
            gap: 10px;
            flex-wrap: wrap;
            margin-top: 15px;
        }
        
        .btn-sm {
            padding: 8px 16px;
            font-size: 0.85em;
        }
        
        .btn-success {
            background: #28a745;
            color: white;
        }
        
        .btn-warning {
            background: #ffc107;
            color: #212529;
        }
        
        .btn-danger {
            background: #dc3545;
            color: white;
        }
        
        .btn-info {
            background: #17a2b8;
            color: white;
        }
        
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 20px;
            margin-bottom: 30px;
        }
        
        .stat-card {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 20px;
            border-radius: 15px;
            text-align: center;
        }
        
        .stat-number {
            font-size: 2em;
            font-weight: 700;
            margin-bottom: 5px;
        }
        
        .stat-label {
            font-size: 0.9em;
            opacity: 0.9;
        }
        
        .empty-state {
            text-align: center;
            padding: 60px 20px;
            color: #666;
        }
        
        .empty-state h3 {
            font-size: 1.5em;
            margin-bottom: 10px;
        }
        
        @media (max-width: 768px) {
            .vehicles-grid {
                grid-template-columns: 1fr;
            }
            
            .header-content {
                flex-direction: column;
                text-align: center;
            }
            
            .header h1 {
                font-size: 2em;
            }
        }
        
        .modal {
            display: none;
            position: fixed;
            z-index: 1000;
            left: 0;
            top: 0;
            width: 100%;
            height: 100%;
            background-color: rgba(0,0,0,0.5);
        }
        
        .modal-content {
            background-color: white;
            margin: 15% auto;
            padding: 20px;
            border-radius: 15px;
            width: 80%;
            max-width: 500px;
        }
        
        .close {
            color: #aaa;
            float: right;
            font-size: 28px;
            font-weight: bold;
            cursor: pointer;
        }
        
        .close:hover {
            color: black;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <div class="header-content">
                <h1>🚗 Vehicle Management</h1>
                <div class="nav-buttons">
                    <a href="<%= request.getContextPath() %>/admin/dashboard" class="btn btn-secondary">← Back to Dashboard</a>
                    <a href="<%= request.getContextPath() %>/admin/logout" class="btn btn-primary">Logout</a>
                </div>
            </div>
        </div>

        <div class="content-card">
            <% if (vehicles != null && !vehicles.isEmpty()) { %>
                <!-- Statistics -->
                <div class="stats-grid">
                    <%
                        int totalVehicles = vehicles.size();
                        int availableCount = 0;
                        int rentedCount = 0;
                        int maintenanceCount = 0;
                        
                        for (VehicleData v : vehicles) {
                            if ("Available".equalsIgnoreCase(v.status) || v.availability) {
                                availableCount++;
                            } else if ("Rented".equalsIgnoreCase(v.status)) {
                                rentedCount++;
                            } else if ("Maintenance".equalsIgnoreCase(v.status)) {
                                maintenanceCount++;
                            }
                        }
                    %>
                    <div class="stat-card">
                        <div class="stat-number"><%= totalVehicles %></div>
                        <div class="stat-label">Total Vehicles</div>
                    </div>
                    <div class="stat-card">
                        <div class="stat-number"><%= availableCount %></div>
                        <div class="stat-label">Available</div>
                    </div>
                    <div class="stat-card">
                        <div class="stat-number"><%= rentedCount %></div>
                        <div class="stat-label">Rented</div>
                    </div>
                    <div class="stat-card">
                        <div class="stat-number"><%= maintenanceCount %></div>
                        <div class="stat-label">Maintenance</div>
                    </div>
                </div>

                <!-- Vehicles Grid -->
                <div class="vehicles-grid">
                    <% for (VehicleData vehicle : vehicles) { %>
                        <div class="vehicle-card">
                            <% if (vehicle.imageUrl != null && !vehicle.imageUrl.isEmpty()) { %>
                                <img src="<%= vehicle.imageUrl %>" alt="<%= vehicle.vehicleName %>" class="vehicle-image">
                            <% } %>
                            
                            <div class="vehicle-header">
                                <div class="vehicle-info">
                                    <h3><%= vehicle.vehicleName %></h3>
                                    <p><%= vehicle.vehicleModel %></p>
                                    <p>#<%= vehicle.vehicleNumber %></p>
                                </div>
                                <div class="status-badge <%= 
                                    "Available".equalsIgnoreCase(vehicle.status) || vehicle.availability ? "status-available" : 
                                    "Rented".equalsIgnoreCase(vehicle.status) ? "status-rented" : 
                                    "status-maintenance" %>">
                                    <%= vehicle.status != null ? vehicle.status : (vehicle.availability ? "Available" : "Unavailable") %>
                                </div>
                            </div>

                            <div class="vehicle-details">
                                <div class="detail-row">
                                    <span class="detail-label">Type:</span>
                                    <span class="detail-value"><%= vehicle.vehicleType %></span>
                                </div>
                                <div class="detail-row">
                                    <span class="detail-label">Rent/Day:</span>
                                    <span class="detail-value">₹<%= String.format("%.2f", vehicle.rentPerDay) %></span>
                                </div>
                            </div>

                            <% if (vehicle.ownerName != null) { %>
                                <div class="owner-info">
                                    <h4>Owner Information</h4>
                                    <p><strong><%= vehicle.ownerName %></strong></p>
                                    <p><%= vehicle.ownerEmail %></p>
                                </div>
                            <% } %>

                            <div class="actions">
                                <% if ("Available".equalsIgnoreCase(vehicle.status) || vehicle.availability) { %>
                                    <form method="post" style="display: inline;">
                                        <input type="hidden" name="vehicle_id" value="<%= vehicle.vehicleId %>">
                                        <input type="hidden" name="action" value="toggle_status">
                                        <input type="hidden" name="new_status" value="Maintenance">
                                        <button type="submit" class="btn btn-warning btn-sm">Mark Maintenance</button>
                                    </form>
                                <% } else if ("Maintenance".equalsIgnoreCase(vehicle.status)) { %>
                                    <form method="post" style="display: inline;">
                                        <input type="hidden" name="vehicle_id" value="<%= vehicle.vehicleId %>">
                                        <input type="hidden" name="action" value="toggle_status">
                                        <input type="hidden" name="new_status" value="Available">
                                        <button type="submit" class="btn btn-success btn-sm">Mark Available</button>
                                    </form>
                                <% } %>
                                
                                <button class="btn btn-info btn-sm" onclick="showVehicleDetails(<%= vehicle.vehicleId %>)">View Details</button>
                                
                                <form method="post" style="display: inline;" onsubmit="return confirm('Are you sure you want to delete this vehicle?')">
                                    <input type="hidden" name="vehicle_id" value="<%= vehicle.vehicleId %>">
                                    <input type="hidden" name="action" value="delete">
                                    <button type="submit" class="btn btn-danger btn-sm">Delete</button>
                                </form>
                            </div>
                        </div>
                    <% } %>
                </div>
            <% } else { %>
                <div class="empty-state">
                    <h3>No Vehicles Found</h3>
                    <p>There are currently no vehicles in the system.</p>
                </div>
            <% } %>
        </div>
    </div>

    <!-- Modal for vehicle details -->
    <div id="vehicleModal" class="modal">
        <div class="modal-content">
            <span class="close">&times;</span>
            <div id="vehicleDetails"></div>
        </div>
    </div>

    <script>
        // Modal functionality
        var modal = document.getElementById('vehicleModal');
        var span = document.getElementsByClassName('close')[0];

        function showVehicleDetails(vehicleId) {
            // This would typically make an AJAX call to get more details
            // For now, just show the modal
            modal.style.display = 'block';
            document.getElementById('vehicleDetails').innerHTML = '<h3>Vehicle Details</h3><p>Detailed information for vehicle ID: ' + vehicleId + '</p>';
        }

        span.onclick = function() {
            modal.style.display = 'none';
        }

        window.onclick = function(event) {
            if (event.target == modal) {
                modal.style.display = 'none';
            }
        }

        // Auto-refresh every 30 seconds
        setTimeout(function() {
            location.reload();
        }, 30000);
    </script>
</body>
</html>