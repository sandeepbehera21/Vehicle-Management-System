<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%><%@ page import="java.util.List,com.vehicle.VehicleInfo" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Book a Vehicle - VehicleHub</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.2.0/css/all.min.css">
  <style>
    :root {
      --primary-color: #6a11cb;
      --secondary-color: #2575fc;
      --light-gray: #f8f9fa;
    }
    body {
      background-color: var(--light-gray);
    }
    .sidebar {
      background-color: #fff;
      min-height: 100vh;
      box-shadow: 0 0 15px rgba(0,0,0,0.1);
    }
    .sidebar .nav-link {
      color: #333;
      font-weight: 500;
      margin: 5px 0;
      transition: all 0.2s ease;
    }
    .sidebar .nav-link.active, .sidebar .nav-link:hover {
      color: var(--secondary-color);
      background-color: #eef4ff;
      border-radius: 8px;
    }
    .vehicle-card {
        background: #fff;
        border-radius: 15px;
        box-shadow: 0 5px 15px rgba(0,0,0,0.05);
        transition: all 0.3s ease;
    }
    .vehicle-card:hover {
        transform: translateY(-5px);
        box-shadow: 0 10px 20px rgba(0,0,0,0.1);
    }
  </style>
</head>
<body>
  <div class="container-fluid">
    <div class="row">
      <!-- Sidebar -->
      <div class="col-md-3 col-lg-2 p-0 sidebar">
        <div class="p-3">
          <h4 class="text-center mb-4">User Menu</h4>
          <nav class="nav flex-column">
            <a class="nav-link" href="<%= request.getContextPath() %>/user/dashboard"><i class="fas fa-tachometer-alt me-2"></i>Dashboard</a>
            <a class="nav-link active" href="<%= request.getContextPath() %>/user/book_vehicle"><i class="fas fa-car me-2"></i>Book Vehicle</a>
            <a class="nav-link" href="<%= request.getContextPath() %>/user/my_trips"><i class="fas fa-history me-2"></i>My Trips</a>
            <a class="nav-link" href="<%= request.getContextPath() %>/user/profile"><i class="fas fa-user me-2"></i>Profile</a>
            <a class="nav-link" href="<%= request.getContextPath() %>/user/payments"><i class="fas fa-credit-card me-2"></i>Payments</a>
            <hr>
            <a class="nav-link" href="<%= request.getContextPath() %>/logout"><i class="fas fa-sign-out-alt me-2"></i>Logout</a>
          </nav>
        </div>
      </div>

      <!-- Main Content -->
      <main class="col-md-9 ms-sm-auto col-lg-10 px-md-4 py-4">
        <h1 class="h2 mb-4">Book a Vehicle</h1>

        <!-- Filters -->
        <div class="card mb-4">
            <div class="card-body">
                <div class="row g-3 align-items-center">
                    <div class="col-md-3">
                        <select class="form-select">
                            <option selected>All Vehicle Types</option>
                            <option>Car</option>
                            <option>Bike</option>
                            <option>Bus</option>
                        </select>
                    </div>
                    <div class="col-md-3">
                        <select class="form-select">
                            <option selected>Any Price Range</option>
                            <option>₹0 - ₹500</option>
                            <option>₹500 - ₹1000</option>
                            <option>₹1000+</option>
                        </select>
                    </div>
                    <div class="col-md-3">
                        <select class="form-select">
                            <option selected>Any Owner Rating</option>
                            <option>4+ Stars</option>
                            <option>3+ Stars</option>
                            <option>2+ Stars</option>
                        </select>
                    </div>
                    <div class="col-md-3">
                        <button class="btn btn-primary w-100">Apply Filters</button>
                    </div>
                </div>
            </div>
        </div>

        <!-- Vehicle Listings -->
        <div class="row g-4">
            <%
                List<VehicleInfo> vehicles = (List<VehicleInfo>) request.getAttribute("vehicles");
                if (vehicles != null && !vehicles.isEmpty()) {
                    for (VehicleInfo vehicle : vehicles) {
            %>
            <div class="col-md-4">
                <div class="card vehicle-card">
                    <img src="<%= vehicle.getImage_url() != null ? vehicle.getImage_url() : "https://images.unsplash.com/photo-1552519507-da3b142c6e3d?q=80&w=2070&auto=format&fit=crop" %>" class="card-img-top" alt="<%= vehicle.getVehicle_name() %>">
                    <div class="card-body">
                        <h5 class="card-title"><%= vehicle.getVehicle_name() %></h5>
                        <p class="card-text"><%= vehicle.getVehicle_type() %></p>
                        <p class="card-text"><strong>₹<%= String.format("%.2f", (vehicle.getRent_per_day() / 24.0)) %> / hour</strong></p>
                        <a href="<%= request.getContextPath() %>/user/booking_form?vehicle_id=<%= vehicle.getVehicle_id() %>" class="btn btn-primary">Book Now</a>
                    </div>
                </div>
            </div>
            <%
                    }
                } else {
            %>
            <div class="col-12">
                <p class="text-center">No vehicles available at the moment.</p>
            </div>
            <%
                }
            %>
        </div>

      </main>
    </div>
  </div>

  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
