<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="com.vehicle.OwnerMaintenanceServlet.VehicleRow,com.vehicle.OwnerMaintenanceServlet.MaintenanceRow" %>
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>Owner Maintenance</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.0.2/dist/css/bootstrap.min.css" rel="stylesheet">
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
</head>
<body>
<%
  response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
  if (session.getAttribute("owner_id") == null) {
    response.sendRedirect(request.getContextPath() + "/owner/login");
    return;
  }
  List<VehicleRow> vehicles = (List<VehicleRow>) request.getAttribute("vehicles");
  List<MaintenanceRow> maintenance = (List<MaintenanceRow>) request.getAttribute("maintenance");
%>

<nav class="navbar navbar-expand-lg navbar-dark bg-dark">
  <div class="container-fluid">
    <a class="navbar-brand" href="<%= request.getContextPath() %>/owner/dashboard">MotorHub Owner</a>
    <div class="collapse navbar-collapse">
      <ul class="navbar-nav me-auto">
        <li class="nav-item"><a class="nav-link" href="<%= request.getContextPath() %>/owner/dashboard">Dashboard</a></li>
        <li class="nav-item"><a class="nav-link" href="<%= request.getContextPath() %>/owner/vehicles">My Vehicles</a></li>
        <li class="nav-item"><a class="nav-link" href="<%= request.getContextPath() %>/owner/bookings">Bookings</a></li>
        <li class="nav-item"><a class="nav-link" href="<%= request.getContextPath() %>/owner/revenue">Revenue</a></li>
        <li class="nav-item"><a class="nav-link active" href="#">Maintenance</a></li>
      </ul>
      <a class="btn btn-outline-light" href="<%= request.getContextPath() %>/logout">Logout</a>
    </div>
  </div>
</nav>

<div class="container py-4">
  <div class="d-flex justify-content-between align-items-center mb-3">
    <h3><i class="fa-solid fa-screwdriver-wrench me-2"></i>Maintenance</h3>
  </div>

  <!-- Vehicles: schedule maintenance -->
  <div class="card mb-4">
    <div class="card-header bg-light"><strong>Your Vehicles</strong></div>
    <div class="card-body">
      <div class="table-responsive">
        <table class="table table-hover align-middle">
          <thead class="table-light">
            <tr>
              <th>ID</th>
              <th>Name</th>
              <th>Number</th>
              <th>Type</th>
              <th>Availability</th>
              <th>Action</th>
            </tr>
          </thead>
          <tbody>
          <% if (vehicles != null) { for (VehicleRow v : vehicles) { %>
            <tr>
              <td><%= v.vehicleId %></td>
              <td><%= v.vehicleName %></td>
              <td><%= v.vehicleNumber %></td>
              <td><%= v.vehicleType %></td>
              <td>
                <span class="badge <%= v.available ? "bg-success" : "bg-secondary" %>"><%= v.available ? "Available" : "Unavailable" %></span>
              </td>
              <td>
                <form class="row g-2" action="<%= request.getContextPath() %>/owner/maintenance" method="POST">
                  <input type="hidden" name="action" value="schedule">
                  <input type="hidden" name="vehicle_id" value="<%= v.vehicleId %>">
                  <div class="col-md-4">
                    <input type="date" name="maintenance_date" class="form-control" required>
                  </div>
                  <div class="col-md-3">
                    <select name="maintenance_type" class="form-select">
                      <option value="Routine">Routine</option>
                      <option value="Repair">Repair</option>
                      <option value="Inspection">Inspection</option>
                    </select>
                  </div>
                  <div class="col-md-3">
                    <input type="number" step="0.01" name="cost" placeholder="Cost (₹)" class="form-control">
                  </div>
                  <div class="col-md-12 mt-2">
                    <input type="text" name="description" placeholder="Description (optional)" class="form-control">
                  </div>
                  <div class="col-md-12 mt-2">
                    <button class="btn btn-primary"><i class="fa-solid fa-wrench me-1"></i>Schedule Maintenance</button>
                  </div>
                </form>
              </td>
            </tr>
          <% } } %>
          </tbody>
        </table>
      </div>
    </div>
  </div>

  <!-- Existing maintenance records -->
  <div class="card">
    <div class="card-header bg-light"><strong>Maintenance Records</strong></div>
    <div class="card-body">
      <div class="table-responsive">
        <table class="table table-hover align-middle">
          <thead class="table-light">
            <tr>
              <th>ID</th>
              <th>Vehicle</th>
              <th>Scheduled</th>
              <th>Completed</th>
              <th>Type</th>
              <th>Cost</th>
              <th>Status</th>
              <th>Action</th>
            </tr>
          </thead>
          <tbody>
          <% if (maintenance != null) { for (MaintenanceRow m : maintenance) { %>
            <tr>
              <td>#<%= m.maintenanceId %></td>
              <td><%= m.vehicleName %> (<%= m.vehicleNumber %>)</td>
              <td><%= m.maintenanceDate %></td>
              <td><%= m.completedDate != null ? m.completedDate : "-" %></td>
              <td><%= m.maintenanceType %></td>
              <td>₹<%= String.format("%.2f", m.cost) %></td>
              <td>
                <span class="badge <%= "Completed".equals(m.status) ? "bg-success" : ("In Progress".equals(m.status) ? "bg-primary" : "bg-warning text-dark") %>"><%= m.status %></span>
              </td>
              <td>
                <% if (!"Completed".equals(m.status)) { %>
                <form action="<%= request.getContextPath() %>/owner/maintenance" method="POST" class="d-inline">
                  <input type="hidden" name="action" value="complete">
                  <input type="hidden" name="maintenance_id" value="<%= m.maintenanceId %>">
                  <input type="hidden" name="vehicle_id" value="<%= m.vehicleId %>">
                  <button class="btn btn-success btn-sm"><i class="fa-solid fa-check me-1"></i>Mark Completed</button>
                </form>
                <% } %>
              </td>
            </tr>
          <% } } %>
          </tbody>
        </table>
      </div>
    </div>
  </div>
</div>

</body>
</html>
