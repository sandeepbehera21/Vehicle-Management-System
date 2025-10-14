package com.vehicle;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/owner/vehicles/delete")
public class OwnerVehicleDeleteServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("owner_id") == null) {
            response.sendRedirect(request.getContextPath() + "/owner/login");
            return;
        }
        int ownerId = (Integer) session.getAttribute("owner_id");
        int vehicleId = Integer.parseInt(request.getParameter("vehicle_id"));

        try {
            DbConnection db = new DbConnection();
            Connection con = db.makeConnection();
            String sql = "DELETE FROM vehicle WHERE vehicle_id = ? AND owner_id = ?";
            try (PreparedStatement ps = con.prepareStatement(sql)) {
                ps.setInt(1, vehicleId);
                ps.setInt(2, ownerId);
                ps.executeUpdate();
            }
            response.sendRedirect(request.getContextPath() + "/owner/vehicles");
        } catch (Exception e) {
            throw new ServletException(e);
        }
    }
}
