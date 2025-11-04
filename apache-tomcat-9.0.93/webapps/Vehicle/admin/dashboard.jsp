<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>Admin Dashboard - Vehicle Management</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.0.2/dist/css/bootstrap.min.css" rel="stylesheet">
  <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
  <style>
    body { background: #f8f9fa; }
    .sidebar {
      background: linear-gradient(45deg, #667eea 0%, #764ba2 100%);
      min-height: 100vh;
      color: white;
    }
    .stat-card {
      border: 0;
      border-radius: 15px;
      box-shadow: 0 5px 15px rgba(0,0,0,0.08);
      transition: all 0.3s ease;
      overflow: hidden;
    }
    .stat-card:hover {
      transform: translateY(-5px);
      box-shadow: 0 10px 25px rgba(0,0,0,0.15);
    }
    .stat-value {
      font-size: 2.5rem;
      font-weight: 700;
    }
    .nav-link {
      color: rgba(255,255,255,0.8);
      padding: 12px 20px;
      margin: 2px 0;
      border-radius: 10px;
      transition: all 0.3s ease;
    }
    .nav-link:hover, .nav-link.active {
      background: rgba(255,255,255,0.2);
      color: white;
    }
    .chart-card {
      border-radius: 15px;
      border: 0;
      box-shadow: 0 5px 15px rgba(0,0,0,0.08);
    }
  </style>
</head>
<body>
<%
  response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
  if (session.getAttribute("admin_id") == null) {
    response.sendRedirect(request.getContextPath() + "/admin/login");
    return;
  }
  String adminName = (String) session.getAttribute("admin_name");
%>

<div class="container-fluid">
  <div class="row">
    <!-- Sidebar -->
    <div class="col-md-3 col-lg-2 sidebar p-0">
      <div class="p-4">
        <div class="text-center mb-4">
          <i class="fas fa-user-shield fa-3x mb-3"></i>
          <h4>Admin Panel</h4>
          <p class="small opacity-75">Welcome, <%= adminName %></p>
        </div>
        
        <nav class="nav flex-column">
          <a class="nav-link active" href="<%= request.getContextPath() %>/admin/dashboard">
            <i class="fas fa-tachometer-alt me-2"></i>Dashboard
          </a>
          <a class="nav-link" href="<%= request.getContextPath() %>/admin/vehicles">
            <i class="fas fa-car me-2"></i>Vehicles
          </a>
          <a class="nav-link" href="<%= request.getContextPath() %>/admin/owners">
            <i class="fas fa-users me-2"></i>Owners
          </a>
          <a class="nav-link" href="<%= request.getContextPath() %>/admin/users">
            <i class="fas fa-user me-2"></i>Users
          </a>
          <a class="nav-link" href="<%= request.getContextPath() %>/admin/trips">
            <i class="fas fa-route me-2"></i>Trips
          </a>
          <a class="nav-link" href="<%= request.getContextPath() %>/admin/maintenance">
            <i class="fas fa-tools me-2"></i>Maintenance
          </a>
          <hr class="my-3 opacity-50">
          <a class="nav-link" href="<%= request.getContextPath() %>/admin/logout">
            <i class="fas fa-sign-out-alt me-2"></i>Logout
          </a>
        </nav>
      </div>
    </div>
    
    <!-- Main Content -->
    <div class="col-md-9 col-lg-10">
      <div class="p-4">
        <div class="d-flex justify-content-between align-items-center mb-4">
          <h1 class="h3 mb-0">Dashboard Overview</h1>
          <div class="text-muted">
            <i class="fas fa-calendar me-1"></i>
            <%= new java.text.SimpleDateFormat("EEEE, MMMM dd, yyyy").format(new java.util.Date()) %>
          </div>
        </div>

        <!-- Key Metrics Row -->
        <div class="row g-4 mb-4">
          <div class="col-md-3">
            <div class="card stat-card bg-primary text-white">
              <div class="card-body">
                <div class="d-flex justify-content-between">
                  <div>
                    <p class="mb-1 opacity-75">Total Users</p>
                    <div class="stat-value"><%= request.getAttribute("totalUsers") %></div>
                  </div>
                  <i class="fas fa-users fa-2x opacity-50"></i>
                </div>
              </div>
            </div>
          </div>
          
          <div class="col-md-3">
            <div class="card stat-card bg-success text-white">
              <div class="card-body">
                <div class="d-flex justify-content-between">
                  <div>
                    <p class="mb-1 opacity-75">Total Owners</p>
                    <div class="stat-value"><%= request.getAttribute("totalOwners") %></div>
                  </div>
                  <i class="fas fa-user-tie fa-2x opacity-50"></i>
                </div>
              </div>
            </div>
          </div>
          
          <div class="col-md-3">
            <div class="card stat-card bg-info text-white">
              <div class="card-body">
                <div class="d-flex justify-content-between">
                  <div>
                    <p class="mb-1 opacity-75">Total Vehicles</p>
                    <div class="stat-value"><%= request.getAttribute("totalVehicles") %></div>
                  </div>
                  <i class="fas fa-car fa-2x opacity-50"></i>
                </div>
              </div>
            </div>
          </div>
          
          <div class="col-md-3">
            <div class="card stat-card bg-warning text-white">
              <div class="card-body">
                <div class="d-flex justify-content-between">
                  <div>
                    <p class="mb-1 opacity-75">Total Bookings</p>
                    <div class="stat-value"><%= request.getAttribute("totalBookings") %></div>
                  </div>
                  <i class="fas fa-calendar-check fa-2x opacity-50"></i>
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- Financial Overview -->
        <div class="row g-4 mb-4">
          <div class="col-md-4">
            <div class="card stat-card">
              <div class="card-body">
                <h6 class="text-muted">Total Revenue</h6>
                <div class="h3 text-success">₹ <%= String.format("%.2f", (Double) request.getAttribute("totalRevenue")) %></div>
                <small class="text-muted">
                  <i class="fas fa-arrow-up text-success me-1"></i>From completed bookings
                </small>
              </div>
            </div>
          </div>
          
          <div class="col-md-4">
            <div class="card stat-card">
              <div class="card-body">
                <h6 class="text-muted">Pending Amount</h6>
                <div class="h3 text-warning">₹ <%= String.format("%.2f", (Double) request.getAttribute("pendingAmount")) %></div>
                <small class="text-muted">
                  <i class="fas fa-clock text-warning me-1"></i>Pending & approved bookings
                </small>
              </div>
            </div>
          </div>
          
          <div class="col-md-4">
            <div class="card stat-card">
              <div class="card-body">
                <h6 class="text-muted">Maintenance Cost</h6>
                <div class="h3 text-danger">₹ <%= String.format("%.2f", (Double) request.getAttribute("maintenanceCost")) %></div>
                <small class="text-muted">
                  <i class="fas fa-tools text-danger me-1"></i>Last 30 days
                </small>
              </div>
            </div>
          </div>
        </div>

        <!-- Status Breakdown -->
        <div class="row g-4">
          <!-- User Status -->
          <div class="col-md-4">
            <div class="card chart-card">
              <div class="card-header bg-transparent">
                <h6 class="mb-0"><i class="fas fa-users me-2"></i>User Status</h6>
              </div>
              <div class="card-body">
                <div class="d-flex justify-content-between align-items-center mb-2">
                  <span>Active</span>
                  <span class="badge bg-success"><%= request.getAttribute("activeUsers") %></span>
                </div>
                <div class="d-flex justify-content-between align-items-center mb-2">
                  <span>Pending</span>
                  <span class="badge bg-warning"><%= request.getAttribute("pendingUsers") %></span>
                </div>
                <div class="d-flex justify-content-between align-items-center">
                  <span>Suspended</span>
                  <span class="badge bg-danger"><%= request.getAttribute("suspendedUsers") %></span>
                </div>
              </div>
            </div>
          </div>

          <!-- Vehicle Status -->
          <div class="col-md-4">
            <div class="card chart-card">
              <div class="card-header bg-transparent">
                <h6 class="mb-0"><i class="fas fa-car me-2"></i>Vehicle Status</h6>
              </div>
              <div class="card-body">
                <div class="d-flex justify-content-between align-items-center mb-2">
                  <span>Available</span>
                  <span class="badge bg-success"><%= request.getAttribute("availableVehicles") %></span>
                </div>
                <div class="d-flex justify-content-between align-items-center mb-2">
                  <span>On Trip</span>
                  <span class="badge bg-warning"><%= request.getAttribute("onTripVehicles") %></span>
                </div>
                <div class="d-flex justify-content-between align-items-center">
                  <span>Maintenance</span>
                  <span class="badge bg-danger"><%= request.getAttribute("maintenanceVehicles") %></span>
                </div>
              </div>
            </div>
          </div>

          <!-- Booking Status -->
          <div class="col-md-4">
            <div class="card chart-card">
              <div class="card-header bg-transparent">
                <h6 class="mb-0"><i class="fas fa-calendar-check me-2"></i>Booking Status</h6>
              </div>
              <div class="card-body">
                <div class="d-flex justify-content-between align-items-center mb-2">
                  <span>Pending</span>
                  <span class="badge bg-warning"><%= request.getAttribute("pendingBookings") %></span>
                </div>
                <div class="d-flex justify-content-between align-items-center mb-2">
                  <span>Approved</span>
                  <span class="badge bg-info"><%= request.getAttribute("approvedBookings") %></span>
                </div>
                <div class="d-flex justify-content-between align-items-center">
                  <span>Completed</span>
                  <span class="badge bg-success"><%= request.getAttribute("completedBookings") %></span>
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- Recent Activity -->
        <div class="row g-4 mt-2">
          <div class="col-12">
            <div class="card chart-card">
              <div class="card-header bg-transparent">
                <h6 class="mb-0"><i class="fas fa-chart-line me-2"></i>Recent Activity (Last 7 Days)</h6>
              </div>
              <div class="card-body">
                <div class="row text-center">
                  <div class="col-md-6">
                    <div class="border-end">
                      <div class="h2 text-primary"><%= request.getAttribute("recentBookings") %></div>
                      <p class="text-muted mb-0">New Bookings</p>
                    </div>
                  </div>
                  <div class="col-md-6">
                    <div class="h2 text-success"><%= request.getAttribute("recentRegistrations") %></div>
                    <p class="text-muted mb-0">New Registrations</p>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.0.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>