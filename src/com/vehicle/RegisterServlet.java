package com.vehicle;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import com.vehicle.DbConnection;

public class RegisterServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;

	protected void doGet(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		response.sendRedirect("login.jsp");
	}

	protected void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		DbConnection db = new DbConnection();

		String role = request.getParameter("role");
		if (role == null || role.isEmpty()) role = "user";
		String name = request.getParameter("name");
		String email = request.getParameter("email");
		String password = request.getParameter("password");
		String phone = request.getParameter("phone");
		String address = request.getParameter("address");

		try {
			Connection con = db.makeConnection();
			if (con != null) {
				// Avoid duplicate emails across all auth tables
				if (emailExists(con, "SELECT 1 FROM users WHERE email=?", email)
						|| emailExists(con, "SELECT 1 FROM owner WHERE email=?", email)
						|| emailExists(con, "SELECT 1 FROM admin WHERE email=?", email)) {
					response.sendRedirect(request.getContextPath() + "/login?error=exists");
					return;
				}

				if ("owner".equalsIgnoreCase(role)) {
					String sql = "INSERT INTO owner (name, email, password, phone, address) VALUES (?, ?, ?, ?, ?)";
					try (PreparedStatement st = con.prepareStatement(sql)) {
						st.setString(1, name);
						st.setString(2, email);
						st.setString(3, password);
						st.setString(4, phone);
						st.setString(5, address);
						st.executeUpdate();
					}
					response.sendRedirect(request.getContextPath() + "/owner/login");
					return;
				} else if ("admin".equalsIgnoreCase(role)) {
					String sql = "INSERT INTO admin (name, email, password, phone) VALUES (?, ?, ?, ?)";
					try (PreparedStatement st = con.prepareStatement(sql)) {
						st.setString(1, name);
						st.setString(2, email);
						st.setString(3, password);
						st.setString(4, phone);
						st.executeUpdate();
					}
					response.sendRedirect(request.getContextPath() + "/admin/login");
					return;
				} else {
					// Default: user
					String sql = "INSERT INTO users (name, email, password, role) VALUES (?, ?, ?, 'user')";
					try (PreparedStatement st = con.prepareStatement(sql, java.sql.Statement.RETURN_GENERATED_KEYS)) {
						st.setString(1, name);
						st.setString(2, email);
						st.setString(3, password);
						st.executeUpdate();
						try (ResultSet keys = st.getGeneratedKeys()) {
							int userId = 0;
							if (keys.next())
								userId = keys.getInt(1);
							HttpSession old = request.getSession(false);
							if (old != null) old.invalidate();
							HttpSession session = request.getSession(true);
							session.setAttribute("user_id", userId);
							session.setAttribute("name", name);
							session.setAttribute("email", email);
							session.setAttribute("role", "user");
							session.setMaxInactiveInterval(30 * 60);
						}
					}
					response.sendRedirect(request.getContextPath() + "/user/dashboard");
					return;
				}
			}
		} catch (Exception e) {
			throw new ServletException(e);
		}
	}

	private boolean emailExists(Connection con, String sql, String email) throws Exception {
		try (PreparedStatement ps = con.prepareStatement(sql)) {
			ps.setString(1, email);
			try (ResultSet rs = ps.executeQuery()) {
				return rs.next();
			}
		}
	}

}
