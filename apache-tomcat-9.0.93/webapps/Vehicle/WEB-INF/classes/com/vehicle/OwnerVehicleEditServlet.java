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
import javax.servlet.http.HttpSession;

@WebServlet("/owner/vehicles/edit")
public class OwnerVehicleEditServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("owner_id") == null) {
            response.sendRedirect(request.getContextPath() + "/owner/login");
            return;
        }
        String idStr = request.getParameter("id");
        if (idStr == null) {
            response.sendRedirect(request.getContextPath() + "/owner/vehicles");
            return;
        }
        int id = Integer.parseInt(idStr);
        int ownerId = (Integer) session.getAttribute("owner_id");

        try {
            DbConnection db = new DbConnection();
            Connection con = db.makeConnection();
            String sql = "SELECT vehicle_id, vehicle_name, vehicle_type, vehicle_number, rent_per_day, availability, image_url FROM vehicle WHERE vehicle_id = ? AND owner_id = ?";
            try (PreparedStatement ps = con.prepareStatement(sql)) {
                ps.setInt(1, id);
                ps.setInt(2, ownerId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        request.setAttribute("vehicle_id", rs.getInt("vehicle_id"));
                        request.setAttribute("vehicle_name", rs.getString("vehicle_name"));
                        request.setAttribute("vehicle_type", rs.getString("vehicle_type"));
                        request.setAttribute("vehicle_number", rs.getString("vehicle_number"));
                        request.setAttribute("rent_per_day", rs.getDouble("rent_per_day"));
                        request.setAttribute("availability", rs.getBoolean("availability"));
                        request.setAttribute("image_url", rs.getString("image_url"));
                    }
                }
            }
        } catch (Exception e) {
            throw new ServletException(e);
        }
        request.setAttribute("mode", "edit");
        request.getRequestDispatcher("/owner/vehicle_form.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("owner_id") == null) {
            response.sendRedirect(request.getContextPath() + "/owner/login");
            return;
        }
        int ownerId = (Integer) session.getAttribute("owner_id");

        int vehicleId = Integer.parseInt(request.getParameter("vehicle_id"));
        String vehicleName = request.getParameter("vehicle_name");
        String vehicleType = request.getParameter("vehicle_type");
        String vehicleNumber = request.getParameter("vehicle_number");
        double rentPerDay = Double.parseDouble(request.getParameter("rent_per_day"));
        boolean availability = "on".equals(request.getParameter("availability"));

        try {
            DbConnection db = new DbConnection();
            Connection con = db.makeConnection();
            String sql = "UPDATE vehicle SET vehicle_name=?, vehicle_type=?, vehicle_number=?, rent_per_day=?, availability=? WHERE vehicle_id=? AND owner_id=?";
            try (PreparedStatement ps = con.prepareStatement(sql)) {
                ps.setString(1, vehicleName);
                ps.setString(2, vehicleType);
                ps.setString(3, vehicleNumber);
                ps.setDouble(4, rentPerDay);
                ps.setBoolean(5, availability);
                ps.setInt(6, vehicleId);
                ps.setInt(7, ownerId);
                ps.executeUpdate();
            }
            response.sendRedirect(request.getContextPath() + "/owner/vehicles");
        } catch (Exception e) {
            throw new ServletException(e);
        }
    }
}
