package com.vehicle;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import com.vehicle.security.BCrypt;

@WebServlet("/owner/register")
public class OwnerRegisterServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.getRequestDispatcher("/owner/owner_register.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String name = request.getParameter("name");
        String email = request.getParameter("email");
        String password = request.getParameter("password");
        String phone = request.getParameter("phone");
        String address = request.getParameter("address");

        try {
            DbConnection db = new DbConnection();
            Connection con = db.makeConnection();
            String sql = "INSERT INTO owner (name, email, password, phone, address) VALUES (?, ?, ?, ?, ?)";
            try (PreparedStatement ps = con.prepareStatement(sql)) {
                ps.setString(1, name);
                ps.setString(2, email);
                String hashed = BCrypt.hashpw(password, BCrypt.gensalt());
                ps.setString(3, hashed);
                ps.setString(4, phone);
                ps.setString(5, address);
                ps.executeUpdate();
            }
            response.sendRedirect(request.getContextPath() + "/owner/login");
        } catch (Exception e) {
            throw new ServletException(e);
        }
    }
}
