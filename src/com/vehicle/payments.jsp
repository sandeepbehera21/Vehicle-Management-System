<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="com.vehicle.UserPaymentsServlet.PaymentData" %>
<%
    HttpSession userSession = request.getSession(false);
    if (userSession == null || userSession.getAttribute("user_id") == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }
    List<PaymentData> payments = (List<PaymentData>) request.getAttribute("payments");
%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Payment History - VehicleHub</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.2.0/css/all.min.css">
  <style>
    :root {
      --primary-color: #6a11cb;
      --secondary-color: #2575fc;
      --light-gray: #f8f9fa;
      --success-color: #28a745;
      --danger-color: #dc3545;
      --warning-color: #ffc107;
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
    .stat-card {
      background: linear-gradient(135deg, var(--primary-color), var(--secondary-color));
      color: white;
      border-radius: 15px;
      padding: 25px;
      box-shadow: 0 5px 15px rgba(0,0,0,0.1);
      margin-bottom: 20px;
    }
    .stat-card h3 {
      font-size: 2rem;
      margin-bottom: 5px;
    }
    .stat-card p {
      margin: 0;
      opacity: 0.9;
    }
    .payment-table {
      background: white;
      border-radius: 15px;
      padding: 25px;
      box-shadow: 0 5px 15px rgba(0,0,0,0.05);
    }
    .status-badge {
      padding: 6px 12px;
      border-radius: 20px;
      font-size: 0.85rem;
      font-weight: 600;
      text-transform: uppercase;
    }
    .status-success {
      background-color: #d4edda;
      color: #155724;
    }
    .status-pending {
      background-color: #fff3cd;
      color: #856404;
    }
    .status-failed {
      background-color: #f8d7da;
      color: #721c24;
    }
    .status-refunded {
      background-color: #d1ecf1;
      color: #0c5460;
    }
    .table-hover tbody tr:hover {
      background-color: #f8f9fa;
      cursor: pointer;
    }
    .payment-method-icon {
      width: 40px;
      height: 40px;
      border-radius: 50%;
      background: linear-gradient(135deg, var(--primary-color), var(--secondary-color));
      color: white;
      display: inline-flex;
      align-items: center;
      justify-content: center;
      margin-right: 10px;
    }
    .empty-state {
      text-align: center;
      padding: 60px 20px;
      color: #999;
    }
    .empty-state i {
      font-size: 4rem;
      margin-bottom: 20px;
      color: #ddd;
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
            <a class="nav-link" href="<%= request.getContextPath() %>/user/my_trips"><i class="fas fa-history me-2"></i>My Trips</a>
            <a class="nav-link" href="<%= request.getContextPath() %>/user/profile"><i class="fas fa-user me-2"></i>Profile</a>
            <a class="nav-link active" href="<%= request.getContextPath() %>/user/payments"><i class="fas fa-credit-card me-2"></i>Payments</a>
            <hr>
            <a class="nav-link" href="<%= request.getContextPath() %>/logout"><i class="fas fa-sign-out-alt me-2"></i>Logout</a>
          </nav>
        </div>
      </div>

      <!-- Main Content -->
      <main class="col-md-9 ms-sm-auto col-lg-10 px-md-4 py-4">
        <h1 class="h2 mb-4"><i class="fas fa-credit-card me-2"></i>Payment History</h1>

        <!-- Payment Statistics -->
        <div class="row mb-4">
          <div class="col-md-3">
            <div class="stat-card">
              <h3><%= request.getAttribute("totalPayments") != null ? request.getAttribute("totalPayments") : 0 %></h3>
              <p><i class="fas fa-receipt me-2"></i>Total Transactions</p>
            </div>
          </div>
          <div class="col-md-3">
            <div class="stat-card" style="background: linear-gradient(135deg, #11998e, #38ef7d);">
              <h3>₹<%= String.format("%.2f", request.getAttribute("totalPaid") != null ? (Double)request.getAttribute("totalPaid") : 0.0) %></h3>
              <p><i class="fas fa-check-circle me-2"></i>Total Paid</p>
            </div>
          </div>
          <div class="col-md-3">
            <div class="stat-card" style="background: linear-gradient(135deg, #f093fb, #f5576c);">
              <h3>₹<%= String.format("%.2f", request.getAttribute("pendingAmount") != null ? (Double)request.getAttribute("pendingAmount") : 0.0) %></h3>
              <p><i class="fas fa-clock me-2"></i>Pending</p>
            </div>
          </div>
          <div class="col-md-3">
            <div class="stat-card" style="background: linear-gradient(135deg, #4facfe, #00f2fe);">
              <h3>₹<%= String.format("%.2f", request.getAttribute("refundedAmount") != null ? (Double)request.getAttribute("refundedAmount") : 0.0) %></h3>
              <p><i class="fas fa-undo me-2"></i>Refunded</p>
            </div>
          </div>
        </div>

        <!-- Transaction History Table -->
        <div class="payment-table">
          <h4 class="mb-4"><i class="fas fa-list me-2"></i>Transaction History</h4>
          
          <% if (payments != null && !payments.isEmpty()) { %>
            <div class="table-responsive">
              <table class="table table-hover align-middle">
                <thead class="table-light">
                  <tr>
                    <th>Transaction ID</th>
                    <th>Vehicle</th>
                    <th>Booking Period</th>
                    <th>Amount</th>
                    <th>Payment Method</th>
                    <th>Status</th>
                    <th>Date</th>
                    <th>Action</th>
                  </tr>
                </thead>
                <tbody>
                  <% for (PaymentData payment : payments) { %>
                    <tr>
                      <td>
                        <strong>#<%= payment.transactionId != null ? payment.transactionId : "TXN" + payment.paymentId %></strong>
                      </td>
                      <td>
                        <div>
                          <strong><%= payment.vehicleName %></strong><br>
                          <small class="text-muted"><%= payment.vehicleNumber %></small>
                        </div>
                      </td>
                      <td>
                        <small>
                          <%= payment.bookingStartDate != null ? payment.bookingStartDate.substring(0, 10) : "N/A" %><br>
                          to <%= payment.bookingEndDate != null ? payment.bookingEndDate.substring(0, 10) : "N/A" %>
                        </small>
                      </td>
                      <td>
                        <strong class="text-primary">₹<%= String.format("%.2f", payment.amount) %></strong>
                      </td>
                      <td>
                        <div class="d-flex align-items-center">
                          <div class="payment-method-icon">
                            <i class="fas fa-<%= 
                              payment.paymentMethod != null && payment.paymentMethod.equalsIgnoreCase("Card") ? "credit-card" :
                              payment.paymentMethod != null && payment.paymentMethod.equalsIgnoreCase("UPI") ? "mobile-alt" :
                              payment.paymentMethod != null && payment.paymentMethod.equalsIgnoreCase("Cash") ? "money-bill-wave" :
                              "wallet"
                            %>"></i>
                          </div>
                          <span><%= payment.paymentMethod != null ? payment.paymentMethod : "N/A" %></span>
                        </div>
                      </td>
                      <td>
                        <span class="status-badge <%= 
                          "Success".equalsIgnoreCase(payment.paymentStatus) ? "status-success" :
                          "Pending".equalsIgnoreCase(payment.paymentStatus) ? "status-pending" :
                          "Refunded".equalsIgnoreCase(payment.paymentStatus) ? "status-refunded" :
                          "status-failed"
                        %>">
                          <i class="fas fa-<%= 
                            "Success".equalsIgnoreCase(payment.paymentStatus) ? "check-circle" :
                            "Pending".equalsIgnoreCase(payment.paymentStatus) ? "clock" :
                            "Refunded".equalsIgnoreCase(payment.paymentStatus) ? "undo" :
                            "times-circle"
                          %> me-1"></i>
                          <%= payment.paymentStatus != null ? payment.paymentStatus : "Unknown" %>
                        </span>
                      </td>
                      <td>
                        <small><%= payment.paymentDate != null ? payment.paymentDate.substring(0, 16).replace("T", " ") : "N/A" %></small>
                      </td>
                      <td>
                        <button class="btn btn-sm btn-outline-primary" data-bs-toggle="modal" data-bs-target="#paymentModal<%= payment.paymentId %>">
                          <i class="fas fa-eye me-1"></i>View
                        </button>
                      </td>
                    </tr>

                    <!-- Payment Details Modal -->
                    <div class="modal fade" id="paymentModal<%= payment.paymentId %>" tabindex="-1">
                      <div class="modal-dialog">
                        <div class="modal-content">
                          <div class="modal-header">
                            <h5 class="modal-title"><i class="fas fa-receipt me-2"></i>Payment Details</h5>
                            <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                          </div>
                          <div class="modal-body">
                            <div class="row mb-3">
                              <div class="col-6"><strong>Transaction ID:</strong></div>
                              <div class="col-6">#<%= payment.transactionId != null ? payment.transactionId : "TXN" + payment.paymentId %></div>
                            </div>
                            <div class="row mb-3">
                              <div class="col-6"><strong>Booking ID:</strong></div>
                              <div class="col-6">#<%= payment.bookingId %></div>
                            </div>
                            <div class="row mb-3">
                              <div class="col-6"><strong>Vehicle:</strong></div>
                              <div class="col-6"><%= payment.vehicleName %> (<%= payment.vehicleNumber %>)</div>
                            </div>
                            <div class="row mb-3">
                              <div class="col-6"><strong>Amount:</strong></div>
                              <div class="col-6"><strong class="text-primary">₹<%= String.format("%.2f", payment.amount) %></strong></div>
                            </div>
                            <div class="row mb-3">
                              <div class="col-6"><strong>Payment Method:</strong></div>
                              <div class="col-6"><%= payment.paymentMethod != null ? payment.paymentMethod : "N/A" %></div>
                            </div>
                            <div class="row mb-3">
                              <div class="col-6"><strong>Status:</strong></div>
                              <div class="col-6">
                                <span class="status-badge <%= 
                                  "Success".equalsIgnoreCase(payment.paymentStatus) ? "status-success" :
                                  "Pending".equalsIgnoreCase(payment.paymentStatus) ? "status-pending" :
                                  "Refunded".equalsIgnoreCase(payment.paymentStatus) ? "status-refunded" :
                                  "status-failed"
                                %>">
                                  <%= payment.paymentStatus != null ? payment.paymentStatus : "Unknown" %>
                                </span>
                              </div>
                            </div>
                            <div class="row mb-3">
                              <div class="col-6"><strong>Payment Date:</strong></div>
                              <div class="col-6"><%= payment.paymentDate != null ? payment.paymentDate.substring(0, 16).replace("T", " ") : "N/A" %></div>
                            </div>
                            <div class="row mb-3">
                              <div class="col-6"><strong>Booking Period:</strong></div>
                              <div class="col-6">
                                <%= payment.bookingStartDate != null ? payment.bookingStartDate.substring(0, 10) : "N/A" %> to 
                                <%= payment.bookingEndDate != null ? payment.bookingEndDate.substring(0, 10) : "N/A" %>
                              </div>
                            </div>
                          </div>
                          <div class="modal-footer">
                            <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
                            <button type="button" class="btn btn-primary" onclick="window.print()">
                              <i class="fas fa-print me-1"></i>Print Receipt
                            </button>
                          </div>
                        </div>
                      </div>
                    </div>
                  <% } %>
                </tbody>
              </table>
            </div>
          <% } else { %>
            <div class="empty-state">
              <i class="fas fa-receipt"></i>
              <h4>No Payment History</h4>
              <p>You haven't made any payments yet. Book a vehicle to get started!</p>
              <a href="<%= request.getContextPath() %>/user/book_vehicle" class="btn btn-primary mt-3">
                <i class="fas fa-car me-2"></i>Book a Vehicle
              </a>
            </div>
          <% } %>
        </div>

      </main>
    </div>
  </div>

  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
