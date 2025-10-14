package com.vehicle;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.vehicle.DbConnection;;
import com.vehicle.security.BCrypt;

@WebServlet("/register")
public class RegisterServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;
       
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		response.sendRedirect("register.jsp");
	}

	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		DbConnection db = new DbConnection();
		
		String name =  request.getParameter("name");
		String email =  request.getParameter("email");
		String password =  request.getParameter("password");
		
		try {
			Connection con = db.makeConnection();
			if(con != null) {
				String hashed = BCrypt.hashpw(password, BCrypt.gensalt());
				String sql = "INSERT INTO users (name, email, password) VALUES (?, ?, ?)";
				PreparedStatement st = con.prepareStatement(sql);
				st.setString(1, name);
				st.setString(2, email);
				st.setString(3, hashed);
				st.executeUpdate();
				response.sendRedirect("login");
			}
		} catch(Exception e){ throw new ServletException(e);}    
	}

}
