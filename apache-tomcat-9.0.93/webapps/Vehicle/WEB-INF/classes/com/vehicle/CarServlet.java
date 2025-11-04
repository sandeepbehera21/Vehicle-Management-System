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
{{ ... }}
                        car.setFuel_type("");
                        car.setGear("");
                        car.setAvail(avail);
				        
				        // Add car objects to carList
				                 }
             }
         }
		} catch(Exception e){};
		
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
