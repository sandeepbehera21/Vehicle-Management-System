<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.time.LocalDateTime,java.time.format.DateTimeFormatter" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Return Vehicle - VehicleHub</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.2.0/css/all.min.css">
  <style>
    :root {
      --primary-color: #6a11cb;
      --secondary-color: #2575fc;
      --light-gray: #f8f9fa;
    }
    body {
      background: linear-gradient(135deg, var(--primary-color), var(--secondary-color));
      min-height: 100vh;
    }
    .return-card {
      background: white;
      border-radius: 20px;
      box-shadow: 0 20px 40px rgba(0,0,0,0.1);
      overflow: hidden;
    }
    .vehicle-image {
      height: 250px;
      object-fit: cover;
      width: 100%;
    }
    .info-section {
      background: #f8f9fa;
      border-radius: 10px;
      padding: 20px;
      margin: 15px 0;
    }
    .fare-breakdown {
      background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
      color: white;
      border-radius: 15px;
      padding: 25px;
    }
    .amount-display {
      font-size: 2.5rem;
      font-weight: bold;
      color: #28a745;
    }
    .btn-proceed {
      background: linear-gradient(135deg, #28a745, #20c997);
      border: none;
      padding: 15px 40px;
      font-size: 1.2rem;
      font-weight: bold;
      border-radius: 50px;
      transition: all 0.3s ease;
    }
    .btn-proceed:hover {
      transform: translateY(-2px);
      box-shadow: 0 10px 20px rgba(40, 167, 69, 0.3);
    }
  </style>
</head>
<body>
  <div class="container py-5">
    <div class="row justify-content-center">
      <div class="col-lg-8">
        <div class="return-card">
          <div class="card-header bg-primary text-white text-center py-4">
            <h2 class="mb-0"><i class="fas fa-undo me-2"></i>Return Vehicle Confirmation</h2>
          </div>
          
          <div class="card-body p-4">
            <!-- Vehicle Information -->
            <div class="row mb-4">
              <div class="col-md-4">
                <% String imageUrl = (String) request.getAttribute("image_url"); %>
                <% if (imageUrl != null && !imageUrl.isEmpty()) { %>
                  <img src="<%= request.getContextPath() %>/uploads/<%= imageUrl %>" 
                       alt="<%= request.getAttribute("vehicle_name") %>" 
                       class="vehicle-image rounded">
                <% } else { %>
                  <div class="vehicle-image bg-light d-flex align-items-center justify-content-center rounded">
                    <i class="fas fa-car fa-4x text-muted"></i>
                  </div>
                <% } %>
              </div>
              <div class="col-md-8">
                <h3 class="text-primary"><%= request.getAttribute("vehicle_name") %></h3>
                <p class="text-muted mb-2"><%= request.getAttribute("vehicle_model") %> • <%= request.getAttribute("vehicle_type") %></p>
                <p class="mb-1"><strong>Owner:</strong> <%= request.getAttribute("owner_name") %> (<%= request.getAttribute("owner_phone") %>)</p>
              </div>
            </div>

            <!-- Trip Details -->
            <div class="info-section">
              <h5 class="text-primary mb-3"><i class="fas fa-route me-2"></i>Trip Details</h5>
              <div class="row">
                <div class="col-md-6">
                  <p><strong>Pickup Location:</strong><br><%= request.getAttribute("pickup_location") %></p>
                  <p><strong>Drop Location:</strong><br><%= request.getAttribute("drop_location") %></p>
                </div>
                <div class="col-md-6">
                  <p><strong>Booking Date:</strong><br><%= request.getAttribute("start_date") %> to <%= request.getAttribute("end_date") %></p>
                </div>
              </div>
            </div>

            <!-- Time Details -->
            <div class="info-section">
              <h5 class="text-primary mb-3"><i class="fas fa-clock me-2"></i>Time Details</h5>
              <div class="row">
                <div class="col-md-4">
                  <p><strong>Start Time:</strong><br>
                  <%= ((LocalDateTime) request.getAttribute("start_time")).format(DateTimeFormatter.ofPattern("dd MMM yyyy, hh:mm a")) %></p>
                </div>
                <div class="col-md-4">
                  <p><strong>Return Time:</strong><br>
                  <%= ((LocalDateTime) request.getAttribute("return_time")).format(DateTimeFormatter.ofPattern("dd MMM yyyy, hh:mm a")) %></p>
                </div>
                <div class="col-md-4">
                  <p><strong>Total Duration:</strong><br>
                  <span class="badge bg-info fs-6"><%= request.getAttribute("hours_used") %> hours</span></p>
                </div>
              </div>
            </div>

            <!-- Fare Breakdown -->
            <div class="fare-breakdown">
              <h5 class="mb-4"><i class="fas fa-calculator me-2"></i>Fare Breakdown</h5>
              
              <div class="row mb-3">
                <div class="col-8">Rent Charges (₹<%= String.format("%.0f", request.getAttribute("rent_per_hour")) %>/hour × <%= request.getAttribute("hours_used") %> hours)</div>
                <div class="col-4 text-end">₹<%= String.format("%.2f", request.getAttribute("total_fare")) %></div>
              </div>
              
              <% if ((Double) request.getAttribute("late_fee") > 0) { %>
              <div class="row mb-3">
                <div class="col-8">Late Fee (1.5x rate)</div>
                <div class="col-4 text-end text-warning">₹<%= String.format("%.2f", request.getAttribute("late_fee")) %></div>
              </div>
              <% } %>
              
              <div class="row mb-3">
                <div class="col-8">Security Deposit</div>
                <div class="col-4 text-end text-success">-₹<%= String.format("%.2f", request.getAttribute("security_deposit")) %></div>
              </div>
              
              <hr class="my-3" style="border-color: rgba(255,255,255,0.3);">
              
              <div class="row">
                <div class="col-8"><h5>Total Amount:</h5></div>
                <div class="col-4 text-end">
                  <h4 class="text-warning">₹<%= String.format("%.2f", (Double) request.getAttribute("final_amount") - (Double) request.getAttribute("security_deposit")) %></h4>
                </div>
              </div>
            </div>

            <!-- Action Buttons -->
            <div class="text-center mt-4">
              <form action="<%= request.getContextPath() %>/user/payment" method="POST" class="d-inline">
                <input type="hidden" name="booking_id" value="<%= request.getAttribute("booking_id") %>">
                <input type="hidden" name="vehicle_id" value="<%= request.getAttribute("vehicle_id") %>">
                <input type="hidden" name="rent_charges" value="<%= request.getAttribute("total_fare") %>">
                <input type="hidden" name="late_fee" value="<%= request.getAttribute("late_fee") %>">
                <input type="hidden" name="security_deposit" value="<%= request.getAttribute("security_deposit") %>">
                <input type="hidden" name="final_amount" value="<%= (Double) request.getAttribute("final_amount") - (Double) request.getAttribute("security_deposit") %>">
                <input type="hidden" name="hours_used" value="<%= request.getAttribute("hours_used") %>">
                
                <button type="submit" class="btn btn-success btn-proceed me-3">
                  <i class="fas fa-credit-card me-2"></i>Proceed to Payment
                </button>
              </form>
              
              <a href="<%= request.getContextPath() %>/user/my_trips" class="btn btn-outline-secondary btn-lg">
                <i class="fas fa-arrow-left me-2"></i>Back to My Trips
              </a>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>

  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
