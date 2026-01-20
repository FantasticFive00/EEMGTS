package servlet;

import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import dao.EmployeeDAO;
import dao.EmployeeDAOImpl;
import model.Employee;

// This nickname "/UpdateProfile" is what the JSP looks for!
@WebServlet("/UpdateProfile") 
public class UpdateProfileServlet extends HttpServlet {

    private EmployeeDAO dao = new EmployeeDAOImpl();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // 1. Get Session
        HttpSession session = request.getSession(false);
        Employee currentEmp = (session != null) ? (Employee) session.getAttribute("employee") : null;

        if (currentEmp == null) {
            response.sendRedirect("Login.jsp");
            return;
        }

        // 2. Get Data from Form
        String deptId = request.getParameter("deptId");
        String email = request.getParameter("email");
        String phone = request.getParameter("phone");
        String password = request.getParameter("password");

        // 3. Update Object
        currentEmp.setDeptId(deptId);
        currentEmp.setEmail(email);
        currentEmp.setPhone(phone);
        currentEmp.setPassword(password);

        // 4. Update Database
        if (dao.updateEmployee(currentEmp)) {
            // Update session so the user sees changes immediately
            session.setAttribute("employee", currentEmp);
            response.sendRedirect("EditProfile.jsp?success=true");
        } else {
            response.sendRedirect("EditProfile.jsp?error=failed");
        }
    }
}