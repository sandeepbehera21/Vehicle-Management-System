<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%@ page import="com.vehicle.AdminUsersServlet.UserData" %>
<%
    HttpSession userSession = request.getSession(false);
    if (userSession == null || userSession.getAttribute("admin_id") == null) {
        response.sendRedirect(request.getContextPath() + "/admin/login");
        return;
    }
    
    List<UserData> users = (List<UserData>) request.getAttribute("users");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>User Management - Admin Panel</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
        }
        
        .container {
            max-width: 1400px;
            margin: 0 auto;
            padding: 20px;
        }
        
        .header {
            background: rgba(255, 255, 255, 0.95);
            backdrop-filter: blur(10px);
            border-radius: 20px;
            padding: 30px;
            margin-bottom: 30px;
            box-shadow: 0 8px 32px rgba(31, 38, 135, 0.37);
            border: 1px solid rgba(255, 255, 255, 0.18);
        }
        
        .header-content {
            display: flex;
            justify-content: space-between;
            align-items: center;
            flex-wrap: wrap;
            gap: 20px;
        }
        
        .header h1 {
            color: #333;
            font-size: 2.5em;
            font-weight: 700;
            display: flex;
            align-items: center;
            gap: 15px;
        }
        
        .nav-buttons {
            display: flex;
            gap: 15px;
            flex-wrap: wrap;
        }
        
        .btn {
            padding: 12px 24px;
            border: none;
            border-radius: 10px;
            text-decoration: none;
            font-weight: 600;
            transition: all 0.3s ease;
            cursor: pointer;
            display: inline-flex;
            align-items: center;
            gap: 8px;
        }
        
        .btn-primary {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
        }
        
        .btn-primary:hover {
            transform: translateY(-2px);
            box-shadow: 0 5px 15px rgba(102, 126, 234, 0.4);
        }
        
        .btn-secondary {
            background: rgba(255, 255, 255, 0.2);
            color: #333;
            border: 1px solid rgba(0, 0, 0, 0.1);
        }
        
        .btn-secondary:hover {
            background: rgba(255, 255, 255, 0.3);
            transform: translateY(-2px);
        }
        
        .content-card {
            background: rgba(255, 255, 255, 0.95);
            backdrop-filter: blur(10px);
            border-radius: 20px;
            padding: 40px;
            box-shadow: 0 8px 32px rgba(31, 38, 135, 0.37);
            border: 1px solid rgba(255, 255, 255, 0.18);
        }
        
        .users-grid {
            display: grid;
            gap: 20px;
            grid-template-columns: repeat(auto-fill, minmax(400px, 1fr));
            margin-bottom: 30px;
        }
        
        .user-card {
            background: linear-gradient(135deg, #f5f7fa 0%, #c3cfe2 100%);
            border-radius: 15px;
            padding: 25px;
            border: 2px solid transparent;
            transition: all 0.3s ease;
            position: relative;
        }
        
        .user-card:hover {
            border-color: #667eea;
            transform: translateY(-5px);
            box-shadow: 0 10px 25px rgba(102, 126, 234, 0.3);
        }
        
        .user-header {
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
            margin-bottom: 20px;
        }
        
        .user-info h3 {
            color: #333;
            font-size: 1.5em;
            margin-bottom: 8px;
        }
        
        .user-info p {
            color: #666;
            font-size: 0.95em;
            margin: 3px 0;
        }
        
        .approval-badge {
            padding: 8px 16px;
            border-radius: 25px;
            font-size: 0.85em;
            font-weight: 600;
            text-transform: uppercase;
        }
        
        .approval-approved {
            background: #d4edda;
            color: #155724;
        }
        
        .approval-pending {
            background: #fff3cd;
            color: #856404;
        }
        
        .user-details {
            margin: 20px 0;
        }
        
        .detail-row {
            display: flex;
            justify-content: space-between;
            margin: 12px 0;
            padding: 10px 0;
            border-bottom: 1px solid rgba(0,0,0,0.1);
        }
        
        .detail-label {
            font-weight: 600;
            color: #555;
        }
        
        .detail-value {
            color: #333;
            text-align: right;
        }
        
        .stats-section {
            background: rgba(255, 255, 255, 0.8);
            padding: 15px;
            border-radius: 10px;
            margin-bottom: 20px;
        }
        
        .stats-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 15px;
        }
        
        .stat-item {
            text-align: center;
            padding: 10px;
        }
        
        .stat-number {
            font-size: 1.8em;
            font-weight: 700;
            color: #667eea;
            margin-bottom: 5px;
        }
        
        .stat-label {
            font-size: 0.9em;
            color: #666;
        }
        
        .actions {
            display: flex;
            gap: 10px;
            flex-wrap: wrap;
            margin-top: 20px;
        }
        
        .btn-sm {
            padding: 8px 16px;
            font-size: 0.85em;
        }
        
        .btn-success {
            background: #28a745;
            color: white;
        }
        
        .btn-warning {
            background: #ffc107;
            color: #212529;
        }
        
        .btn-danger {
            background: #dc3545;
            color: white;
        }
        
        .btn-info {
            background: #17a2b8;
            color: white;
        }
        
        .summary-stats {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 20px;
            margin-bottom: 30px;
        }
        
        .summary-card {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 25px;
            border-radius: 15px;
            text-align: center;
        }
        
        .summary-number {
            font-size: 2.2em;
            font-weight: 700;
            margin-bottom: 8px;
        }
        
        .summary-label {
            font-size: 1em;
            opacity: 0.9;
        }
        
        .empty-state {
            text-align: center;
            padding: 60px 20px;
            color: #666;
        }
        
        .empty-state h3 {
            font-size: 1.5em;
            margin-bottom: 10px;
        }
        
        .filter-tabs {
            display: flex;
            gap: 10px;
            margin-bottom: 30px;
            flex-wrap: wrap;
        }
        
        .filter-tab {
            padding: 10px 20px;
            border: 2px solid #667eea;
            background: transparent;
            color: #667eea;
            border-radius: 25px;
            cursor: pointer;
            transition: all 0.3s ease;
        }
        
        .filter-tab.active,
        .filter-tab:hover {
            background: #667eea;
            color: white;
        }
        
        .activity-indicator {
            position: absolute;
            top: 15px;
            right: 15px;
            width: 12px;
            height: 12px;
            border-radius: 50%;
        }
        
        .activity-active {
            background: #28a745;
            box-shadow: 0 0 10px rgba(40, 167, 69, 0.5);
        }
        
        .activity-inactive {
            background: #dc3545;
        }
        
        @media (max-width: 768px) {
            .users-grid {
                grid-template-columns: 1fr;
            }
            
            .header-content {
                flex-direction: column;
                text-align: center;
            }
            
            .header h1 {
                font-size: 2em;
            }
            
            .stats-grid {
                grid-template-columns: 1fr;
            }
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <div class="header-content">
                <h1>👤 User Management</h1>
                <div class="nav-buttons">
                    <a href="<%= request.getContextPath() %>/admin/dashboard" class="btn btn-secondary">← Back to Dashboard</a>
                    <a href="<%= request.getContextPath() %>/admin/logout" class="btn btn-primary">Logout</a>
                </div>
            </div>
        </div>

        <div class="content-card">
            <% if (users != null && !users.isEmpty()) { %>
                <!-- Summary Statistics -->
                <div class="summary-stats">
                    <%
                        int totalUsers = users.size();
                        int approvedUsers = 0;
                        int pendingUsers = 0;
                        int activeUsers = 0;
                        double totalRevenue = 0;
                        
                        for (UserData u : users) {
                            if (u.approved) {
                                approvedUsers++;
                            } else {
                                pendingUsers++;
                            }
                            if (u.totalBookings > 0) {
                                activeUsers++;
                            }
                            totalRevenue += u.totalSpent;
                        }
                    %>
                    <div class="summary-card">
                        <div class="summary-number"><%= totalUsers %></div>
                        <div class="summary-label">Total Users</div>
                    </div>
                    <div class="summary-card">
                        <div class="summary-number"><%= approvedUsers %></div>
                        <div class="summary-label">Approved</div>
                    </div>
                    <div class="summary-card">
                        <div class="summary-number"><%= activeUsers %></div>
                        <div class="summary-label">Active Users</div>
                    </div>
                    <div class="summary-card">
                        <div class="summary-number">₹<%= String.format("%.0f", totalRevenue) %></div>
                        <div class="summary-label">Total Revenue</div>
                    </div>
                </div>

                <!-- Filter Tabs -->
                <div class="filter-tabs">
                    <button class="filter-tab active" onclick="filterUsers('all')">All Users</button>
                    <button class="filter-tab" onclick="filterUsers('approved')">Approved</button>
                    <button class="filter-tab" onclick="filterUsers('pending')">Pending Approval</button>
                    <button class="filter-tab" onclick="filterUsers('active')">Active Users</button>
                </div>

                <!-- Users Grid -->
                <div class="users-grid" id="usersGrid">
                    <% for (UserData user : users) { %>
                        <div class="user-card" data-status="<%= user.approved ? "approved" : "pending" %>" data-activity="<%= user.totalBookings > 0 ? "active" : "inactive" %>">
                            <!-- Activity Indicator -->
                            <div class="activity-indicator <%= user.totalBookings > 0 ? "activity-active" : "activity-inactive" %>"></div>
                            
                            <div class="user-header">
                                <div class="user-info">
                                    <h3><%= user.name %></h3>
                                    <p><strong>📧</strong> <%= user.email %></p>
                                    <p><strong>📱</strong> <%= user.phone != null ? user.phone : "Not provided" %></p>
                                </div>
                                <div class="approval-badge <%= user.approved ? "approval-approved" : "approval-pending" %>">
                                    <%= user.approved ? "Approved" : "Pending" %>
                                </div>
                            </div>

                            <% if (user.address != null && !user.address.trim().isEmpty()) { %>
                                <div class="user-details">
                                    <div class="detail-row">
                                        <span class="detail-label">📍 Address:</span>
                                        <span class="detail-value"><%= user.address %></span>
                                    </div>
                                </div>
                            <% } %>

                            <div class="stats-section">
                                <div class="stats-grid">
                                    <div class="stat-item">
                                        <div class="stat-number"><%= user.totalBookings %></div>
                                        <div class="stat-label">Total Bookings</div>
                                    </div>
                                    <div class="stat-item">
                                        <div class="stat-number">₹<%= String.format("%.0f", user.totalSpent) %></div>
                                        <div class="stat-label">Total Spent</div>
                                    </div>
                                </div>
                            </div>

                            <div class="user-details">
                                <div class="detail-row">
                                    <span class="detail-label">Member Since:</span>
                                    <span class="detail-value"><%= user.createdAt != null ? user.createdAt.substring(0, 10) : "N/A" %></span>
                                </div>
                                <% if (user.lastBookingDate != null) { %>
                                <div class="detail-row">
                                    <span class="detail-label">Last Booking:</span>
                                    <span class="detail-value"><%= user.lastBookingDate.substring(0, 10) %></span>
                                </div>
                                <% } %>
                            </div>

                            <div class="actions">
                                <% if (!user.approved) { %>
                                    <form method="post" style="display: inline;">
                                        <input type="hidden" name="user_id" value="<%= user.userId %>">
                                        <input type="hidden" name="action" value="approve">
                                        <button type="submit" class="btn btn-success btn-sm">✓ Approve</button>
                                    </form>
                                <% } else { %>
                                    <form method="post" style="display: inline;">
                                        <input type="hidden" name="user_id" value="<%= user.userId %>">
                                        <input type="hidden" name="action" value="disapprove">
                                        <button type="submit" class="btn btn-warning btn-sm">⚠ Revoke Approval</button>
                                    </form>
                                <% } %>
                                
                                <button class="btn btn-info btn-sm" onclick="contactUser('<%= user.email %>')">✉ Contact</button>
                                
                                <form method="post" style="display: inline;" onsubmit="return confirm('Are you sure you want to delete this user and all their bookings?')">
                                    <input type="hidden" name="user_id" value="<%= user.userId %>">
                                    <input type="hidden" name="action" value="delete">
                                    <button type="submit" class="btn btn-danger btn-sm">🗑 Delete</button>
                                </form>
                            </div>
                        </div>
                    <% } %>
                </div>
            <% } else { %>
                <div class="empty-state">
                    <h3>No Users Found</h3>
                    <p>There are currently no users in the system.</p>
                </div>
            <% } %>
        </div>
    </div>

    <script>
        function filterUsers(status) {
            const cards = document.querySelectorAll('.user-card');
            const tabs = document.querySelectorAll('.filter-tab');
            
            // Update active tab
            tabs.forEach(tab => tab.classList.remove('active'));
            event.target.classList.add('active');
            
            // Filter cards
            cards.forEach(card => {
                let shouldShow = false;
                
                if (status === 'all') {
                    shouldShow = true;
                } else if (status === 'approved') {
                    shouldShow = card.getAttribute('data-status') === 'approved';
                } else if (status === 'pending') {
                    shouldShow = card.getAttribute('data-status') === 'pending';
                } else if (status === 'active') {
                    shouldShow = card.getAttribute('data-activity') === 'active';
                }
                
                card.style.display = shouldShow ? 'block' : 'none';
            });
        }

        function contactUser(email) {
            window.location.href = 'mailto:' + email + '?subject=Regarding Your Vehicle Rental Account';
        }

        // Auto-refresh every 60 seconds
        setTimeout(function() {
            location.reload();
        }, 60000);
    </script>
</body>
</html>