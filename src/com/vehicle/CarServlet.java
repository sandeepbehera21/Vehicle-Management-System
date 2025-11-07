package com.vehicle;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.PreparedStatement;
import java.util.ArrayList;

import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.vehicle.Vehicle;
import com.vehicle.Area;

@WebServlet("/car")
public class CarServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;
	
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		DbConnection db = new DbConnection();
		
		// Array List for filters
		Area a = new Area();
		ArrayList<Area> areaList = a.fetchAreaCar();
		
		City c = new City();
		ArrayList<City> cityList = c.fetchCityCar();
		
		State s = new State();
		ArrayList<State> stateList = s.fetchStateCar();
		
		Zip z = new Zip();
		ArrayList<Zip> zipList = z.fetchZipCar();

		// Array List for cars
		ArrayList<Vehicle> carList = new ArrayList<Vehicle>();

		try {
			Connection con = db.makeConnection();
			// Only show approved vehicles to users
			String sql = "SELECT * FROM vehicle WHERE vehicle_type = 'Car' AND approval_status = 'approved'";
			PreparedStatement ps = con.prepareStatement(sql);
			ResultSet rs = ps.executeQuery();

			while (rs.next()) {
				Vehicle car = new Vehicle();
				car.setV_id(rs.getInt("vehicle_id"));
				car.setModel(rs.getString("vehicle_name"));
				car.setType(1); // Car type
				car.setImage(rs.getString("image_url"));
				car.setPrice((float)rs.getDouble("rent_per_day"));
				car.setAvail(rs.getBoolean("availability"));

				carList.add(car);
			}
		} catch(Exception e){
			e.printStackTrace();
		}

		request.setAttribute("areaList", areaList);
		request.setAttribute("cityList", cityList);
		request.setAttribute("stateList", stateList);
		request.setAttribute("carList", carList);
		RequestDispatcher rd = request.getRequestDispatcher("car.jsp");
		rd.forward(request, response);
	}

	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		// TODO Handle Post Request
	}

}
