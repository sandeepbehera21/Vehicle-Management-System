<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    HttpSession userSession = request.getSession(false);
    if (userSession == null || userSession.getAttribute("user_id") == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>My Profile - VehicleHub</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.2.0/css/all.min.css">
  <link rel="stylesheet" href="<%= request.getContextPath() %>/css/unified-style.css">
</head>
<body>
  <div class="container-fluid">
    <div class="row">
      <!-- Sidebar -->
      <div class="col-md-3 col-lg-2 p-0 sidebar">
        <div class="brand">
          <i class="fas fa-user me-2"></i>VehicleHub User
        </div>
        <div class="p-3">
          <nav class="nav flex-column">
            <a class="nav-link" href="<%= request.getContextPath() %>/user/dashboard">
              <i class="fas fa-tachometer-alt"></i>Dashboard
            </a>
            <a class="nav-link" href="<%= request.getContextPath() %>/user/book_vehicle">
              <i class="fas fa-car"></i>Book Vehicle
            </a>
            <a class="nav-link" href="<%= request.getContextPath() %>/user/my_trips">
              <i class="fas fa-history"></i>My Trips
            </a>
            <a class="nav-link active" href="<%= request.getContextPath() %>/user/profile">
              <i class="fas fa-user"></i>Profile
            </a>
            <a class="nav-link" href="<%= request.getContextPath() %>/user/payments">
              <i class="fas fa-credit-card"></i>Payments
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
          <h1 class="page-title"><i class="fas fa-user-circle me-2"></i>My Profile</h1>
        </div>

        <% if (request.getParameter("success") != null) { %>
          <div class="alert alert-success alert-dismissible fade show" role="alert">
            <i class="fas fa-check-circle me-2"></i>Profile updated successfully!
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
          </div>
        <% } %>

        <div class="row">
          <!-- Profile Information -->
          <div class="col-lg-8">
            <div class="content-card">
              <div class="profile-header">
                <div class="profile-avatar">
                  <i class="fas fa-user"></i>
                </div>
                <h3><%= request.getAttribute("name") %></h3>
                <p class="text-muted"><%= request.getAttribute("email") %></p>
                <small class="text-muted">Member since: <%= request.getAttribute("createdAt") != null ? request.getAttribute("createdAt").toString().substring(0, 10) : "N/A" %></small>
              </div>

              <h5 class="mb-3"><i class="fas fa-info-circle me-2"></i>Personal Information</h5>
              <div class="info-row">
                <div class="info-label"><i class="fas fa-id-card me-2"></i>User ID:</div>
                <div class="info-value"><%= request.getAttribute("userId") %></div>
              </div>
              <div class="info-row">
                <div class="info-label"><i class="fas fa-user me-2"></i>Full Name:</div>
                <div class="info-value"><%= request.getAttribute("name") %></div>
              </div>
              <div class="info-row">
                <div class="info-label"><i class="fas fa-envelope me-2"></i>Email:</div>
                <div class="info-value"><%= request.getAttribute("email") %></div>
              </div>
              <div class="info-row">
                <div class="info-label"><i class="fas fa-phone me-2"></i>Phone:</div>
                <div class="info-value"><%= request.getAttribute("phone") != null ? request.getAttribute("phone") : "Not provided" %></div>
              </div>
              <div class="info-row">
                <div class="info-label"><i class="fas fa-map-marker-alt me-2"></i>Address:</div>
                <div class="info-value"><%= request.getAttribute("address") != null ? request.getAttribute("address") : "Not provided" %></div>
              </div>

              <div class="text-center mt-4">
                <button class="btn btn-primary" data-bs-toggle="modal" data-bs-target="#editProfileModal">
                  <i class="fas fa-edit me-2"></i>Edit Profile
                </button>
              </div>
            </div>
          </div>

          <!-- Statistics -->
          <div class="col-lg-4">
            <div class="stat-card text-primary">
              <div class="label"><i class="fas fa-calendar-check me-2"></i>Total Bookings</div>
              <div class="value"><%= request.getAttribute("totalBookings") %></div>
            </div>
          </div>
        </div>

      </main>
    </div>
  </div>

  <!-- Edit Profile Modal -->
  <div class="modal fade" id="editProfileModal" tabindex="-1">
    <div class="modal-dialog">
      <div class="modal-content">
        <div class="modal-header">
          <h5 class="modal-title"><i class="fas fa-edit me-2"></i>Edit Profile</h5>
          <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
        </div>
        <form method="post" action="<%= request.getContextPath() %>/user/profile">
          <div class="modal-body">
            <div class="mb-3">
              <label class="form-label"><i class="fas fa-user me-2"></i>Full Name</label>
              <input type="text" class="form-control" name="name" value="<%= request.getAttribute("name") %>" required>
            </div>
            <div class="mb-3">
              <label class="form-label"><i class="fas fa-phone me-2"></i>Phone Number</label>
              <input type="tel" class="form-control" name="phone" value="<%= request.getAttribute("phone") != null ? request.getAttribute("phone") : "" %>">
            </div>
            <div class="mb-3">
              <label class="form-label"><i class="fas fa-map-marker-alt me-2"></i>Address</label>
              <textarea class="form-control" name="address" rows="3"><%= request.getAttribute("address") != null ? request.getAttribute("address") : "" %></textarea>
            </div>
            <div class="alert alert-info">
              <i class="fas fa-info-circle me-2"></i>Email cannot be changed. Contact admin if needed.
            </div>
          </div>
          <div class="modal-footer">
            <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
            <button type="submit" class="btn btn-primary">Save Changes</button>
          </div>
        </form>
      </div>
    </div>
  </div>

  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
