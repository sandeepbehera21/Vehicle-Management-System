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

@WebServlet("/bike")
public class BikeServlet extends HttpServlet {
	
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		DbConnection db = new DbConnection();
		PrintWriter out = response.getWriter();
		
		        // Filters: placeholder lists (legacy fetchers, keep to avoid breaking JSPs)
        Area a = new Area();
        ArrayList<Area> areaList = a.fetchAreaBike();
        City c = new City();
        ArrayList<City> cityList = c.fetchCityBike();
        State s = new State();
        ArrayList<State> stateList = s.fetchStateBike();
        Zip z = new Zip();
        ArrayList<Zip> zipList = z.fetchZipBike();
		
		ArrayList<Vehicle> bikeList = new ArrayList<Vehicle>();
		
		try {
			Connection con = db.makeConnection();
			if(con != null) {
				System.out.print("Connection Successfull");
				
				                // New schema: select bikes that are available
                String sql = "SELECT vehicle_id, owner_id, vehicle_name, vehicle_type, image_url, rent_per_day, availability FROM vehicle WHERE vehicle_type = ? AND availability = true";
                PreparedStatement ps = con.prepareStatement(sql);
                ps.setString(1, "Bike");
                ResultSet rs = ps.executeQuery();
		         
		         // Extract data from result set
		         if(!rs.isBeforeFirst()) {
		        	 out.println("No Bikes FOund");
		         } else {
		        	 while(rs.next()){
		        		Vehicle bike = new Vehicle();
		                        int v_id = rs.getInt("vehicle_id");
                        int owner_id = rs.getInt("owner_id");
                        int type = 2; // map Bike to 2-wheeler for legacy JSP
                        String model = rs.getString("vehicle_name");
                        String image = rs.getString("image_url");
                        float price = rs.getBigDecimal("rent_per_day") != null ? rs.getBigDecimal("rent_per_day").floatValue() : 0f;
                        boolean avail = rs.getBoolean("availability");
				        
				        
				        bike.setV_id(v_id);
		        		bike.setOwner_id(owner_id);
		        		bike.setType(type);
		        		bike.setModel(model);
		                        bike.setColor("");
                        bike.setReg_date("");
                        bike.setImage(image);
                        bike.setPrice(price);
                        bike.setArea("");
                        bike.setCity("");
                        bike.setState("");
                        bike.setZip("");
                        bike.setGear("");
                        bike.setAvail(avail);

				        // Add bike objects to bikeList
				        bikeList.add(bike);
		                 }
             }
         }
        } catch(Exception e){};
		
		request.setAttribute("areaList", areaList);
		request.setAttribute("cityList", cityList);
		request.setAttribute("stateList", stateList);
		request.setAttribute("zipList", zipList);
		RequestDispatcher rd = request.getRequestDispatcher("bike.jsp");
		rd.forward(request, response);
	}

	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		// TODO Handle Post Request
	}

}
