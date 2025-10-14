package com.vehicle;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
@WebServlet("/admin/login")
public class AdminLoginServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.getRequestDispatcher("/admin/admin_login.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String username = request.getParameter("username");
        String password = request.getParameter("password");
        
        // Simple admin authentication - admin/admin
        if ("admin".equals(username) && "admin".equals(password)) {
            HttpSession session = request.getSession();
            session.setAttribute("admin_id", 1);
            session.setAttribute("admin_username", "admin");
            session.setAttribute("admin_name", "System Administrator");
            session.setAttribute("admin_email", "admin@vehiclemanagement.com");
            response.sendRedirect(request.getContextPath() + "/admin/dashboard");
            return;
        }
        
        
        // Login failed
        request.setAttribute("error", "Invalid username or password. Use admin/admin");
        request.getRequestDispatcher("/admin/admin_login.jsp").forward(request, response);
    }
}
