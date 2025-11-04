<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>Vehicle Management System</title>
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
  <style>
    body {
      min-height: 100vh;
      background: linear-gradient(135deg, #6a11cb 0%, #2575fc 100%);
      color: #fff;
    }
    .hero {
      padding: 48px 0 24px;
      text-align: center;
    }
    .hero h1 { font-weight: 800; font-size: 2.5rem; }
    .hero small { opacity: .85; }
    .card { border: none; border-radius: 1rem; box-shadow: 0 1rem 2rem rgba(0,0,0,.15); }
    .card h4 { color: #1f2d3d; }
    .badge-note { font-size: .8rem; opacity: .8; }
    .features .card { background: rgba(255,255,255,.06); color: #f8f9fa; }
    .features .card h6 { color: #fff; }
    a.btn { text-decoration: none; }
  </style>
</head>
<body>
<%
  String base = request.getContextPath();
  String now = new java.text.SimpleDateFormat("EEE MMM dd HH:mm:ss z yyyy").format(new java.util.Date());
%>

<div class="container py-4">
  <div class="hero">
    <h1>🚗 Vehicle Management System</h1>
    <p class="mb-1">Your Complete Solution for Vehicle Rental Management</p>
    <small>Current Time: <%= now %></small>
  </div>

  <!-- Three panels -->
  <div class="row g-4 justify-content-center">
    <div class="col-12 col-md-6 col-lg-4">
      <div class="card p-4 h-100">
        <h4 class="mb-2">For Users</h4>
        <p class="text-muted">Browse and rent vehicles easily. Create your account and start booking today!</p>
        <div class="mt-3 d-flex gap-2">
          <a class="btn btn-primary" href="<%= base %>/login">User Login</a>
          <a class="btn btn-outline-primary" href="<%= base %>/register">Register Now</a>
        </div>
      </div>
    </div>
    <div class="col-12 col-md-6 col-lg-4">
      <div class="card p-4 h-100">
        <h4 class="mb-2">For Owners</h4>
        <p class="text-muted">List your vehicles and earn money. Manage your fleet efficiently.</p>
        <div class="mt-3 d-flex gap-2">
          <a class="btn btn-success" href="<%= base %>/owner/login">Owner Login</a>
          <a class="btn btn-outline-success" href="<%= base %>/owner/register">Become an Owner</a>
        </div>
      </div>
    </div>
    <div class="col-12 col-md-6 col-lg-4">
      <div class="card p-4 h-100">
        <h4 class="mb-2">Admin Panel</h4>
        <p class="text-muted">Complete system administration and management dashboard.</p>
        <div class="mt-3 d-flex gap-2">
          <a class="btn btn-info text-white" href="<%= base %>/admin/login">Admin Login</a>
        </div>
        <div class="mt-2 badge-note text-muted">Login: admin / admin</div>
      </div>
    </div>
  </div>

  <!-- Features (light) -->
  <div class="features mt-5">
    <div class="row g-3">
      <div class="col-6 col-md-3">
        <div class="card p-3 h-100"><h6>Vehicle Management</h6><p class="mb-0">Browse, search, and manage a wide variety of vehicles</p></div>
      </div>
      <div class="col-6 col-md-3">
        <div class="card p-3 h-100"><h6>Easy Booking</h6><p class="mb-0">Simple booking process for users</p></div>
      </div>
      <div class="col-6 col-md-3">
        <div class="card p-3 h-100"><h6>Owner Portal</h6><p class="mb-0">Tools for vehicle owners</p></div>
      </div>
      <div class="col-6 col-md-3">
        <div class="card p-3 h-100"><h6>Admin Dashboard</h6><p class="mb-0">Oversight and analytics</p></div>
      </div>
    </div>
  </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
