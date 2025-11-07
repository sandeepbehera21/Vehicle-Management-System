<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.vehicle.VehicleInfo" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Book Vehicle - VehicleHub</title>
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
  </style>
</head>
<body>
<% VehicleInfo vehicle = (VehicleInfo) request.getAttribute("vehicle"); %>
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
        <h1 class="h2 mb-4">Book: <%= vehicle.getVehicle_name() %></h1>

        <div class="row">
            <div class="col-md-6">
                <div class="card">
                    <img src="<%= vehicle.getImage_url() != null ? vehicle.getImage_url() : "https://images.unsplash.com/photo-1552519507-da3b142c6e3d?q=80&w=2070&auto=format&fit=crop" %>" class="card-img-top" alt="<%= vehicle.getVehicle_name() %>">
                    <div class="card-body">
                        <h5 class="card-title"><%= vehicle.getVehicle_name() %></h5>
                        <p class="card-text"><%= vehicle.getVehicle_type() %></p>
                        <p class="card-text"><strong>₹<%= String.format("%.2f", (vehicle.getRent_per_day() / 24.0)) %> / hour</strong></p>
                    </div>
                </div>
            </div>
            <div class="col-md-6">
                <div class="card">
                    <div class="card-body">
                        <h5 class="card-title">Booking Details</h5>
                        <% if (request.getParameter("error") != null && request.getParameter("error").equals("unavailable")) { %>
                          <div class="alert alert-danger">Sorry, this vehicle is already booked for those dates. Please choose different dates.</div>
                        <% } %>
                        <form action="<%= request.getContextPath() %>/user/create_booking" method="post">
                            <input type="hidden" name="vehicle_id" value="<%= vehicle.getVehicle_id() %>">
                            <input type="hidden" name="rent_per_day" value="<%= vehicle.getRent_per_day() %>">
                            <input type="hidden" id="booking_time" name="booking_time" value="">
                            <div class="row">
                              <div class="col-md-6 mb-3">
                                <label for="start_date" class="form-label">Start Date</label>
                                <input type="date" class="form-control" id="start_date" name="start_date" required>
                              </div>
                              <div class="col-md-6 mb-3">
                                <label for="start_time" class="form-label">Start Time</label>
                                <input type="time" class="form-control" id="start_time" name="start_time" required>
                              </div>
                            </div>
                            <div class="row">
                              <div class="col-md-6 mb-3">
                                <label for="end_date" class="form-label">End Date</label>
                                <input type="date" class="form-control" id="end_date" name="end_date" required>
                              </div>
                              <div class="col-md-6 mb-3">
                                <label for="end_time" class="form-label">End Time</label>
                                <input type="time" class="form-control" id="end_time" name="end_time" required>
                              </div>
                            </div>
                            <div class="mb-3">
                                <label for="pickup_location" class="form-label">Pickup Location</label>
                                <input type="text" class="form-control" id="pickup_location" name="pickup_location" required>
                            </div>
                            <div class="mb-3">
                                <div class="d-flex justify-content-between align-items-center">
                                  <label for="drop_location" class="form-label mb-0">Drop Location</label>
                                  <div class="form-check">
                                    <input class="form-check-input" type="checkbox" value="1" id="sameAsPickup">
                                    <label class="form-check-label" for="sameAsPickup">
                                      Same as Pickup
                                    </label>
                                  </div>
                                </div>
                                <input type="text" class="form-control" id="drop_location" name="drop_location" required>
                            </div>
                            <div class="mb-3">
                                <label for="purpose" class="form-label">Purpose of Trip</label>
                                <textarea class="form-control" id="purpose" name="purpose" rows="3"></textarea>
                            </div>
                            <button type="submit" class="btn btn-primary">Confirm Booking</button>
                        </form>
                    </div>
                </div>
            </div>
        </div>

      </main>
    </div>
  </div>

  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
  <script>
    // Set booking timestamp
    (function(){
      var now = new Date();
      // ISO-like without timezone for server convenience
      var ts = now.getFullYear()+"-"+String(now.getMonth()+1).padStart(2,'0')+"-"+String(now.getDate()).padStart(2,'0')+
               " "+String(now.getHours()).padStart(2,'0')+":"+String(now.getMinutes()).padStart(2,'0')+":"+String(now.getSeconds()).padStart(2,'0');
      document.getElementById('booking_time').value = ts;
    })();

    // Same as pickup behavior
    document.getElementById('sameAsPickup').addEventListener('change', function(){
      var pick = document.getElementById('pickup_location');
      var drop = document.getElementById('drop_location');
      if (this.checked) {
        drop.value = pick.value;
        drop.readOnly = true;
      } else {
        drop.readOnly = false;
      }
    });
    document.getElementById('pickup_location').addEventListener('input', function(){
      var same = document.getElementById('sameAsPickup');
      if (same.checked) {
        document.getElementById('drop_location').value = this.value;
      }
    });
  </script>
</body>
</html>
