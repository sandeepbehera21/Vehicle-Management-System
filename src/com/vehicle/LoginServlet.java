package com.vehicle;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.*;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import com.vehicle.DbConnection;

@WebServlet("/login")
public class LoginServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;

	protected void doGet(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		response.sendRedirect("login.jsp");
	}

	protected void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		String email = request.getParameter("email");
		String password = request.getParameter("password");

		DbConnection db = new DbConnection();
		try {
			Connection con = db.makeConnection();
			String sql = "SELECT user_id, name, email, password, role, account_status FROM users WHERE email = ?";
			try (PreparedStatement ps = con.prepareStatement(sql)) {
				ps.setString(1, email);
				try (ResultSet rs = ps.executeQuery()) {
					if (rs.next()) {
						String storedPassword = rs.getString("password");
						String role = rs.getString("role");
						String accountStatus = rs.getString("account_status");
						
						// Check if account is disabled
						if ("DISABLED".equalsIgnoreCase(accountStatus)) {
							response.sendRedirect(request.getContextPath() + "/login?error=disabled");
							return;
						}
						
						if (password != null && password.equals(storedPassword)) {
							HttpSession old = request.getSession(false);
							if (old != null) old.invalidate();
							HttpSession session = request.getSession(true);
							session.setAttribute("user_id", rs.getInt("user_id"));
							session.setAttribute("name", rs.getString("name"));
							session.setAttribute("email", rs.getString("email"));
							session.setAttribute("role", role);
							session.setMaxInactiveInterval(30 * 60);

							if ("admin".equalsIgnoreCase(role)) {
								session.setAttribute("admin_id", rs.getInt("user_id"));
								response.sendRedirect(request.getContextPath() + "/admin/dashboard");
								return;
							} else if ("owner".equalsIgnoreCase(role)) {
								Integer ownerId = null;
								try (PreparedStatement op = con.prepareStatement("SELECT owner_id FROM owner WHERE email = ?")) {
									op.setString(1, rs.getString("email"));
									try (ResultSet ors = op.executeQuery()) {
										if (ors.next()) {
											ownerId = ors.getInt("owner_id");
										}
									}
								}
								if (ownerId != null) {
									session.setAttribute("owner_id", ownerId);
								}
								response.sendRedirect(request.getContextPath() + "/owner/dashboard");
								return;
							} else {
								response.sendRedirect(request.getContextPath() + "/user/dashboard");
								return;
							}
						}
					}
				}
			}

			// Not found in users or wrong password there; try admin table
			try (PreparedStatement aps = con.prepareStatement(
					"SELECT admin_id, name, email FROM admin WHERE email = ? AND password = ?")) {
				aps.setString(1, email);
				aps.setString(2, password);
				try (ResultSet ars = aps.executeQuery()) {
					if (ars.next()) {
						HttpSession old = request.getSession(false);
						if (old != null) old.invalidate();
						HttpSession session = request.getSession(true);
						session.setAttribute("admin_id", ars.getInt("admin_id"));
						session.setAttribute("admin_name", ars.getString("name"));
						session.setAttribute("admin_email", ars.getString("email"));
						session.setAttribute("role", "admin");
						session.setMaxInactiveInterval(30 * 60);
						response.sendRedirect(request.getContextPath() + "/admin/dashboard");
						return;
					}
				}
			}

			// Try owner table
			try (PreparedStatement ops = con.prepareStatement(
					"SELECT owner_id, name, email, account_status FROM owner WHERE email = ? AND password = ?")) {
				ops.setString(1, email);
				ops.setString(2, password);
				try (ResultSet ors = ops.executeQuery()) {
					if (ors.next()) {
						String ownerStatus = ors.getString("account_status");
						
						// Check if owner account is disabled
						if ("DISABLED".equalsIgnoreCase(ownerStatus)) {
							response.sendRedirect(request.getContextPath() + "/login?error=disabled");
							return;
						}
						
						HttpSession old = request.getSession(false);
						if (old != null) old.invalidate();
						HttpSession session = request.getSession(true);
						session.setAttribute("owner_id", ors.getInt("owner_id"));
						session.setAttribute("name", ors.getString("name"));
						session.setAttribute("email", ors.getString("email"));
						session.setAttribute("role", "owner");
						session.setMaxInactiveInterval(30 * 60);
						response.sendRedirect(request.getContextPath() + "/owner/dashboard");
						return;
					}
				}
			}
			response.sendRedirect(request.getContextPath() + "/login?error=1");
		} catch (Exception e) {
			throw new ServletException(e);
		}
	}
}
