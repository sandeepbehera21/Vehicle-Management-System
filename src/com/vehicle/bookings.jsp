<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List,com.vehicle.BookingDetails" %>
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>Owner Bookings</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body>
<%
  response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
  if (session.getAttribute("owner_id") == null) {
    response.sendRedirect(request.getContextPath() + "/owner/login");
    return;
  }
  List<BookingDetails> bookings = (List<BookingDetails>) request.getAttribute("bookings");
%>

<nav class="navbar navbar-expand-lg navbar-dark bg-dark">
  <div class="container-fluid">
    <a class="navbar-brand" href="<%= request.getContextPath() %>/owner/dashboard">Owner Dashboard</a>
    <div class="collapse navbar-collapse">
      <ul class="navbar-nav me-auto">
        <li class="nav-item"><a class="nav-link" href="<%= request.getContextPath() %>/owner/dashboard">Dashboard</a></li>
        <li class="nav-item"><a class="nav-link" href="<%= request.getContextPath() %>/owner/vehicles">My Vehicles</a></li>
        <li class="nav-item"><a class="nav-link active" href="<%= request.getContextPath() %>/owner/bookings">Bookings</a></li>
      </ul>
      <a class="btn btn-outline-light" href="<%= request.getContextPath() %>/logout">Logout</a>
    </div>
  </div>
</nav>

<div class="container py-4">
  <h3 class="mb-3">Incoming Bookings</h3>

  <div class="table-responsive shadow-sm">
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
           for (BookingDetails b : bookings) { %>
        <tr>
          <td><%= b.getBooking_id() %></td>
          <td><%= b.getUser_name() %></td>
          <td><%= b.getVehicle_name() %></td>
          <td><%= b.getStart_date() %> to <%= b.getEnd_date() %></td>
          <td>$<%= String.format("%.2f", b.getTotal_amount()) %></td>
          <td>
            <span class="badge <%= "Approved".equals(b.getStatus())?"bg-success":("Pending".equals(b.getStatus())?"bg-warning text-dark":("Rejected".equals(b.getStatus())?"bg-danger":"bg-secondary")) %>"><%= b.getStatus() %></span>
          </td>
          <td class="text-end">
            <% if ("Pending".equals(b.getStatus())) { %>
            <form action="<%= request.getContextPath() %>/owner/update_booking_status" method="POST" class="d-inline">
              <input type="hidden" name="booking_id" value="<%= b.getBooking_id() %>">
              <button type="submit" name="action" value="Approved" class="btn btn-sm btn-success">Approve</button>
              <button type="submit" name="action" value="Rejected" class="btn btn-sm btn-danger">Reject</button>
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
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>