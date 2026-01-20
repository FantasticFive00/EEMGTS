package servlet;

import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import dao.SubmissionDAO;
import dao.SubmissionDAOImpl;
import model.Employee;

@WebServlet("/ManagerActionServlet")
public class ManagerActionServlet extends HttpServlet {

    private SubmissionDAO submissionDAO = new SubmissionDAOImpl();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {

        // 1. Security Check: Is the user a Manager?
        HttpSession session = request.getSession(false);
        Employee manager = (session != null) ? (Employee) session.getAttribute("employee") : null;

        if (manager == null || !"Manager".equalsIgnoreCase(manager.getRole())) {
            response.sendRedirect("Login.jsp"); // Block unauthorized access
            return;
        }

        // 2. Get Parameters from the Form
        String submissionIdStr = request.getParameter("submissionId");
        String action = request.getParameter("action"); // "approve" or "reject"
        
        if (submissionIdStr != null && action != null) {
            int submissionId = Integer.parseInt(submissionIdStr);
            String newStatus = "";

            // 3. Determine New Status
            if ("approve".equalsIgnoreCase(action)) {
                newStatus = "APPROVED";
            } else if ("reject".equalsIgnoreCase(action)) {
                newStatus = "REJECTED";
            }

            // 4. Update Database
            // We pass the manager's department to ensure they only approve their own team's claims
            boolean success = submissionDAO.updateStatusByManager(submissionId, newStatus, manager.getDeptId());

            if (success) {
                // Success: Go back to the list
                response.sendRedirect("ManagerSubmissionList.jsp?msg=" + newStatus);
            } else {
                // Failure: Stay on page and show error
                response.sendRedirect("ManagerSubmissionList.jsp?error=UpdateFailed");
            }
        } else {
            response.sendRedirect("ManagerSubmissionList.jsp");
        }
    }
}
