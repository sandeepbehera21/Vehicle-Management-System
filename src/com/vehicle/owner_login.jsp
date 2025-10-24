<%@ page language="java" contentType="text/html; charset=ISO-8859-1" pageEncoding="ISO-8859-1"%>
<!DOCTYPE html>
<html>
<head>
  <meta charset="ISO-8859-1">
  <title>Owner Login</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.0.2/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="bg-light">
  <div class="container d-flex align-items-center justify-content-center" style="min-height:100vh;">
    <div class="card shadow" style="max-width:420px; width:100%;">
      <div class="card-body p-4">
        <h3 class="mb-3 text-center">Owner Login</h3>
        <% if (request.getParameter("error") != null) { 
           String errorCode = request.getParameter("error");
           if ("2".equals(errorCode)) { %>
          <div class="alert alert-warning" role="alert">
            Your account is pending approval. Please contact the administrator.
          </div>
        <% } else { %>
          <div class="alert alert-danger" role="alert">
            Invalid email or password. Please try again.
          </div>
        <% } } %>
        <form action="<%= request.getContextPath() %>/owner/login" method="POST">
          <input type="hidden" name="next" value="<%= request.getParameter("next") != null ? request.getParameter("next") : "" %>">
          <div class="mb-3">
            <label class="form-label">Email</label>
            <input type="email" name="email" class="form-control" required>
          </div>
          <div class="mb-3">
            <label class="form-label">Password</label>
            <input type="password" name="password" class="form-control" required>
          </div>
          <button type="submit" class="btn btn-primary w-100">Login</button>
        </form>
        <hr/>
        <p class="text-center mb-0">New owner? <a href="<%= request.getContextPath() %>/owner/register">Register</a></p>
      </div>
    </div>
  </div>
  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.0.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
