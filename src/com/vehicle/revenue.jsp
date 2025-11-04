<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="com.vehicle.OwnerRevenueServlet.RevenueRow" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Revenue - VehicleHub</title>
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
  List<RevenueRow> rows = (List<RevenueRow>) request.getAttribute("rows");
  Double total = (Double) request.getAttribute("total");
  String from = (String) request.getAttribute("from");
  String to = (String) request.getAttribute("to");
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
            <a class="nav-link" href="<%= request.getContextPath() %>/owner/bookings">
              <i class="fas fa-calendar-check"></i>Bookings
            </a>
            <a class="nav-link active" href="<%= request.getContextPath() %>/owner/revenue">
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
          <h1 class="page-title"><i class="fas fa-chart-line me-2"></i>Revenue</h1>
          <form class="d-flex" method="GET" action="<%= request.getContextPath() %>/owner/revenue">
            <input type="date" class="form-control me-2" name="from" value="<%= from != null ? from : "" %>" style="width: 150px;">
            <input type="date" class="form-control me-2" name="to" value="<%= to != null ? to : "" %>" style="width: 150px;">
            <button class="btn btn-primary" type="submit">
              <i class="fas fa-filter me-2"></i>Filter
            </button>
          </form>
        </div>

        <div class="stat-card text-success mb-4">
          <div class="label"><i class="fas fa-rupee-sign me-2"></i>Total Revenue</div>
          <div class="value">₹<%= String.format("%.2f", total != null ? total : 0.0) %></div>
        </div>

        <div class="table-container">
    <table class="table table-hover align-middle">
      <thead class="table-light">
        <tr>
          <th>Booking</th>
          <th>Vehicle</th>
          <th>Dates</th>
          <th>Total</th>
        </tr>
      </thead>
      <tbody>
      <% if (rows != null) {
           for (RevenueRow r : rows) { %>
        <tr>
          <td>#<%= r.bookingId %></td>
          <td><%= r.vehicleName %> (ID <%= r.vehicleId %>)</td>
          <td><%= r.startDate %> → <%= r.endDate %></td>
          <td>₹ <%= String.format("%.2f", r.totalAmount) %></td>
        </tr>
      <% } } %>
      </tbody>
        </table>
        </div>

      </main>
    </div>
  </div>

  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
