<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Owner Dashboard - VehicleHub</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.2.0/css/all.min.css">
  <link rel="stylesheet" href="<%= request.getContextPath() %>/css/unified-style.css">
</head>
<body>
<%
  response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
  if (session.getAttribute("owner_id") == null) {
    response.sendRedirect(request.getContextPath() + "/login");
    return;
  }
  String ownerName = (String) session.getAttribute("owner_name");
  long totalVehicles = (request.getAttribute("totalVehicles") != null) ? (Long) request.getAttribute("totalVehicles") : 0L;
  long pendingBookings = (request.getAttribute("pendingBookings") != null) ? (Long) request.getAttribute("pendingBookings") : 0L;
  long approvedBookings = (request.getAttribute("approvedBookings") != null) ? (Long) request.getAttribute("approvedBookings") : 0L;
  double totalRevenue = (request.getAttribute("totalRevenue") != null) ? (Double) request.getAttribute("totalRevenue") : 0.0;
%>

  <div class="container-fluid">
    <div class="row">
      <!-- Sidebar -->
      <div class="col-md-3 col-lg-2 p-0 sidebar">
        <div class="brand">
          <i class="fas fa-car me-2"></i>VehicleHub Owner
        </div>
        <div class="p-3">
          <nav class="nav flex-column">
            <a class="nav-link active" href="<%= request.getContextPath() %>/owner/dashboard">
              <i class="fas fa-tachometer-alt"></i>Dashboard
            </a>
            <a class="nav-link" href="<%= request.getContextPath() %>/owner/vehicles">
              <i class="fas fa-car"></i>My Vehicles
            </a>
            <a class="nav-link" href="<%= request.getContextPath() %>/owner/bookings">
              <i class="fas fa-calendar-check"></i>Bookings
            </a>
            <a class="nav-link" href="<%= request.getContextPath() %>/owner/revenue">
              <i class="fas fa-chart-line"></i>Revenue
            </a>
            <a class="nav-link" href="<%= request.getContextPath() %>/owner/maintenance">
              <i class="fas fa-tools"></i>Maintenance
            </a>
            <a class="nav-link" href="<%= request.getContextPath() %>/owner/ratings">
              <i class="fas fa-star"></i>Ratings & Reviews
            </a>
            <div class="nav-divider"></div>
            <div class="px-3 py-2">
              <small class="text-muted">Hi, <%= ownerName != null ? ownerName : "Owner" %></small>
            </div>
            <a class="nav-link" href="<%= request.getContextPath() %>/logout">
              <i class="fas fa-sign-out-alt"></i>Logout
            </a>
          </nav>
        </div>
      </div>

      <!-- Main Content -->
      <main class="main-content">
        <div class="page-header">
          <h1 class="page-title"><i class="fas fa-tachometer-alt me-2"></i>Dashboard</h1>
        </div>
        <!-- Quick Statistics -->
        <div class="row g-4 mb-4">
          <div class="col-md-3">
            <div class="stat-card text-primary">
              <div class="label"><i class="fas fa-car me-2"></i>Total Vehicles</div>
              <div class="value"><%= totalVehicles %></div>
            </div>
          </div>
          <div class="col-md-3">
            <div class="stat-card text-warning">
              <div class="label"><i class="fas fa-clock me-2"></i>Pending Bookings</div>
              <div class="value"><%= pendingBookings %></div>
            </div>
          </div>
          <div class="col-md-3">
            <div class="stat-card text-success">
              <div class="label"><i class="fas fa-check-circle me-2"></i>Approved Bookings</div>
              <div class="value"><%= approvedBookings %></div>
            </div>
          </div>
          <div class="col-md-3">
            <div class="stat-card text-info">
              <div class="label"><i class="fas fa-rupee-sign me-2"></i>Total Revenue</div>
              <div class="value">₹<%= String.format("%.2f", totalRevenue) %></div>
            </div>
          </div>
        </div>

        <div class="row g-4">
          <!-- Quick Actions -->
          <div class="col-md-6">
            <div class="content-card">
              <h5 class="mb-3"><i class="fas fa-rocket me-2"></i>Quick Actions</h5>
              <div class="quick-actions">
                <a href="<%= request.getContextPath() %>/owner/vehicles" class="btn btn-primary">
                  <i class="fas fa-car me-2"></i>Manage Vehicles
                </a>
                <a href="<%= request.getContextPath() %>/owner/bookings" class="btn btn-outline-primary">
                  <i class="fas fa-calendar-check me-2"></i>Manage Bookings
                </a>
                <a href="<%= request.getContextPath() %>/owner/revenue" class="btn btn-outline-primary">
                  <i class="fas fa-chart-line me-2"></i>View Revenue
                </a>
                <a href="<%= request.getContextPath() %>/owner/vehicles/new" class="btn btn-success">
                  <i class="fas fa-plus me-2"></i>Add Vehicle
                </a>
              </div>
            </div>
          </div>

          <!-- Recent Activity -->
          <div class="col-md-6">
            <div class="content-card">
              <h5 class="mb-3"><i class="fas fa-bell me-2"></i>Recent Activity</h5>
              <div class="list-group list-group-flush">
                <div class="notification-item">
                  <i class="fas fa-calendar-plus text-success me-2"></i>
                  New booking request received for your vehicle
                </div>
                <div class="notification-item">
                  <i class="fas fa-star text-warning me-2"></i>
                  You received a new 5-star rating
                </div>
                <div class="notification-item">
                  <i class="fas fa-tools text-info me-2"></i>
                  Vehicle maintenance reminder: Honda Civic
                </div>
                <div class="notification-item">
                  <i class="fas fa-money-bill-wave text-success me-2"></i>
                  Payment received: ₹2,500
                </div>
              </div>
            </div>
          </div>
        </div>

      </main>
    </div>
  </div>

  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
