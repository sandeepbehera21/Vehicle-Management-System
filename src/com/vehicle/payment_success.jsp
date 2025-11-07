<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Payment Success - VehicleHub</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.2.0/css/all.min.css">
  <style>
    :root {
      --primary-color: #6a11cb;
      --secondary-color: #2575fc;
      --success-color: #28a745;
    }
    body {
      background: linear-gradient(135deg, var(--success-color), #20c997);
      min-height: 100vh;
    }
    .success-container {
      background: white;
      border-radius: 20px;
      box-shadow: 0 20px 40px rgba(0,0,0,0.1);
      overflow: hidden;
    }
    .success-header {
      background: linear-gradient(135deg, var(--success-color), #20c997);
      color: white;
      text-align: center;
      padding: 40px 20px;
    }
    .success-icon {
      font-size: 4rem;
      margin-bottom: 20px;
      animation: bounce 1s ease-in-out;
    }
    @keyframes bounce {
      0%, 20%, 50%, 80%, 100% { transform: translateY(0); }
      40% { transform: translateY(-10px); }
      60% { transform: translateY(-5px); }
    }
    .rating-section {
      background: #f8f9fa;
      border-radius: 15px;
      padding: 30px;
      margin: 20px 0;
    }
    .star-rating {
      font-size: 2rem;
      color: #ddd;
      cursor: pointer;
      transition: color 0.2s ease;
    }
    .star-rating.active,
    .star-rating:hover {
      color: #ffd700;
    }
    .btn-dashboard {
      background: linear-gradient(135deg, var(--primary-color), var(--secondary-color));
      border: none;
      padding: 15px 40px;
      font-size: 1.1rem;
      font-weight: bold;
      border-radius: 50px;
      color: white;
      transition: all 0.3s ease;
    }
    .btn-dashboard:hover {
      transform: translateY(-2px);
      box-shadow: 0 10px 20px rgba(106, 17, 203, 0.3);
      color: white;
    }
    .transaction-info {
      background: #e3f2fd;
      border-left: 4px solid #2196f3;
      padding: 15px;
      border-radius: 5px;
      margin: 20px 0;
    }
  </style>
</head>
<body>
  <div class="container py-5">
    <div class="row justify-content-center">
      <div class="col-lg-8">
        <div class="success-container">
          <!-- Success Header -->
          <div class="success-header">
            <div class="success-icon">
              <i class="fas fa-check-circle"></i>
            </div>
            <h2 class="mb-3">Payment Successful!</h2>
            <p class="mb-0 fs-5">Thank you! Your bike has been successfully returned & payment received.</p>
          </div>
          
          <div class="p-4">
            <!-- Transaction Details -->
            <div class="transaction-info">
              <div class="row">
                <div class="col-md-6">
                  <p class="mb-2"><strong>Transaction ID:</strong> <%= request.getAttribute("transaction_id") %></p>
                  <p class="mb-2"><strong>Vehicle:</strong> <%= request.getAttribute("vehicle_name") %></p>
                </div>
                <div class="col-md-6">
                  <p class="mb-2"><strong>Amount Paid:</strong> ₹<%= String.format("%.2f", request.getAttribute("final_amount")) %></p>
                  <p class="mb-2"><strong>Payment Method:</strong> <%= request.getAttribute("payment_method").equals("cash") ? "Cash on Delivery" : "Online Payment" %></p>
                </div>
              </div>
            </div>

            <!-- Rating Section -->
            <div class="rating-section">
              <h4 class="text-center mb-4"><i class="fas fa-star me-2"></i>Rate Your Experience</h4>
              
              <form id="ratingForm" action="<%= request.getContextPath() %>/user/submit_rating" method="POST">
                <input type="hidden" name="booking_id" value="<%= request.getAttribute("booking_id") %>">
                <input type="hidden" name="vehicle_id" value="<%= request.getAttribute("vehicle_id") %>">
                <input type="hidden" id="ratingValue" name="rating" value="0">
                
                <!-- Star Rating -->
                <div class="text-center mb-4">
                  <div class="star-container">
                    <i class="fas fa-star star-rating" data-rating="1"></i>
                    <i class="fas fa-star star-rating" data-rating="2"></i>
                    <i class="fas fa-star star-rating" data-rating="3"></i>
                    <i class="fas fa-star star-rating" data-rating="4"></i>
                    <i class="fas fa-star star-rating" data-rating="5"></i>
                  </div>
                  <p class="mt-2 text-muted" id="ratingText">Click to rate your experience</p>
                </div>
                
                <!-- Review Text -->
                <div class="mb-4">
                  <label for="review" class="form-label">Share your experience (optional)</label>
                  <textarea class="form-control" id="review" name="review" rows="4" 
                           placeholder="Tell us about your experience with this vehicle..."></textarea>
                </div>
                
                <!-- Submit Button -->
                <div class="text-center">
                  <button type="submit" class="btn btn-success btn-lg me-3" id="submitRating" disabled>
                    <i class="fas fa-paper-plane me-2"></i>Submit Rating
                  </button>
                  <button type="button" class="btn btn-outline-secondary btn-lg" onclick="skipRating()">
                    Skip for Now
                  </button>
                </div>
              </form>
            </div>

            <!-- Action Buttons -->
            <div class="text-center mt-4">
              <a href="<%= request.getContextPath() %>/user/my_trips" class="btn btn-dashboard me-3">
                <i class="fas fa-history me-2"></i>View My Trips
              </a>
              <a href="<%= request.getContextPath() %>/user/book_vehicle" class="btn btn-outline-primary btn-lg">
                <i class="fas fa-car me-2"></i>Book Another Vehicle
              </a>
            </div>

            <!-- Success Message -->
            <div class="alert alert-success mt-4" role="alert">
              <div class="d-flex align-items-center">
                <i class="fas fa-info-circle me-2"></i>
                <div>
                  <strong>Trip Duration:</strong> <%= request.getAttribute("hours_used") %> hours<br>
                  <strong>Status:</strong> Vehicle returned successfully and is now available for other users.
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
    let selectedRating = 0;
    const stars = document.querySelectorAll('.star-rating');
    const ratingText = document.getElementById('ratingText');
    const submitButton = document.getElementById('submitRating');
    const ratingValue = document.getElementById('ratingValue');

    const ratingTexts = {
      1: 'Poor - Not satisfied',
      2: 'Fair - Below expectations',
      3: 'Good - Met expectations',
      4: 'Very Good - Exceeded expectations',
      5: 'Excellent - Outstanding experience'
    };

    stars.forEach(star => {
      star.addEventListener('click', function() {
        selectedRating = parseInt(this.dataset.rating);
        updateStars();
        updateRatingText();
        enableSubmitButton();
      });

      star.addEventListener('mouseover', function() {
        const hoverRating = parseInt(this.dataset.rating);
        highlightStars(hoverRating);
      });
    });

    document.querySelector('.star-container').addEventListener('mouseleave', function() {
      updateStars();
    });

    function highlightStars(rating) {
      stars.forEach((star, index) => {
        if (index < rating) {
          star.classList.add('active');
        } else {
          star.classList.remove('active');
        }
      });
    }

    function updateStars() {
      highlightStars(selectedRating);
    }

    function updateRatingText() {
      if (selectedRating > 0) {
        ratingText.textContent = ratingTexts[selectedRating];
        ratingText.classList.remove('text-muted');
        ratingText.classList.add('text-primary', 'fw-bold');
      }
    }

    function enableSubmitButton() {
      if (selectedRating > 0) {
        submitButton.disabled = false;
        ratingValue.value = selectedRating;
      }
    }

    function skipRating() {
      window.location.href = '<%= request.getContextPath() %>/user/my_trips';
    }

    // Form submission
    document.getElementById('ratingForm').addEventListener('submit', function(e) {
      if (selectedRating === 0) {
        e.preventDefault();
        alert('Please select a rating before submitting.');
      }
    });
  </script>
</body>
</html>
