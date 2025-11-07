<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>User Dashboard - VehicleHub</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.2.0/css/all.min.css">
  <link rel="stylesheet" href="<%= request.getContextPath() %>/css/unified-style.css">
</head>
<body>
  <div class="container-fluid">
    <div class="row">
      <!-- Sidebar -->
      <div class="col-md-3 col-lg-2 p-0 sidebar">
        <div class="brand">
          <i class="fas fa-user me-2"></i>VehicleHub User
        </div>
        <div class="p-3">
          <nav class="nav flex-column">
            <a class="nav-link active" href="<%= request.getContextPath() %>/user/dashboard">
              <i class="fas fa-tachometer-alt"></i>Dashboard
            </a>
            <a class="nav-link" href="<%= request.getContextPath() %>/user/book_vehicle">
              <i class="fas fa-car"></i>Book Vehicle
            </a>
            <a class="nav-link" href="<%= request.getContextPath() %>/user/my_trips">
              <i class="fas fa-history"></i>My Trips
            </a>
            <a class="nav-link" href="<%= request.getContextPath() %>/user/profile">
              <i class="fas fa-user"></i>Profile
            </a>
            <a class="nav-link" href="<%= request.getContextPath() %>/user/payments">
              <i class="fas fa-credit-card"></i>Payments
            </a>
            <div class="nav-divider"></div>
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
              <div class="label"><i class="fas fa-route me-2"></i>Total Trips</div>
              <div class="value"><%= request.getAttribute("totalTrips") != null ? request.getAttribute("totalTrips") : 0 %></div>
            </div>
          </div>
          <div class="col-md-3">
            <div class="stat-card text-success">
              <div class="label"><i class="fas fa-calendar-check me-2"></i>Active Bookings</div>
              <div class="value"><%= request.getAttribute("activeBookings") != null ? request.getAttribute("activeBookings") : 0 %></div>
            </div>
          </div>
          <div class="col-md-3">
            <div class="stat-card text-warning">
              <div class="label"><i class="fas fa-clock me-2"></i>Pending Requests</div>
              <div class="value"><%= request.getAttribute("pendingRequests") != null ? request.getAttribute("pendingRequests") : 0 %></div>
            </div>
          </div>
          <div class="col-md-3">
            <div class="stat-card text-info">
              <div class="label"><i class="fas fa-rupee-sign me-2"></i>Total Spending</div>
              <div class="value">₹<%= request.getAttribute("totalSpending") != null ? String.format("%.2f", (Double)request.getAttribute("totalSpending")) : "0.00" %></div>
            </div>
          </div>
        </div>

        <div class="row g-4">
          <!-- Notifications -->
          <div class="col-md-6">
            <div class="content-card">
              <h5 class="mb-3"><i class="fas fa-bell me-2"></i>Notifications</h5>
              <div class="list-group list-group-flush">
                <div class="notification-item">
                  <i class="fas fa-check-circle text-success me-2"></i>
                  Your booking for Toyota Camry is approved.
                </div>
                <div class="notification-item">
                  <i class="fas fa-tools text-warning me-2"></i>
                  Maintenance alert: Honda Civic will be unavailable next week.
                </div>
                <div class="notification-item">
                  <i class="fas fa-flag-checkered text-info me-2"></i>
                  Your trip to the airport has been completed.
                </div>
              </div>
            </div>
          </div>

          <!-- Quick Actions -->
          <div class="col-md-6">
            <div class="content-card">
              <h5 class="mb-3"><i class="fas fa-rocket me-2"></i>Quick Actions</h5>
              <div class="quick-actions">
                <a href="<%= request.getContextPath() %>/user/book_vehicle" class="btn btn-primary">
                  <i class="fas fa-car me-2"></i>Book Vehicle
                </a>
                <a href="<%= request.getContextPath() %>/user/my_trips" class="btn btn-outline-primary">
                  <i class="fas fa-history me-2"></i>View Trips
                </a>
                <a href="<%= request.getContextPath() %>/user/payments" class="btn btn-outline-primary">
                  <i class="fas fa-credit-card me-2"></i>Payment History
                </a>
                <a href="<%= request.getContextPath() %>/user/profile" class="btn btn-outline-primary">
                  <i class="fas fa-user me-2"></i>Profile
                </a>
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
