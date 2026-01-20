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

@WebServlet("/DeleteEmployeeServlet")
public class DeleteEmployeeServlet extends HttpServlet {

    private SubmissionDAO dao = new SubmissionDAOImpl();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {

        // 1. Security Check
        HttpSession session = request.getSession(false);
        Employee manager = (session != null) ? (Employee) session.getAttribute("employee") : null;

        if (manager == null || !"Manager".equalsIgnoreCase(manager.getRole())) {
            response.sendRedirect("Login.jsp");
            return;
        }

        // 2. Get the Employee ID to delete
        String empIdToDelete = request.getParameter("empId");

        if (empIdToDelete != null) {
            
            // 3. Execute Delete (Pass Manager's Dept ID for security)
            boolean success = dao.deleteEmployee(empIdToDelete, manager.getDeptId());

            if (success) {
                // NEW (Correct Name)
                response.sendRedirect("ManageEmployeeAccount.jsp?msg=Deleted");
            } else {
                // NEW (Correct Name)
                response.sendRedirect("ManageEmployeeAccount.jsp?error=DeleteFailed");
            }
        } else {
            response.sendRedirect("ManageEmployeeAccount.jsp");
        }
    }
}
