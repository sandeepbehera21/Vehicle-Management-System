<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List,java.util.Map,java.text.SimpleDateFormat" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>My Ratings & Reviews - Owner Dashboard</title>
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
    .stats-card {
      background: linear-gradient(135deg, var(--primary-color), var(--secondary-color));
      color: white;
      border-radius: 15px;
      padding: 25px;
      margin-bottom: 20px;
    }
    .rating-card {
      background: white;
      border-radius: 15px;
      padding: 20px;
      margin-bottom: 15px;
      box-shadow: 0 2px 10px rgba(0,0,0,0.1);
      transition: transform 0.2s ease;
    }
    .rating-card:hover {
      transform: translateY(-2px);
    }
    .star-display {
      color: #ffd700;
      font-size: 1.2rem;
    }
    .rating-bar {
      height: 8px;
      background-color: #e9ecef;
      border-radius: 4px;
      overflow: hidden;
    }
    .rating-fill {
      height: 100%;
      background: linear-gradient(90deg, #ffd700, #ffed4e);
      transition: width 0.3s ease;
    }
    .vehicle-rating-card {
      background: white;
      border-radius: 10px;
      padding: 15px;
      margin-bottom: 10px;
      box-shadow: 0 2px 5px rgba(0,0,0,0.1);
    }
  </style>
</head>
<body>
  <div class="container-fluid">
    <div class="row">
      <!-- Sidebar -->
      <div class="col-md-3 col-lg-2 p-0 sidebar">
        <div class="p-3">
          <h4 class="text-center mb-4">Owner Panel</h4>
          <nav class="nav flex-column">
            <a class="nav-link" href="<%= request.getContextPath() %>/owner/dashboard"><i class="fas fa-tachometer-alt me-2"></i>Dashboard</a>
            <a class="nav-link" href="<%= request.getContextPath() %>/owner/vehicles"><i class="fas fa-car me-2"></i>My Vehicles</a>
            <a class="nav-link" href="<%= request.getContextPath() %>/owner/bookings"><i class="fas fa-calendar-check me-2"></i>Bookings</a>
            <a class="nav-link active" href="#"><i class="fas fa-star me-2"></i>Ratings & Reviews</a>
            <a class="nav-link" href="<%= request.getContextPath() %>/owner/revenue"><i class="fas fa-chart-line me-2"></i>Revenue</a>
            <hr>
            <a class="nav-link" href="<%= request.getContextPath() %>/owner/logout"><i class="fas fa-sign-out-alt me-2"></i>Logout</a>
          </nav>
        </div>
      </div>

      <!-- Main Content -->
      <main class="col-md-9 ms-sm-auto col-lg-10 px-md-4 py-4">
        <div class="d-flex justify-content-between flex-wrap flex-md-nowrap align-items-center pb-2 mb-3 border-bottom">
          <h1 class="h2">My Ratings & Reviews</h1>
        </div>

        <% Map<String, Object> stats = (Map<String, Object>) request.getAttribute("statistics"); %>
        
        <!-- Statistics Overview -->
        <div class="row mb-4">
          <div class="col-lg-8">
            <div class="stats-card">
              <div class="row">
                <div class="col-md-4 text-center">
                  <h3 class="mb-1"><%= stats.get("total_ratings") %></h3>
                  <p class="mb-0">Total Ratings Received</p>
                </div>
                <div class="col-md-4 text-center">
                  <h3 class="mb-1">
                    <% if ((Integer) stats.get("total_ratings") > 0) { %>
                      <%= String.format("%.1f", stats.get("average_rating")) %>
                    <% } else { %>
                      N/A
                    <% } %>
                  </h3>
                  <p class="mb-0">Average Rating</p>
                </div>
                <div class="col-md-4 text-center">
                  <div class="star-display">
                    <% 
                    if ((Integer) stats.get("total_ratings") > 0) {
                      double avgRating = (Double) stats.get("average_rating");
                      for (int i = 1; i <= 5; i++) {
                        if (i <= avgRating) {
                    %>
                          <i class="fas fa-star"></i>
                    <% } else if (i - 0.5 <= avgRating) { %>
                          <i class="fas fa-star-half-alt"></i>
                    <% } else { %>
                          <i class="far fa-star"></i>
                    <% } } } else { %>
                      <span class="text-muted">No ratings yet</span>
                    <% } %>
                  </div>
                </div>
              </div>
            </div>
          </div>
          
          <div class="col-lg-4">
            <div class="card">
              <div class="card-header">
                <h6 class="mb-0">Rating Distribution</h6>
              </div>
              <div class="card-body">
                <% 
                int totalRatings = (Integer) stats.get("total_ratings");
                if (totalRatings > 0) {
                  for (int star = 5; star >= 1; star--) {
                    int count = (Integer) stats.get(getStarKey(star));
                    double percentage = (count * 100.0) / totalRatings;
                %>
                <div class="d-flex align-items-center mb-2">
                  <span class="me-2"><%= star %> <i class="fas fa-star text-warning"></i></span>
                  <div class="rating-bar flex-grow-1 me-2">
                    <div class="rating-fill" style="width: <%= percentage %>%"></div>
                  </div>
                  <span class="text-muted"><%= count %></span>
                </div>
                <% } } else { %>
                <div class="text-center text-muted">
                  <i class="fas fa-star fa-2x mb-2"></i>
                  <p>No ratings received yet</p>
                </div>
                <% } %>
              </div>
            </div>
          </div>
        </div>

        <!-- Vehicle-wise Ratings -->
        <div class="row mb-4">
          <div class="col-12">
            <div class="card">
              <div class="card-header">
                <h5 class="mb-0"><i class="fas fa-car me-2"></i>Vehicle Performance</h5>
              </div>
              <div class="card-body">
                <% 
                List<Map<String, Object>> vehicleRatings = (List<Map<String, Object>>) request.getAttribute("vehicleRatings");
                if (vehicleRatings != null && !vehicleRatings.isEmpty()) {
                  for (Map<String, Object> vehicle : vehicleRatings) {
                %>
                <div class="vehicle-rating-card">
                  <div class="row align-items-center">
                    <div class="col-md-6">
                      <h6 class="mb-1"><%= vehicle.get("vehicle_name") %></h6>
                      <small class="text-muted"><%= vehicle.get("vehicle_model") %></small>
                    </div>
                    <div class="col-md-3 text-center">
                      <% if ((Integer) vehicle.get("rating_count") > 0) { %>
                        <div class="star-display">
                          <% 
                          double avgRating = (Double) vehicle.get("avg_rating");
                          for (int i = 1; i <= 5; i++) {
                            if (i <= avgRating) {
                          %>
                            <i class="fas fa-star"></i>
                          <% } else if (i - 0.5 <= avgRating) { %>
                            <i class="fas fa-star-half-alt"></i>
                          <% } else { %>
                            <i class="far fa-star"></i>
                          <% } } %>
                        </div>
                        <small class="text-muted"><%= String.format("%.1f", vehicle.get("avg_rating")) %>/5</small>
                      <% } else { %>
                        <span class="text-muted">No ratings</span>
                      <% } %>
                    </div>
                    <div class="col-md-3 text-end">
                      <span class="badge bg-primary"><%= vehicle.get("rating_count") %> ratings</span>
                    </div>
                  </div>
                </div>
                <% } } else { %>
                <div class="text-center py-3">
                  <p class="text-muted">No vehicles found</p>
                </div>
                <% } %>
              </div>
            </div>
          </div>
        </div>

        <!-- Individual Ratings -->
        <div class="card">
          <div class="card-header">
            <h5 class="mb-0"><i class="fas fa-comments me-2"></i>Customer Reviews</h5>
          </div>
          <div class="card-body">
            <% 
            List<Map<String, Object>> ratings = (List<Map<String, Object>>) request.getAttribute("ratings");
            SimpleDateFormat sdf = new SimpleDateFormat("MMM dd, yyyy 'at' hh:mm a");
            
            if (ratings != null && !ratings.isEmpty()) {
              for (Map<String, Object> rating : ratings) {
            %>
            <div class="rating-card">
              <div class="row">
                <div class="col-md-8">
                  <div class="d-flex align-items-start mb-2">
                    <div class="me-3">
                      <div class="star-display">
                        <% 
                        int ratingValue = (Integer) rating.get("rating");
                        for (int i = 1; i <= 5; i++) {
                          if (i <= ratingValue) {
                        %>
                          <i class="fas fa-star"></i>
                        <% } else { %>
                          <i class="far fa-star"></i>
                        <% } } %>
                      </div>
                      <small class="text-muted"><%= ratingValue %>/5</small>
                    </div>
                    <div class="flex-grow-1">
                      <h6 class="mb-1"><%= rating.get("vehicle_name") %> - <%= rating.get("vehicle_model") %></h6>
                      <p class="mb-1 text-muted">
                        <strong>Customer:</strong> <%= rating.get("user_name") %>
                      </p>
                      <% if (rating.get("review") != null && !rating.get("review").toString().trim().isEmpty()) { %>
                      <p class="mb-0">"<%= rating.get("review") %>"</p>
                      <% } else { %>
                      <p class="mb-0 text-muted fst-italic">No written review provided</p>
                      <% } %>
                    </div>
                  </div>
                </div>
                <div class="col-md-4 text-end">
                  <small class="text-muted">
                    <i class="fas fa-calendar me-1"></i>
                    <%= sdf.format(rating.get("rating_date")) %>
                  </small>
                  <br>
                  <small class="text-muted">
                    <i class="fas fa-receipt me-1"></i>
                    Booking #<%= rating.get("booking_id") %>
                  </small>
                </div>
              </div>
            </div>
            <% } } else { %>
            <div class="text-center py-5">
              <i class="fas fa-star fa-3x text-muted mb-3"></i>
              <h5 class="text-muted">No ratings received yet</h5>
              <p class="text-muted">Customer ratings and reviews will appear here once your vehicles are rented and rated.</p>
            </div>
            <% } %>
          </div>
        </div>
      </main>
    </div>
  </div>

  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>

<%!
private String getStarKey(int star) {
    switch (star) {
        case 1: return "one_star";
        case 2: return "two_star";
        case 3: return "three_star";
        case 4: return "four_star";
        case 5: return "five_star";
        default: return "one_star";
    }
}
%>
