<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Payment - VehicleHub</title>
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
    .payment-container {
      background: white;
      border-radius: 20px;
      box-shadow: 0 20px 40px rgba(0,0,0,0.1);
      overflow: hidden;
    }
    .payment-sidebar {
      background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
      color: white;
      padding: 30px;
    }
    .vehicle-summary {
      background: rgba(255,255,255,0.1);
      border-radius: 15px;
      padding: 20px;
      margin-bottom: 20px;
    }
    .payment-method {
      border: 2px solid #e9ecef;
      border-radius: 15px;
      padding: 20px;
      margin-bottom: 15px;
      cursor: pointer;
      transition: all 0.3s ease;
    }
    .payment-method:hover {
      border-color: var(--secondary-color);
      background-color: #f8f9ff;
    }
    .payment-method.selected {
      border-color: var(--secondary-color);
      background-color: #f8f9ff;
      box-shadow: 0 5px 15px rgba(37, 117, 252, 0.2);
    }
    .btn-pay {
      background: linear-gradient(135deg, #28a745, #20c997);
      border: none;
      padding: 15px 40px;
      font-size: 1.2rem;
      font-weight: bold;
      border-radius: 50px;
      width: 100%;
      transition: all 0.3s ease;
    }
    .btn-pay:hover {
      transform: translateY(-2px);
      box-shadow: 0 10px 20px rgba(40, 167, 69, 0.3);
    }
    .amount-display {
      font-size: 2.5rem;
      font-weight: bold;
      color: #ffd700;
    }
  </style>
</head>
<body>
  <div class="container py-5">
    <div class="row justify-content-center">
      <div class="col-lg-10">
        <div class="payment-container">
          <div class="row g-0">
            <!-- Payment Sidebar -->
            <div class="col-lg-5 payment-sidebar">
              <h3 class="mb-4"><i class="fas fa-receipt me-2"></i>Payment Summary</h3>
              
              <!-- Vehicle Summary -->
              <div class="vehicle-summary">
                <div class="d-flex align-items-center mb-3">
                  <% String imageUrl = (String) request.getAttribute("image_url"); %>
                  <% if (imageUrl != null && !imageUrl.isEmpty()) { %>
                    <img src="<%= request.getContextPath() %>/uploads/<%= imageUrl %>" 
                         alt="<%= request.getAttribute("vehicle_name") %>" 
                         class="rounded me-3" style="width: 60px; height: 60px; object-fit: cover;">
                  <% } else { %>
                    <div class="bg-light rounded me-3 d-flex align-items-center justify-content-center" 
                         style="width: 60px; height: 60px;">
                      <i class="fas fa-car text-muted"></i>
                    </div>
                  <% } %>
                  <div>
                    <h6 class="mb-1"><%= request.getAttribute("vehicle_name") %></h6>
                    <small class="opacity-75"><%= request.getAttribute("vehicle_model") %></small>
                  </div>
                </div>
                <p class="mb-0"><strong>Owner:</strong> <%= request.getAttribute("owner_name") %></p>
              </div>

              <!-- Breakdown -->
              <div class="mb-4">
                <h5 class="mb-3">Breakdown</h5>
                
                <div class="d-flex justify-content-between mb-2">
                  <span>Rent Charges (<%= request.getAttribute("hours_used") %> hours)</span>
                  <span>₹<%= String.format("%.2f", request.getAttribute("rent_charges")) %></span>
                </div>
                
                <% if ((Double) request.getAttribute("late_fee") > 0) { %>
                <div class="d-flex justify-content-between mb-2">
                  <span>Late Fee</span>
                  <span class="text-warning">₹<%= String.format("%.2f", request.getAttribute("late_fee")) %></span>
                </div>
                <% } %>
                
                <div class="d-flex justify-content-between mb-2">
                  <span>Security Deposit Adjustment</span>
                  <span class="text-success">-₹<%= String.format("%.2f", request.getAttribute("security_deposit")) %></span>
                </div>
                
                <hr style="border-color: rgba(255,255,255,0.3);">
                
                <div class="d-flex justify-content-between">
                  <h5>Total Amount:</h5>
                  <div class="amount-display">₹<%= String.format("%.2f", request.getAttribute("final_amount")) %></div>
                </div>
              </div>
            </div>

            <!-- Payment Methods -->
            <div class="col-lg-7 p-4">
              <h3 class="mb-4 text-primary"><i class="fas fa-credit-card me-2"></i>Choose Payment Method</h3>
              
              <form id="paymentForm" action="<%= request.getContextPath() %>/user/process_payment" method="POST">
                <input type="hidden" name="booking_id" value="<%= request.getAttribute("booking_id") %>">
                <input type="hidden" name="vehicle_id" value="<%= request.getAttribute("vehicle_id") %>">
                <input type="hidden" name="rent_charges" value="<%= request.getAttribute("rent_charges") %>">
                <input type="hidden" name="late_fee" value="<%= request.getAttribute("late_fee") %>">
                <input type="hidden" name="security_deposit" value="<%= request.getAttribute("security_deposit") %>">
                <input type="hidden" name="final_amount" value="<%= request.getAttribute("final_amount") %>">
                <input type="hidden" name="hours_used" value="<%= request.getAttribute("hours_used") %>">
                
                <!-- Cash Payment -->
                <div class="payment-method" onclick="selectPaymentMethod('cash', this)">
                  <input type="radio" name="payment_method" value="cash" id="cash" class="d-none">
                  <div class="d-flex align-items-center">
                    <div class="me-3">
                      <i class="fas fa-money-bill-wave fa-2x text-success"></i>
                    </div>
                    <div class="flex-grow-1">
                      <h5 class="mb-1">Cash on Delivery</h5>
                      <p class="text-muted mb-0">Pay cash when you return the vehicle</p>
                    </div>
                    <div>
                      <i class="fas fa-check-circle text-success d-none"></i>
                    </div>
                  </div>
                </div>

                <!-- Online Payment -->
                <div class="payment-method" onclick="selectPaymentMethod('online', this)">
                  <input type="radio" name="payment_method" value="online" id="online" class="d-none">
                  <div class="d-flex align-items-center">
                    <div class="me-3">
                      <i class="fas fa-credit-card fa-2x text-primary"></i>
                    </div>
                    <div class="flex-grow-1">
                      <h5 class="mb-1">Pay Now</h5>
                      <p class="text-muted mb-0">Secure online payment via UPI/Card/Net Banking</p>
                    </div>
                    <div>
                      <i class="fas fa-check-circle text-success d-none"></i>
                    </div>
                  </div>
                </div>

                <!-- Payment Buttons -->
                <div class="mt-4">
                  <button type="submit" class="btn btn-success btn-pay mb-3" id="payButton" disabled>
                    <i class="fas fa-lock me-2"></i>Complete Payment
                  </button>
                  
                  <div class="text-center">
                    <a href="<%= request.getContextPath() %>/user/return_vehicle?booking_id=<%= request.getAttribute("booking_id") %>" 
                       class="btn btn-outline-secondary">
                      <i class="fas fa-arrow-left me-2"></i>Back to Return Confirmation
                    </a>
                  </div>
                </div>
              </form>

              <!-- Security Info -->
              <div class="mt-4 p-3 bg-light rounded">
                <div class="d-flex align-items-center">
                  <i class="fas fa-shield-alt text-success me-2"></i>
                  <small class="text-muted">Your payment is secured with 256-bit SSL encryption</small>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>

  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
  <script>
    function selectPaymentMethod(method, element) {
      // Remove selected class from all methods
      document.querySelectorAll('.payment-method').forEach(el => {
        el.classList.remove('selected');
        el.querySelector('.fas.fa-check-circle').classList.add('d-none');
      });
      
      // Add selected class to clicked method
      element.classList.add('selected');
      element.querySelector('.fas.fa-check-circle').classList.remove('d-none');
      
      // Check the radio button
      document.getElementById(method).checked = true;
      
      // Enable pay button
      document.getElementById('payButton').disabled = false;
      
      // Update button text based on method
      const payButton = document.getElementById('payButton');
      if (method === 'cash') {
        payButton.innerHTML = '<i class="fas fa-handshake me-2"></i>Confirm Cash Payment';
      } else {
        payButton.innerHTML = '<i class="fas fa-credit-card me-2"></i>Pay Now';
      }
    }
  </script>
</body>
</html>
