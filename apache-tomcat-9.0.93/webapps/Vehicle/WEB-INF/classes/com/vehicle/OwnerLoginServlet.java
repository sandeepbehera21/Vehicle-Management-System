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
import com.vehicle.security.BCrypt;

@WebServlet("/owner/login")
public class OwnerLoginServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.getRequestDispatcher("/owner/owner_login.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String email = request.getParameter("email");
        String password = request.getParameter("password");
        try {
            DbConnection db = new DbConnection();
            Connection con = db.makeConnection();
            String sql = "SELECT owner_id, name, email, password FROM owner WHERE email = ?";
            try (PreparedStatement ps = con.prepareStatement(sql)) {
                ps.setString(1, email);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        String stored = rs.getString("password");
                        if (stored != null && BCrypt.checkpw(password, stored)) {
                            HttpSession session = request.getSession();
                            session.setAttribute("owner_id", rs.getInt("owner_id"));
                            session.setAttribute("owner_name", rs.getString("name"));
                            session.setAttribute("owner_email", rs.getString("email"));
                            response.sendRedirect(request.getContextPath() + "/owner/dashboard");
                            return;
                        }
                    }
                }
            }
            response.sendRedirect(request.getContextPath() + "/owner/login?error=1");
        } catch (Exception e) {
            throw new ServletException(e);
        }
    }
}
