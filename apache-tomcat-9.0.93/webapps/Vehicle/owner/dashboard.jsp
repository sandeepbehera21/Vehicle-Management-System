<%@ page language="java" contentType="text/html; charset=ISO-8859-1" pageEncoding="ISO-8859-1"%>
<!DOCTYPE html>
<html>
<head>
  <meta charset="ISO-8859-1">
  <title>Owner Dashboard</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.0.2/dist/css/bootstrap.min.css" rel="stylesheet">
  <style>
    body { background-color: #f7f9fb; }
    .brand { font-weight: 700; letter-spacing: .5px; }
    .stat-card { border: 0; border-radius: 1rem; box-shadow: 0 8px 24px rgba(0,0,0,.08); }
    .stat-value { font-size: 2.2rem; font-weight: 700; }
    .nav-link.active { font-weight: 600; }
  </style>
</head>
<body>
<%
  response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
  if (session.getAttribute("owner_id") == null) {
    response.sendRedirect(request.getContextPath() + "/owner/login");
    return;
  }
  String ownerName = (String) session.getAttribute("owner_name");
  long totalVehicles = (request.getAttribute("totalVehicles") != null) ? (Long) request.getAttribute("totalVehicles") : 0L;
  long pendingBookings = (request.getAttribute("pendingBookings") != null) ? (Long) request.getAttribute("pendingBookings") : 0L;
  long approvedBookings = (request.getAttribute("approvedBookings") != null) ? (Long) request.getAttribute("approvedBookings") : 0L;
  double totalRevenue = (request.getAttribute("totalRevenue") != null) ? (Double) request.getAttribute("totalRevenue") : 0.0;
%>

  <!-- Navbar -->
  <nav class="navbar navbar-expand-lg navbar-dark bg-dark">
    <div class="container-fluid">
      <a class="navbar-brand brand" href="<%= request.getContextPath() %>/owner/dashboard">MotorHub Owner</a>
      <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#nav" aria-controls="nav" aria-expanded="false" aria-label="Toggle navigation">
        <span class="navbar-toggler-icon"></span>
      </button>
      <div id="nav" class="collapse navbar-collapse">
        <ul class="navbar-nav me-auto mb-2 mb-lg-0">
          <li class="nav-item"><a class="nav-link active" href="<%= request.getContextPath() %>/owner/dashboard">Dashboard</a></li>
          <li class="nav-item"><a class="nav-link" href="<%= request.getContextPath() %>/owner/vehicles">My Vehicles</a></li>
          <li class="nav-item"><a class="nav-link" href="<%= request.getContextPath() %>/owner/bookings">Bookings</a></li>
          <li class="nav-item"><a class="nav-link" href="<%= request.getContextPath() %>/owner/revenue">Revenue</a></li>
        </ul>
        <span class="navbar-text text-white me-3">Hi, <%= ownerName != null ? ownerName : "Owner" %></span>
        <a class="btn btn-outline-light" href="<%= request.getContextPath() %>/owner/logout">Logout</a>
      </div>
    </div>
  </nav>

  <!-- Content -->
  <div class="container py-5">
    <div class="row g-4">
      <div class="col-md-3">
        <div class="card stat-card">
          <div class="card-body">
            <h6 class="text-muted">Total Vehicles</h6>
            <div class="stat-value"><%= totalVehicles %></div>
          </div>
        </div>
      </div>
      <div class="col-md-3">
        <div class="card stat-card">
          <div class="card-body">
            <h6 class="text-muted">Pending Bookings</h6>
            <div class="stat-value text-warning"><%= pendingBookings %></div>
          </div>
        </div>
      </div>
      <div class="col-md-3">
        <div class="card stat-card">
          <div class="card-body">
            <h6 class="text-muted">Approved Bookings</h6>
            <div class="stat-value text-success"><%= approvedBookings %></div>
          </div>
        </div>
      </div>
      <div class="col-md-3">
        <div class="card stat-card">
          <div class="card-body">
            <h6 class="text-muted">Total Revenue</h6>
            <div class="stat-value">₹ <%= String.format("%.2f", totalRevenue) %></div>
          </div>
        </div>
      </div>
    </div>

    <div class="mt-5">
      <a href="<%= request.getContextPath() %>/owner/vehicles" class="btn btn-primary me-2">Manage Vehicles</a>
      <a href="<%= request.getContextPath() %>/owner/bookings" class="btn btn-outline-secondary me-2">Manage Bookings</a>
      <a href="<%= request.getContextPath() %>/owner/revenue" class="btn btn-outline-dark">View Revenue</a>
    </div>
  </div>

  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.0.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
