<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List,com.vehicle.Booking" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>My Trips - VehicleHub</title>
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
  <div class="container-fluid">
    <div class="row">
      <!-- Sidebar -->
      <div class="col-md-3 col-lg-2 p-0 sidebar">
        <div class="p-3">
          <h4 class="text-center mb-4">User Menu</h4>
          <nav class="nav flex-column">
            <a class="nav-link" href="<%= request.getContextPath() %>/user/dashboard"><i class="fas fa-tachometer-alt me-2"></i>Dashboard</a>
            <a class="nav-link" href="<%= request.getContextPath() %>/user/book_vehicle"><i class="fas fa-car me-2"></i>Book Vehicle</a>
            <a class="nav-link active" href="<%= request.getContextPath() %>/user/my_trips"><i class="fas fa-history me-2"></i>My Trips</a>
            <a class="nav-link" href="<%= request.getContextPath() %>/user/profile"><i class="fas fa-user me-2"></i>Profile</a>
            <a class="nav-link" href="<%= request.getContextPath() %>/user/payments"><i class="fas fa-credit-card me-2"></i>Payments</a>
            <hr>
            <a class="nav-link" href="<%= request.getContextPath() %>/logout"><i class="fas fa-sign-out-alt me-2"></i>Logout</a>
          </nav>
        </div>
      </div>

      <!-- Main Content -->
      <main class="col-md-9 ms-sm-auto col-lg-10 px-md-4 py-4">
        <h1 class="h2 mb-4">My Trips</h1>

        <h3 class="h4 mb-3">Upcoming Trips</h3>
        <div class="table-responsive shadow-sm mb-5">
          <table class="table table-hover align-middle">
            <thead class="table-light">
              <tr>
                <th>Booking ID</th>
                <th>Vehicle</th>
                <th>Owner</th>
                <th>Dates</th>
                <th>Duration</th>
                <th>Route</th>
                <th>Fare</th>
                <th>Status</th>
                <th>Actions</th>
              </tr>
            </thead>
            <tbody>
            <% 
              List<Booking> upcomingTrips = (List<Booking>) request.getAttribute("upcomingTrips");
              if (upcomingTrips != null && !upcomingTrips.isEmpty()) {
                for (Booking trip : upcomingTrips) {
            %>
              <tr>
                <td><%= trip.getBooking_id() %></td>
                <td><%= trip.getVehicle_name() %></td>
                <td><%= trip.getOwner_name() %> (<%= trip.getOwner_phone() %>)</td>
                <td><%= trip.getStart_date() %> to <%= trip.getEnd_date() %></td>
                <td><%= trip.getDuration() %></td>
                <td><%= trip.getRoute() %></td>
                <td>₹<%= String.format("%.2f", trip.getTotal_amount()) %></td>
                <td>
                  <span class="badge <%= "Approved".equals(trip.getStatus())?"bg-success":("Ongoing".equals(trip.getStatus())?"bg-primary":("Pending".equals(trip.getStatus())?"bg-warning text-dark":("Rejected".equals(trip.getStatus())?"bg-danger":"bg-secondary"))) %>"><%= trip.getStatus() %></span>
                </td>
                <td>
                  <% if ("Pending".equals(trip.getStatus())) { %>
                    <form action="<%= request.getContextPath() %>/orders" method="POST" onsubmit="return confirm('Are you sure you want to cancel this booking?');">
                      <input type="hidden" name="booking_id" value="<%= trip.getBooking_id() %>">
                      <input type="hidden" name="vehicle_id" value="<%= trip.getVehicle_id() %>">
                      <button type="submit" class="btn btn-sm btn-danger">Cancel</button>
                    </form>
                  <% } else if ("Ongoing".equals(trip.getStatus()) || "Approved".equals(trip.getStatus())) { %>
                    <a href="<%= request.getContextPath() %>/user/return_vehicle?booking_id=<%= trip.getBooking_id() %>" class="btn btn-lg btn-success fw-bold">
                      <i class="fas fa-undo me-2"></i>Return Vehicle
                    </a>
                  <% } %>
                </td>
              </tr>
            <% 
                }
              } else { 
            %>
              <tr><td colspan="9" class="text-center">No upcoming trips.</td></tr>
            <% } %>
            </tbody>
          </table>
        </div>

        <h3 class="h4 mb-3">Past Trips</h3>
        <div class="table-responsive shadow-sm">
          <table class="table table-hover align-middle">
            <thead class="table-light">
              <tr>
                <th>Booking ID</th>
                <th>Vehicle</th>
                <th>Dates</th>
                <th>Total</th>
                <th>Status</th>
                <th>Rating</th>
                <th>Review</th>
                <th>Actions</th>
              </tr>
            </thead>
            <tbody>
            <% 
              List<Booking> pastTrips = (List<Booking>) request.getAttribute("pastTrips");
              if (pastTrips != null && !pastTrips.isEmpty()) {
                for (Booking trip : pastTrips) {
            %>
              <tr>
                <td><%= trip.getBooking_id() %></td>
                <td><%= trip.getVehicle_name() %></td>
                <td><%= trip.getStart_date() %> to <%= trip.getEnd_date() %></td>
                <td>₹<%= String.format("%.2f", trip.getTotal_amount()) %></td>
                <td>
                  <span class="badge bg-secondary"><%= trip.getStatus() %></span>
                </td>
                <td><%= trip.getRating() > 0 ? trip.getRating() : "N/A" %></td>
                <td><%= trip.getReview() != null ? trip.getReview() : "N/A" %></td>
                <td>
                  <% if (trip.getRating() == 0) { %>
                    <button type="button" class="btn btn-sm btn-outline-primary" data-bs-toggle="modal" data-bs-target="#rateReviewModal-<%= trip.getBooking_id() %>">
                      Rate & Review
                    </button>

                    <!-- Modal -->
                    <div class="modal fade" id="rateReviewModal-<%= trip.getBooking_id() %>" tabindex="-1" aria-labelledby="rateReviewModalLabel-<%= trip.getBooking_id() %>" aria-hidden="true">
                      <div class="modal-dialog">
                        <div class="modal-content">
                          <div class="modal-header">
                            <h5 class="modal-title" id="rateReviewModalLabel-<%= trip.getBooking_id() %>">Rate and Review: <%= trip.getVehicle_name() %></h5>
                            <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                          </div>
                          <div class="modal-body">
                            <form action="<%= request.getContextPath() %>/user/rate_review" method="POST">
                              <input type="hidden" name="booking_id" value="<%= trip.getBooking_id() %>">
                              <div class="mb-3">
                                <label for="rating-<%= trip.getBooking_id() %>" class="form-label">Rating (1-5)</label>
                                <input type="number" class="form-control" id="rating-<%= trip.getBooking_id() %>" name="rating" min="1" max="5" required>
                              </div>
                              <div class="mb-3">
                                <label for="review-<%= trip.getBooking_id() %>" class="form-label">Review</label>
                                <textarea class="form-control" id="review-<%= trip.getBooking_id() %>" name="review" rows="3" required></textarea>
                              </div>
                              <button type="submit" class="btn btn-primary">Submit</button>
                            </form>
                          </div>
                        </div>
                      </div>
                    </div>
                  <% } %>
                </td>
              </tr>
            <% 
                }
              } else { 
            %>
              <tr><td colspan="8" class="text-center">No past trips.</td></tr>
            <% } %>
            </tbody>
          </table>
        </div>

      </main>
    </div>
  </div>

  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
