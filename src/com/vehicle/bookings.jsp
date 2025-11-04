<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List,com.vehicle.Booking" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Bookings - VehicleHub</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.2.0/css/all.min.css">
  <link rel="stylesheet" href="<%= request.getContextPath() %>/css/unified-style.css">
</head>
<body>
<%
  response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
  if (session.getAttribute("owner_id") == null) {
    response.sendRedirect(request.getContextPath() + "/owner/login");
    return;
  }
  List<Booking> bookings = (List<Booking>) request.getAttribute("bookings");
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
            <a class="nav-link" href="<%= request.getContextPath() %>/owner/dashboard">
              <i class="fas fa-tachometer-alt"></i>Dashboard
            </a>
            <a class="nav-link" href="<%= request.getContextPath() %>/owner/vehicles">
              <i class="fas fa-car"></i>My Vehicles
            </a>
            <a class="nav-link active" href="<%= request.getContextPath() %>/owner/bookings">
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
            <a class="nav-link" href="<%= request.getContextPath() %>/logout">
              <i class="fas fa-sign-out-alt"></i>Logout
            </a>
          </nav>
        </div>
      </div>

      <!-- Main Content -->
      <main class="main-content">
        <div class="page-header">
          <h1 class="page-title"><i class="fas fa-calendar-check me-2"></i>Incoming Bookings</h1>
        </div>

        <div class="table-container">
    <table class="table table-hover align-middle">
      <thead class="table-light">
        <tr>
          <th>Booking ID</th>
          <th>User</th>
          <th>Vehicle</th>
          <th>Dates</th>
          <th>Total</th>
          <th>Status</th>
          <th class="text-end">Actions</th>
        </tr>
      </thead>
      <tbody>
      <% if (bookings != null && !bookings.isEmpty()) {
           for (Booking b : bookings) { %>
        <tr>
          <td><%= b.getBooking_id() %></td>
          <td><%= b.getUser_name() %></td>
          <td><%= b.getVehicle_name() %></td>
          <td><%= b.getStart_date() %> to <%= b.getEnd_date() %></td>
          <td>₹<%= String.format("%.2f", b.getTotal_amount()) %></td>
          <td>
            <span class="badge <%= "Approved".equals(b.getStatus())?"bg-success":("Pending".equals(b.getStatus())?"bg-warning text-dark":("Rejected".equals(b.getStatus())?"bg-danger":"bg-secondary")) %>"><%= b.getStatus() %></span>
          </td>
          <td class="text-end">
            <% if ("Pending".equals(b.getStatus())) { %>
            <form action="<%= request.getContextPath() %>/owner/update_booking_status" method="POST" class="d-inline">
              <input type="hidden" name="booking_id" value="<%= b.getBooking_id() %>">
              <button type="submit" name="action" value="Approved" class="btn btn-sm btn-success me-2">
                <i class="fas fa-check me-1"></i>Approve
              </button>
              <button type="submit" name="action" value="Rejected" class="btn btn-sm btn-danger">
                <i class="fas fa-times me-1"></i>Reject
              </button>
            </form>
            <% } %>
          </td>
        </tr>
      <% } } else { %>
        <tr><td colspan="7" class="text-center">No bookings found.</td></tr>
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