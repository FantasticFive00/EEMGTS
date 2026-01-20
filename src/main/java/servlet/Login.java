package servlet;

import java.io.IOException;

import dao.EmployeeDAO;
import dao.EmployeeDAOImpl;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.Employee;

@WebServlet("/login")
public class Login extends HttpServlet {

    private EmployeeDAO employeeDAO = new EmployeeDAOImpl();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String email = request.getParameter("email");
        String password = request.getParameter("password");

        // DEBUG
        System.out.println("=== LOGIN ATTEMPT ===");
        System.out.println("Email: " + email);
        System.out.println("Password length: " + (password != null ? password.length() : "null"));

        // Login check
        Employee emp = employeeDAO.login(email, password);

        System.out.println("Employee found: " + (emp != null));
        if (emp != null) {
            System.out.println("Employee ID: " + emp.getEmpId());
            System.out.println("Employee Name: " + emp.getName());
            System.out.println("Employee Role: " + emp.getRole());
        }
        System.out.println("====================");

        if (emp != null) {
            // Create session
            HttpSession session = request.getSession();

            // Store the entire employee object
            session.setAttribute("employee", emp);

            // Optional: store individual ID and name for easy access
            session.setAttribute("employeeId", emp.getEmpId());
            session.setAttribute("employeeName", emp.getName());

            // Check if the user is a manager or employee and redirect accordingly
            if ("manager".equalsIgnoreCase(emp.getRole())) {
                // Redirect to ManagerHome.jsp if the user is a manager
                response.sendRedirect("ManagerHome.jsp");
            } else {
                // Redirect to Home.jsp if the user is a regular employee
                response.sendRedirect("Home.jsp");
            }
        } else {
            // If login failed, set the error message and forward to login page
            request.setAttribute("error", "Invalid email or password");
            request.getRequestDispatcher("Login.jsp").forward(request, response);
        }
    }
}
