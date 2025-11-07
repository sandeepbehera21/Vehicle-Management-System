package com.vehicle;

import java.io.IOException;
import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * Routes friendly URLs like /register, /login, /home, /vehicles to JSPs.
 */
import javax.servlet.annotation.WebServlet;

@WebServlet("/")
public class SimplePageRouterServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String servletPath = request.getServletPath();
        String target;
        switch (servletPath) {
            case "/register":
                target = "/register.jsp"; // existing JSP
                break;
            case "/login":
                target = "/login.jsp"; // existing JSP
                break;
            case "/home":
            case "/index":
            case "/":
                // prefer index.jsp if present, fall back to home.jsp
                target = resourceExists(request, "/index.jsp") ? "/index.jsp" : "/home.jsp";
                break;
            case "/vehicles":
            case "/browse":
                // choose a vehicle listing JSP if present
                if (resourceExists(request, "/car.jsp")) {
                    target = "/car.jsp";
                } else if (resourceExists(request, "/bike.jsp")) {
                    target = "/bike.jsp";
                } else {
                    target = "/home.jsp";
                }
                break;
            default:
                target = "/home.jsp";
        }
        RequestDispatcher rd = request.getRequestDispatcher(target);
        rd.forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String servletPath = request.getServletPath();
        switch (servletPath) {
            case "/register":
                // Simulate registration success (no DB). Save minimal info in session.
                String name = request.getParameter("name");
                String email = request.getParameter("email");
                request.getSession(true).setAttribute("user_name", name);
                request.getSession().setAttribute("user_email", email);
                request.setAttribute("message", "Registration successful! Please login.");
                request.getRequestDispatcher("/login.jsp").forward(request, response);
                return;
            case "/login":
                // Simulate login success. Any non-empty email/password is accepted.
                String loginEmail = request.getParameter("email");
                String loginPassword = request.getParameter("password");
                if (loginEmail != null && !loginEmail.isEmpty() && loginPassword != null && !loginPassword.isEmpty()) {
                    request.getSession(true).setAttribute("user_email", loginEmail);
                    request.setAttribute("loginMessage", "Welcome " + loginEmail + "!");
                    // Prefer dashboard.jsp if present else go home
                    String target = resourceExists(request, "/dashboard.jsp") ? "/dashboard.jsp" : "/home.jsp";
                    request.getRequestDispatcher(target).forward(request, response);
                } else {
                    request.setAttribute("message", "Invalid credentials");
                    request.getRequestDispatcher("/login.jsp").forward(request, response);
                }
                return;
            default:
                // For any other POST just fallback to GET routing
                doGet(request, response);
        }
    }

    private boolean resourceExists(HttpServletRequest request, String path) {
        return getServletContext().getResourceAsStream(path) != null;
    }
}
