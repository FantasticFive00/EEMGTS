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

@WebServlet("/SubmitDraftServlet") // This must match the form action in ViewClaim.jsp
public class SubmitDraftServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private SubmissionDAO dao;

    public SubmitDraftServlet() {
        super();
        dao = new SubmissionDAOImpl();
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {

        // 1. Security: Check if logged in
        HttpSession session = request.getSession(false);
        Employee emp = (session != null) ? (Employee) session.getAttribute("employee") : null;

        if (emp == null) {
            response.sendRedirect("Login.jsp");
            return;
        }

        try {
            // 2. Get the ID from the button
            String idStr = request.getParameter("submissionId");
            
            if (idStr != null && !idStr.isEmpty()) {
                int submissionId = Integer.parseInt(idStr);

                // 3. Update Status
                boolean success = dao.submitDraft(submissionId, emp.getEmpId());

                if (success) {
                    response.sendRedirect("ViewClaim.jsp?msg=submitted");
                } else {
                    response.sendRedirect("ViewClaim.jsp?error=fail");
                }
            } else {
                response.sendRedirect("ViewClaim.jsp?error=invalid_id");
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("ViewClaim.jsp?error=exception");
        }
    }
}
