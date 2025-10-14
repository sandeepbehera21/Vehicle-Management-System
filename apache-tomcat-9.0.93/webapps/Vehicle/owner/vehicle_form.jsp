<%@ page language="java" contentType="text/html; charset=ISO-8859-1" pageEncoding="ISO-8859-1"%>
<!DOCTYPE html>
<html>
<head>
  <meta charset="ISO-8859-1">
  <title>Vehicle Form</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.0.2/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body>
<%
  response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
  if (session.getAttribute("owner_id") == null) {
    response.sendRedirect(request.getContextPath() + "/owner/login");
    return;
  }
  String mode = (String) request.getAttribute("mode");
  boolean isEdit = "edit".equals(mode);
%>

<nav class="navbar navbar-expand-lg navbar-dark bg-dark">
  <div class="container-fluid">
    <a class="navbar-brand" href="<%= request.getContextPath() %>/owner/dashboard">MotorHub Owner</a>
    <div class="collapse navbar-collapse">
      <ul class="navbar-nav me-auto">
        <li class="nav-item"><a class="nav-link" href="<%= request.getContextPath() %>/owner/vehicles">My Vehicles</a></li>
      </ul>
      <a class="btn btn-outline-light" href="<%= request.getContextPath() %>/owner/logout">Logout</a>
    </div>
  </div>
</nav>

<div class="container py-4">
  <div class="row justify-content-center">
    <div class="col-lg-8">
      <div class="card shadow-sm">
        <div class="card-body p-4">
          <h3 class="mb-3"><%= isEdit ? "Edit Vehicle" : "Add Vehicle" %></h3>

          <form action="<%= request.getContextPath() %><%= isEdit ? "/owner/vehicles/edit" : "/owner/vehicles/new" %>" method="POST" <%= isEdit ? "" : "enctype=\"multipart/form-data\"" %>>
            <% if (isEdit) { %>
              <input type="hidden" name="vehicle_id" value="<%= request.getAttribute("vehicle_id") %>">
            <% } %>

            <div class="row g-3">
              <div class="col-md-6">
                <label class="form-label">Vehicle Name</label>
                <input type="text" name="vehicle_name" class="form-control" value="<%= request.getAttribute("vehicle_name") != null ? request.getAttribute("vehicle_name") : "" %>" required>
              </div>
              <div class="col-md-6">
                <label class="form-label">Vehicle Model</label>
                <input type="text" name="vehicle_model" class="form-control" value="<%= request.getAttribute("vehicle_model") != null ? request.getAttribute("vehicle_model") : "" %>" placeholder="e.g., Swift, Activa, Classic 350">
              </div>
              <div class="col-md-6">
                <label class="form-label">Vehicle Type</label>
                <select class="form-select" name="vehicle_type" required>
                  <option value="Car" <%= "Car".equals(request.getAttribute("vehicle_type")) ? "selected" : "" %>>Car</option>
                  <option value="Bike" <%= "Bike".equals(request.getAttribute("vehicle_type")) ? "selected" : "" %>>Bike</option>
                  <option value="Scooter" <%= "Scooter".equals(request.getAttribute("vehicle_type")) ? "selected" : "" %>>Scooter</option>
                </select>
              </div>
              <div class="col-md-6">
                <label class="form-label">Registration Number</label>
                <input type="text" name="vehicle_number" class="form-control" value="<%= request.getAttribute("vehicle_number") != null ? request.getAttribute("vehicle_number") : "" %>" required>
              </div>
              <div class="col-md-6">
                <label class="form-label">Rent Per Day</label>
                <input type="number" step="0.01" min="0" name="rent_per_day" class="form-control" value="<%= request.getAttribute("rent_per_day") != null ? request.getAttribute("rent_per_day") : "" %>" required>
              </div>
              <% if (isEdit) { %>
              <div class="col-md-6">
                <label class="form-label">Status</label>
                <select class="form-select" name="status">
                  <% String currentStatus = (String) request.getAttribute("status"); if (currentStatus == null) currentStatus = "Available"; %>
                  <option value="Available" <%= "Available".equals(currentStatus) ? "selected" : "" %>>Available</option>
                  <option value="On Trip" <%= "On Trip".equals(currentStatus) ? "selected" : "" %>>On Trip</option>
                  <option value="Maintenance" <%= "Maintenance".equals(currentStatus) ? "selected" : "" %>>Maintenance</option>
                </select>
              </div>
              <% } %>
              <% if (!isEdit) { %>
              <div class="col-md-12">
                <label class="form-label">Photo</label>
                <input type="file" name="image" accept="image/*" class="form-control">
              </div>
              <% } %>
              <% if (isEdit) { %>
              <div class="col-md-12 form-check mt-3">
                <input class="form-check-input" type="checkbox" name="availability" id="avail" <%= Boolean.TRUE.equals(request.getAttribute("availability")) ? "checked" : "" %> >
                <label class="form-check-label" for="avail">Available</label>
              </div>
              <% } %>
            </div>

            <div class="mt-4 d-flex gap-2">
              <button type="submit" class="btn btn-success"><%= isEdit ? "Save Changes" : "Create Vehicle" %></button>
              <a href="<%= request.getContextPath() %>/owner/vehicles" class="btn btn-outline-secondary">Cancel</a>
            </div>
          </form>

        </div>
      </div>
    </div>
  </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.0.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
