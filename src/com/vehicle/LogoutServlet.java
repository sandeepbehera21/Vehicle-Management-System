package com.vehicle;

import java.io.IOException;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/logout")
public class LogoutServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;
       
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		HttpSession session = request.getSession(false);
        if (session != null) {
            // Clear common attributes for all roles
            session.removeAttribute("user_id");
            session.removeAttribute("owner_id");
            session.removeAttribute("admin_id");
            session.removeAttribute("email");
            session.removeAttribute("name");
            session.removeAttribute("owner_email");
            session.removeAttribute("owner_name");
            session.removeAttribute("admin_email");
            session.removeAttribute("admin_name");
            session.invalidate();
        }
        response.sendRedirect(request.getContextPath() + "/home.jsp");
	}
}
