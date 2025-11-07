package com.vehicle;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet("/user/booking_form")
public class BookingFormServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        int vehicleId = Integer.parseInt(request.getParameter("vehicle_id"));
        VehicleInfo vehicle = null;
        DbConnection db = new DbConnection();

        try {
            Connection con = db.makeConnection();
            String sql = "SELECT * FROM vehicle WHERE vehicle_id = ?";
            try (PreparedStatement ps = con.prepareStatement(sql)) {
                ps.setInt(1, vehicleId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        vehicle = new VehicleInfo();
                        vehicle.setVehicle_id(rs.getInt("vehicle_id"));
                        vehicle.setOwner_id(rs.getInt("owner_id"));
                        vehicle.setVehicle_name(rs.getString("vehicle_name"));
                        vehicle.setVehicle_type(rs.getString("vehicle_type"));
                        vehicle.setVehicle_number(rs.getString("vehicle_number"));
                        vehicle.setImage_url(rs.getString("image_url"));
                        vehicle.setRent_per_day(rs.getDouble("rent_per_day"));
                        vehicle.setAvailability(rs.getBoolean("availability"));
                    }
                }
            }
            con.close();
        } catch (Exception e) {
            throw new ServletException(e);
        }

        request.setAttribute("vehicle", vehicle);
        request.getRequestDispatcher("/user/booking_form.jsp").forward(request, response);
    }
}
