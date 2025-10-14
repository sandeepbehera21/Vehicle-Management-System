<%@ page language="java" contentType="text/html; charset=ISO-8859-1" pageEncoding="ISO-8859-1"%>
<%@ page import="java.util.List" %>
<%@ page import="com.vehicle.OwnerVehiclesServlet.VehicleRow" %>
<!DOCTYPE html>
<html>
<head>
  <meta charset="ISO-8859-1">
  <title>My Vehicles</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.0.2/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body>
<%
  response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
  if (session.getAttribute("owner_id") == null) {
    response.sendRedirect(request.getContextPath() + "/owner/login");
    return;
  }
  List<VehicleRow> vehicles = (List<VehicleRow>) request.getAttribute("vehicles");
%>

<nav class="navbar navbar-expand-lg navbar-dark bg-dark">
  <div class="container-fluid">
    <a class="navbar-brand" href="<%= request.getContextPath() %>/owner/dashboard">MotorHub Owner</a>
    <div class="collapse navbar-collapse">
      <ul class="navbar-nav me-auto">
        <li class="nav-item"><a class="nav-link" href="<%= request.getContextPath() %>/owner/dashboard">Dashboard</a></li>
        <li class="nav-item"><a class="nav-link active" href="<%= request.getContextPath() %>/owner/vehicles">My Vehicles</a></li>
        <li class="nav-item"><a class="nav-link" href="<%= request.getContextPath() %>/owner/bookings">Bookings</a></li>
        <li class="nav-item"><a class="nav-link" href="<%= request.getContextPath() %>/owner/revenue">Revenue</a></li>
      </ul>
      <a class="btn btn-outline-light" href="<%= request.getContextPath() %>/owner/logout">Logout</a>
    </div>
  </div>
</nav>

<div class="container py-4">
  <div class="d-flex justify-content-between align-items-center mb-3">
    <h3>My Vehicles</h3>
    <a href="<%= request.getContextPath() %>/owner/vehicles/new" class="btn btn-primary">Add Vehicle</a>
  </div>

  <div class="table-responsive shadow-sm">
    <table class="table table-hover align-middle">
      <thead class="table-light">
        <tr>
          <th>Photo</th>
          <th>Name</th>
          <th>Model</th>
          <th>Type</th>
          <th>Registration No.</th>
          <th>Rent/Day</th>
          <th>Status</th>
          <th>Available</th>
          <th class="text-end">Actions</th>
        </tr>
      </thead>
      <tbody>
      <% if (vehicles != null) {
           for (VehicleRow v : vehicles) { %>
        <tr>
          <td style="width:140px">
            <% if (v.imageUrl != null) { %>
              <img src="<%= v.imageUrl %>" alt="img" class="img-thumbnail" style="max-height:80px;">
            <% } %>
          </td>
          <td><%= v.vehicleName %></td>
          <td><%= (v.vehicleModel != null ? v.vehicleModel : "-") %></td>
          <td><%= v.vehicleType %></td>
          <td><%= v.vehicleNumber %></td>
          <td>₹ <%= String.format("%.2f", v.rentPerDay) %></td>
          <td>
            <span class="badge <%= "Available".equalsIgnoreCase(v.status) ? "bg-success" : ("On Trip".equalsIgnoreCase(v.status) ? "bg-warning text-dark" : "bg-secondary") %>"><%= (v.status != null ? v.status : "Available") %></span>
          </td>
          <td>
            <span class="badge <%= v.availability ? "bg-success" : "bg-secondary" %>"><%= v.availability ? "Yes" : "No" %></span>
          </td>
          <td class="text-end">
            <a href="<%= request.getContextPath() %>/owner/vehicles/edit?id=<%= v.vehicleId %>" class="btn btn-sm btn-outline-primary">Edit</a>
            <form class="d-inline" action="<%= request.getContextPath() %>/owner/vehicles/delete" method="POST" onsubmit="return confirm('Delete this vehicle?')">
              <input type="hidden" name="vehicle_id" value="<%= v.vehicleId %>">
              <button type="submit" class="btn btn-sm btn-outline-danger">Delete</button>
            </form>
          </td>
        </tr>
      <% } } %>
      </tbody>
    </table>
  </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.0.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
