package com.vehicle;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.sql.Connection;
import java.sql.PreparedStatement;

import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import javax.servlet.http.Part;

@MultipartConfig(maxFileSize = 5 * 1024 * 1024)
@WebServlet("/owner/vehicles/new")
public class OwnerVehicleCreateServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        if (request.getSession(false) == null || request.getSession(false).getAttribute("owner_id") == null) {
            response.sendRedirect(request.getContextPath() + "/owner/login");
            return;
        }
        request.setAttribute("mode", "create");
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

        String vehicleName = request.getParameter("vehicle_name");
        String vehicleType = request.getParameter("vehicle_type"); // Car, Bike, Scooter
        String vehicleNumber = request.getParameter("vehicle_number");
        double rentPerDay = Double.parseDouble(request.getParameter("rent_per_day"));
        boolean availability = true;

        String imageUrl = null;
        Part imagePart = request.getPart("image");
        if (imagePart != null && imagePart.getSize() > 0) {
            String uploadsPath = request.getServletContext().getRealPath("/uploads");
            if (uploadsPath == null) {
                uploadsPath = request.getServletContext().getRealPath("/") + File.separator + "uploads";
            }
            Files.createDirectories(Paths.get(uploadsPath));
            String fileName = System.currentTimeMillis() + "_" + Paths.get(imagePart.getSubmittedFileName()).getFileName();
            File file = new File(uploadsPath, fileName);
            try (InputStream in = imagePart.getInputStream(); FileOutputStream out = new FileOutputStream(file)) {
                in.transferTo(out);
            }
            imageUrl = request.getContextPath() + "/uploads/" + file.getName();
        }

        try {
            DbConnection db = new DbConnection();
            Connection con = db.makeConnection();
            String sql = "INSERT INTO vehicle (owner_id, vehicle_name, vehicle_type, vehicle_number, rent_per_day, availability, image_url) VALUES (?,?,?,?,?,?,?)";
            try (PreparedStatement ps = con.prepareStatement(sql)) {
                ps.setInt(1, ownerId);
                ps.setString(2, vehicleName);
                ps.setString(3, vehicleType);
                ps.setString(4, vehicleNumber);
                ps.setDouble(5, rentPerDay);
                ps.setBoolean(6, availability);
                ps.setString(7, imageUrl);
                ps.executeUpdate();
            }
            response.sendRedirect(request.getContextPath() + "/owner/vehicles");
        } catch (Exception e) {
            throw new ServletException(e);
        }
    }
}
