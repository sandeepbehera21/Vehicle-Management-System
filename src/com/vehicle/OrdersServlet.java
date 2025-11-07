package com.vehicle;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet("/orders")
public class OrdersServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        int bookingId = Integer.parseInt(request.getParameter("booking_id"));
        int vehicleId = Integer.parseInt(request.getParameter("vehicle_id"));

        DbConnection db = new DbConnection();
        try {
            Connection con = db.makeConnection();

            // Start a transaction
            con.setAutoCommit(false);

            try {
                // Delete the booking
                String deleteBookingSql = "DELETE FROM booking WHERE booking_id = ?";
                try (PreparedStatement ps = con.prepareStatement(deleteBookingSql)) {
                    ps.setInt(1, bookingId);
                    ps.executeUpdate();
                }

                // Update the vehicle availability
                String updateVehicleSql = "UPDATE vehicle SET avail = true WHERE v_id = ?";
                try (PreparedStatement ps = con.prepareStatement(updateVehicleSql)) {
                    ps.setInt(1, vehicleId);
                    ps.executeUpdate();
                }

                // Commit the transaction
                con.commit();

            } catch (Exception e) {
                con.rollback();
                throw new ServletException(e);
            } finally {
                con.setAutoCommit(true);
                con.close();
            }

        } catch (Exception e) {
            throw new ServletException(e);
        }

        response.sendRedirect(request.getContextPath() + "/user/my_trips");
    }
}