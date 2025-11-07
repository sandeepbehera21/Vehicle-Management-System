package com.vehicle;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet("/user/book_vehicle")
public class BookVehicleServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        List<VehicleInfo> vehicleList = new ArrayList<>();
        DbConnection db = new DbConnection();

        try {
            Connection con = db.makeConnection();
            String sql = "SELECT * FROM vehicle WHERE availability = TRUE";
            try (PreparedStatement ps = con.prepareStatement(sql)) {
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        VehicleInfo vehicle = new VehicleInfo();
                        vehicle.setVehicle_id(rs.getInt("vehicle_id"));
                        vehicle.setOwner_id(rs.getInt("owner_id"));
                        vehicle.setVehicle_name(rs.getString("vehicle_name"));
                        vehicle.setVehicle_type(rs.getString("vehicle_type"));
                        vehicle.setVehicle_number(rs.getString("vehicle_number"));
                        vehicle.setImage_url(rs.getString("image_url"));
                        vehicle.setRent_per_day(rs.getDouble("rent_per_day"));
                        vehicle.setAvailability(rs.getBoolean("availability"));
                        vehicleList.add(vehicle);
                    }
                }
            }
            con.close();
        } catch (Exception e) {
            throw new ServletException(e);
        }

        request.setAttribute("vehicles", vehicleList);
        request.getRequestDispatcher("/user/book_vehicle.jsp").forward(request, response);
    }
}