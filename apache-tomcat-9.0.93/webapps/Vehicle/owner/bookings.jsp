<%@ page language="java" contentType="text/html; charset=ISO-8859-1" pageEncoding="ISO-8859-1"%>
<%@ page import="java.util.List" %>
<%@ page import="com.vehicle.OwnerBookingsServlet.BookingRow" %>
<!DOCTYPE html>
<html>
<head>
  <meta charset="ISO-8859-1">
  <title>Owner Bookings</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.0.2/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body>
<%
  response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
  if (session.getAttribute("owner_id") == null) {
    response.sendRedirect(request.getContextPath() + "/owner/login");
    return;
  }
  List<BookingRow> bookings = (List<BookingRow>) request.getAttribute("bookings");
%>

<nav class="navbar navbar-expand-lg navbar-dark bg-dark">
  <div class="container-fluid">
    <a class="navbar-brand" href="<%= request.getContextPath() %>/owner/dashboard">MotorHub Owner</a>
    <div class="collapse navbar-collapse">
      <ul class="navbar-nav me-auto">
        <li class="nav-item"><a class="nav-link" href="<%= request.getContextPath() %>/owner/dashboard">Dashboard</a></li>
        <li class="nav-item"><a class="nav-link" href="<%= request.getContextPath() %>/owner/vehicles">My Vehicles</a></li>
        <li class="nav-item"><a class="nav-link active" href="<%= request.getContextPath() %>/owner/bookings">Bookings</a></li>
        <li class="nav-item"><a class="nav-link" href="<%= request.getContextPath() %>/owner/revenue">Revenue</a></li>
      </ul>
      <a class="btn btn-outline-light" href="<%= request.getContextPath() %>/owner/logout">Logout</a>
    </div>
  </div>
</nav>

<div class="container py-4">
  <h3 class="mb-3">Bookings</h3>

  <div class="table-responsive shadow-sm">
    <table class="table table-hover align-middle">
      <thead class="table-light">
        <tr>
          <th>Photo</th>
          <th>Vehicle</th>
          <th>Dates</th>
          <th>Total</th>
          <th>User</th>
          <th>Status</th>
          <th class="text-end">Actions</th>
        </tr>
      </thead>
      <tbody>
      <% if (bookings != null) {
           for (BookingRow b : bookings) { %>
        <tr>
          <td style="width:140px">
            <% if (b.imageUrl != null) { %>
              <img src="<%= b.imageUrl %>" class="img-thumbnail" style="max-height:80px;"/>
            <% } %>
          </td>
          <td>
            <div class="fw-semibold"><%= b.vehicleName %></div>
            <div class="text-muted small"><%= b.vehicleType %> • ID #<%= b.vehicleId %></div>
          </td>
          <td><%= b.startDate %> → <%= b.endDate %></td>
          <td>₹ <%= String.format("%.2f", b.totalAmount) %></td>
          <td>#<%= b.userId %></td>
          <td>
            <span class="badge <%= "Approved".equals(b.status)?"bg-success":("Pending".equals(b.status)?"bg-warning text-dark":("Rejected".equals(b.status)?"bg-danger":"bg-secondary")) %>"><%= b.status %></span>
          </td>
          <td class="text-end">
            <form action="<%= request.getContextPath() %>/owner/bookings/action" method="POST" class="d-inline">
              <input type="hidden" name="booking_id" value="<%= b.bookingId %>">
              <input type="hidden" name="vehicle_id" value="<%= b.vehicleId %>">
              <button name="action" value="approve" class="btn btn-sm btn-outline-success" <%= !"Pending".equals(b.status) ? "disabled" : "" %>>Approve</button>
            </form>
            <form action="<%= request.getContextPath() %>/owner/bookings/action" method="POST" class="d-inline">
              <input type="hidden" name="booking_id" value="<%= b.bookingId %>">
              <input type="hidden" name="vehicle_id" value="<%= b.vehicleId %>">
              <button name="action" value="reject" class="btn btn-sm btn-outline-danger" <%= !"Pending".equals(b.status) ? "disabled" : "" %>>Reject</button>
            </form>
            <form action="<%= request.getContextPath() %>/owner/bookings/action" method="POST" class="d-inline">
              <input type="hidden" name="booking_id" value="<%= b.bookingId %>">
              <input type="hidden" name="vehicle_id" value="<%= b.vehicleId %>">
              <button name="action" value="complete" class="btn btn-sm btn-outline-primary" <%= !"Approved".equals(b.status) ? "disabled" : "" %>>Complete</button>
            </form>
          </td>
        </tr>
      <% } } %>
      </tbody>
    </table>
  </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.0.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
