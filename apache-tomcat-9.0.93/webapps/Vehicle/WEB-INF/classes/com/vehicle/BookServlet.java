package com.vehicle;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.time.LocalDate;
import java.time.temporal.ChronoUnit;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/book")
public class BookServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;
       
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		
	}

	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		PrintWriter out = response.getWriter();
		HttpSession session = request.getSession();
		Integer uidObj = (Integer) session.getAttribute("user_id");
		if (uidObj == null) { response.sendRedirect("/Vehicle/login"); return; }
		int user_id = uidObj;
		int vehicle_id = Integer.parseInt(request.getParameter("v_id"));
		LocalDate start = LocalDate.parse(request.getParameter("start_date"));
		LocalDate end = LocalDate.parse(request.getParameter("end_date"));
		long days = Math.max(1, ChronoUnit.DAYS.between(start, end));
		
		try {
			DbConnection db = new DbConnection();
			Connection con = db.makeConnection();
			if (con != null) {
				// Fetch rent_per_day
				double rentPerDay = 0.0;
				try (PreparedStatement ps = con.prepareStatement("SELECT rent_per_day FROM vehicle WHERE vehicle_id=? AND availability=true")) {
					ps.setInt(1, vehicle_id);
					try (ResultSet rs = ps.executeQuery()) {
						if (rs.next()) rentPerDay = rs.getBigDecimal(1).doubleValue();
						else { response.sendRedirect("/Vehicle/dashboard?error=unavailable"); return; }
					}
				}
				double total = rentPerDay * days;
				
				// mark unavailable
				try (PreparedStatement up = con.prepareStatement("UPDATE vehicle SET availability=false WHERE vehicle_id=?")) {
					up.setInt(1, vehicle_id);
					up.executeUpdate();
				}
				
				// insert booking
				String ins = "INSERT INTO booking (user_id, vehicle_id, start_date, end_date, total_amount, status) VALUES (?,?,?,?,?, 'Pending')";
				try (PreparedStatement st = con.prepareStatement(ins)) {
					st.setInt(1, user_id);
					st.setInt(2, vehicle_id);
					st.setDate(3, java.sql.Date.valueOf(start));
					st.setDate(4, java.sql.Date.valueOf(end));
					st.setBigDecimal(5, java.math.BigDecimal.valueOf(total));
					st.executeUpdate();
				}
				
				response.sendRedirect("/Vehicle/dashboard");
			}
		} catch (Exception e) { throw new ServletException(e); }
	}

}
