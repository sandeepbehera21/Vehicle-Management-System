package com.vehicle;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet("/owner/update_booking_status")
public class OwnerBookingActionServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        int bookingId = Integer.parseInt(request.getParameter("booking_id"));
        String action = request.getParameter("action");

        UpdateBookingStatusServlet updater = new UpdateBookingStatusServlet();
        updater.updateStatus(bookingId, action);

        response.sendRedirect(request.getContextPath() + "/owner/bookings");
    }
}