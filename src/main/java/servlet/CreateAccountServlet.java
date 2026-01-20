package servlet;

import java.io.IOException;
import dao.EmployeeDAO;
import dao.EmployeeDAOImpl;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.Employee;

@WebServlet("/CreateAccount")
public class CreateAccountServlet extends HttpServlet {

    private EmployeeDAO employeeDAO = new EmployeeDAOImpl();

    // Handle GET requests - redirect to the JSP page
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.sendRedirect(request.getContextPath() + "/CreateAccount.jsp");
    }

    // Handle POST requests - process form submission
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // 1. Get parameters (Note: Ensure your JSP <select> name matches "deptId")
        String empId = request.getParameter("employeeId");
        String name = request.getParameter("name");
        String role = request.getParameter("role");

        // This will now capture "D01", "D02", etc., instead of "Finance"
        String deptId = request.getParameter("deptId");

        String email = request.getParameter("email");
        String phone = request.getParameter("phone");
        String password = request.getParameter("password");

        // Check if email already exists
        if (employeeDAO.isEmailExists(email)) {
            request.setAttribute("error", "Email already registered");
            request.getRequestDispatcher("CreateAccount.jsp").forward(request, response);
            return;
        }

        // 2. Create Employee object
        // Make sure your Employee model has a setDeptId (or setDepartment) that accepts
        // the "D01" string
        Employee emp = new Employee();
        emp.setEmpId(empId);
        emp.setName(name);
        emp.setRole(role);
        emp.setDeptId(deptId); // Changed from setDepartment to setDeptId (Recommended)
        emp.setEmail(email);
        emp.setPhone(phone);
        emp.setPassword(password);

        // Register employee
        boolean success = employeeDAO.registerEmployee(emp);

        if (success) {
            // 3. CRITICAL FIX: Logic first, Redirect last.
            // In your old code, the redirect happened here, preventing the code below from
            // running.

            if ("Manager".equals(role)) {
                // Now passing "D01" (ID) instead of "Production" (Name)
                employeeDAO.assignManagerToDepartment(empId, deptId);
            }

            // Redirect ONLY after all logic is complete
            response.sendRedirect(request.getContextPath() + "/CreateAccount.jsp?success=true");

        } else {
            request.setAttribute("error", "Registration failed");
            request.getRequestDispatcher("CreateAccount.jsp").forward(request, response);
        }
    }
}