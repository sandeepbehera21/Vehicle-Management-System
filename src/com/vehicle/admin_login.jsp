<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>Admin Login - Vehicle Management</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.0.2/dist/css/bootstrap.min.css" rel="stylesheet">
  <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
  <style>
    body {
      background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
      min-height: 100vh;
      display: flex;
      align-items: center;
    }
    .login-card {
      background: rgba(255, 255, 255, 0.95);
      backdrop-filter: blur(10px);
      border-radius: 20px;
      box-shadow: 0 20px 40px rgba(0,0,0,0.1);
      border: 1px solid rgba(255, 255, 255, 0.2);
    }
    .admin-header {
      background: linear-gradient(45deg, #ff6b6b, #ee5a24);
      color: white;
      border-radius: 20px 20px 0 0;
      padding: 2rem;
      text-align: center;
    }
    .btn-admin {
      background: linear-gradient(45deg, #ff6b6b, #ee5a24);
      border: none;
      border-radius: 10px;
      padding: 12px;
      color: white;
      font-weight: 600;
      transition: all 0.3s ease;
    }
    .btn-admin:hover {
      background: linear-gradient(45deg, #ee5a24, #ff6b6b);
      color: white;
      transform: translateY(-2px);
      box-shadow: 0 8px 20px rgba(238, 90, 36, 0.3);
    }
    .form-control {
      border-radius: 10px;
      border: 2px solid #e9ecef;
      padding: 12px 15px;
      transition: all 0.3s ease;
    }
    .form-control:focus {
      border-color: #ff6b6b;
      box-shadow: 0 0 0 0.2rem rgba(255, 107, 107, 0.25);
    }
    .alert-custom {
      border-radius: 10px;
      border: none;
    }
  </style>
</head>
<body>
  <div class="container">
    <div class="row justify-content-center">
      <div class="col-md-6 col-lg-5">
        <div class="card login-card border-0">
          <div class="admin-header">
            <i class="fas fa-user-shield fa-3x mb-3"></i>
            <h3 class="mb-0">Admin Portal</h3>
            <p class="mb-0 mt-2 opacity-75">Vehicle Management System</p>
          </div>
          <div class="card-body p-4">
            <% if (request.getAttribute("error") != null) { %>
              <div class="alert alert-danger alert-custom">
                <i class="fas fa-exclamation-circle me-2"></i>
                <%= request.getAttribute("error") %>
              </div>
            <% } %>
            
            <form action="<%= request.getContextPath() %>/admin/login" method="POST">
              <div class="mb-4">
                <label class="form-label fw-bold">
                  <i class="fas fa-user me-2 text-muted"></i>Username
                </label>
                <input type="text" name="username" class="form-control" placeholder="Enter admin username" required>
              </div>
              
              <div class="mb-4">
                <label class="form-label fw-bold">
                  <i class="fas fa-lock me-2 text-muted"></i>Password
                </label>
                <input type="password" name="password" class="form-control" placeholder="Enter admin password" required>
              </div>
              
              <button type="submit" class="btn btn-admin w-100 mb-3">
                <i class="fas fa-sign-in-alt me-2"></i>Admin Login
              </button>
            </form>
            
            <div class="text-center mt-4 pt-3 border-top">
              <small class="text-muted">
                <i class="fas fa-info-circle me-1"></i>
                Default credentials: admin / admin123
              </small>
            </div>
            
            <div class="text-center mt-3">
              <a href="<%= request.getContextPath() %>/" class="text-decoration-none">
                <i class="fas fa-arrow-left me-1"></i>Back to Main Site
              </a>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
  
  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.0.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>