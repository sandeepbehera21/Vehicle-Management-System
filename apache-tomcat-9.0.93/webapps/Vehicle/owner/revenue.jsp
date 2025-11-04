<%@ page language="java" contentType="text/html; charset=ISO-8859-1" pageEncoding="ISO-8859-1"%>
<%@ page import="java.util.List" %>
<%@ page import="com.vehicle.OwnerRevenueServlet.RevenueRow" %>
<!DOCTYPE html>
<html>
<head>
  <meta charset="ISO-8859-1">
  <title>Owner Revenue</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.0.2/dist/css/bootstrap.min.css" rel="stylesheet">
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

<nav class="navbar navbar-expand-lg navbar-dark bg-dark">
  <div class="container-fluid">
    <a class="navbar-brand" href="<%= request.getContextPath() %>/owner/dashboard">MotorHub Owner</a>
    <div class="collapse navbar-collapse">
      <ul class="navbar-nav me-auto">
        <li class="nav-item"><a class="nav-link" href="<%= request.getContextPath() %>/owner/dashboard">Dashboard</a></li>
        <li class="nav-item"><a class="nav-link" href="<%= request.getContextPath() %>/owner/vehicles">My Vehicles</a></li>
        <li class="nav-item"><a class="nav-link" href="<%= request.getContextPath() %>/owner/bookings">Bookings</a></li>
        <li class="nav-item"><a class="nav-link active" href="<%= request.getContextPath() %>/owner/revenue">Revenue</a></li>
      </ul>
      <a class="btn btn-outline-light" href="<%= request.getContextPath() %>/owner/logout">Logout</a>
    </div>
  </div>
</nav>

<div class="container py-4">
  <div class="d-flex justify-content-between align-items-center mb-3">
    <h3>Revenue</h3>
    <form class="d-flex" method="GET" action="<%= request.getContextPath() %>/owner/revenue">
      <input type="date" class="form-control me-2" name="from" value="<%= from != null ? from : "" %>">
      <input type="date" class="form-control me-2" name="to" value="<%= to != null ? to : "" %>">
      <button class="btn btn-primary" type="submit">Filter</button>
    </form>
  </div>

  <div class="alert alert-info">Total Revenue: <strong>₹ <%= String.format("%.2f", total != null ? total : 0.0) %></strong></div>

  <div class="table-responsive shadow-sm">
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
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.0.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
