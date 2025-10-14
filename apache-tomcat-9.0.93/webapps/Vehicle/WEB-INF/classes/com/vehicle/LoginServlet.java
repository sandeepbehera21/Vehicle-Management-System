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
import com.vehicle.security.BCrypt;

@WebServlet("/login")
public class LoginServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;
	
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		response.sendRedirect("login.jsp");
	}
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		HttpSession session = request.getSession();
		DbConnection db = new DbConnection();
		PrintWriter out = response.getWriter();
		
		String email =  request.getParameter("email");
		String password =  request.getParameter("password");
		
		System.out.println("User Email:\t" + request.getParameter("email"));
		System.out.println("User Password:\t" + request.getParameter("password"));

		        try {
            Connection con = db.makeConnection();
            if(con != null) {
                String sql = "SELECT user_id, name, email, password FROM users WHERE email = ?";
                try (PreparedStatement ps = con.prepareStatement(sql)) {
                    ps.setString(1, email);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (!rs.isBeforeFirst()) {
                            response.sendRedirect("/Vehicle/login?error=1");
                        } else {
                            while (rs.next()) {
                                int user_id = rs.getInt("user_id");
                                String name = rs.getString("name");
                                String remail = rs.getString("email");
                                String hash = rs.getString("password");
                                if (BCrypt.checkpw(password, hash)) {
                                    session.setAttribute("user_id", user_id);
                                    session.setAttribute("name", name);
                                    session.setAttribute("email", remail);
                                    response.sendRedirect("/Vehicle/dashboard");
                                } else {
                                    response.sendRedirect("/Vehicle/login?error=1");
                                }
                            }
                        }
                    }
                }
            }
        } catch(Exception e){ throw new ServletException(e);}
