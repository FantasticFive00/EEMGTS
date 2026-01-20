<%@ page import="java.util.List" %>
<%@ page import="model.Employee" %>
<%@ page import="model.Submission" %>
<%@ page import="dao.EmployeeDAO" %>
<%@ page import="dao.EmployeeDAOImpl" %>
<%@ page import="dao.SubmissionDAOImpl" %>
<%@ page session="true" %>

<%
    // 1. Security Check
    Employee currentEmp = (Employee) session.getAttribute("employee");

    if (currentEmp == null) {
        response.sendRedirect("Login.jsp");
        return;
    }

    if (!"Manager".equalsIgnoreCase(currentEmp.getRole())) {
        response.sendRedirect("AccessDenied.jsp");
        return;
    }

    String deptId = currentEmp.getDeptId(); 

    // 2. Get Employees for the Table
    EmployeeDAO empDao = new EmployeeDAOImpl();
    List<Employee> employees = empDao.getEmployeesByDepartment(deptId);

    // 3. Get Submission Count for the Sidebar Badge (Optional, but looks professional)
    SubmissionDAOImpl subDao = new SubmissionDAOImpl();
    List<Submission> subList = subDao.getSubmissionsForManager(deptId);
    int pendingCount = (subList != null) ? subList.size() : 0;
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Manage Employee Account</title>
    
    <link rel="stylesheet" href="CSS/ManagerHome.css">
    <link rel="stylesheet" href="CSS/ManageEmployeeAccount.css">
    
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
</head>

<body>

<div class="dashboard-container">

    <nav class="sidebar">
        <div class="brand">
            <h2>KOTAK MALAYSIA</h2>
        </div>

        <div class="profile-section">
            <img src="https://cdn-icons-png.flaticon.com/512/3135/3135715.png" alt="Profile" class="profile-img">
            <div class="profile-text">
                <h4><%= currentEmp.getName() %></h4>
                <span><%= currentEmp.getRole() %></span>
            </div>
        </div>

        <div class="menu">
            <div class="menu-category">Main</div>
            <a href="ManagerHome.jsp" class="menu-link">
                <i class="fa-solid fa-gauge-high"></i> Dashboard
            </a>

            <div class="menu-category">Management</div>
            
            <a href="ManagerSubmissionList.jsp" class="menu-link">
                <i class="fa-solid fa-file-invoice"></i> Submission Claims
                <% if(pendingCount > 0) { %>
                    <span style="background: #ef4444; color: white; padding: 2px 6px; border-radius: 10px; font-size: 10px; margin-left: auto;">
                        <%= pendingCount %>
                    </span>
                <% } %>
            </a>
            
            <a href="ManageEmployeeAccount.jsp" class="menu-link active">
                <i class="fa-solid fa-users"></i> Manage Employees
            </a>
            
            <div class="menu-category">Account</div>
            <a href="EditProfile.jsp" class="menu-link">
                <i class="fa-solid fa-user-gear"></i> My Profile
            </a>
        </div>

        <button onclick="logout()" class="logout-btn">
            <i class="fa-solid fa-arrow-right-from-bracket"></i> Log Out
        </button>
    </nav>
    <main class="main-content">
        
        <header class="top-bar" style="margin-bottom: 20px;">
            <div class="icon-btn"><i class="fa-regular fa-bell"></i></div>
            <div class="icon-btn"><i class="fa-regular fa-envelope"></i></div>
        </header>

        <div class="page-container">
            
            <div class="header-text" style="margin-top: 0;">
                <h2>Manage Team</h2>
                <p>
                    Viewing active accounts for Department: 
                    <span class="dept-badge"><%= deptId %></span>
                </p>
            </div>
            
            <div class="card">
                <table class="styled-table">
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>Name</th>
                            <th>Role</th>
                            <th>Phone</th>
                            <th>Email</th>
                            <th style="text-align: right;">Action</th>
                        </tr>
                    </thead>
                    <tbody>
                    <% if (employees == null || employees.isEmpty()) { %>
                        <tr>
                            <td colspan="6" class="empty-state">
                                <i class="fa-solid fa-users-slash"></i>
                                <p>No employees found in this department.</p>
                            </td>
                        </tr>
                    <% } else {
                        for (Employee e : employees) { 
                            String roleClass = "Manager".equalsIgnoreCase(e.getRole()) ? "role-manager" : "role-employee";
                    %>
                        <tr>
                            <td class="id-col"><%= e.getEmpId() %></td>
                            <td class="name-col"><%= e.getName() %></td>
                            <td>
                                <span class="role-badge <%= roleClass %>">
                                    <%= e.getRole() %>
                                </span>
                            </td>
                            <td><%= e.getPhone() %></td>
                            <td><%= e.getEmail() %></td>
                            <td style="text-align: right;">
                            
                            <% if (!currentEmp.getEmpId().equals(e.getEmpId())) { %>
                                
                                <form action="DeleteEmployeeServlet" method="post" style="display:inline;">
                                    <input type="hidden" name="empId" value="<%= e.getEmpId() %>">
                                    
                                    <button type="submit" class="btn-delete"
                                            onclick="return confirm('WARNING: Are you sure you want to delete <%= e.getName() %>? This cannot be undone.');">
                                        <i class="fa-regular fa-trash-can"></i> Delete
                                    </button>
                                </form>
                                
                            <% } else { %>
                                <span class="self-badge">
                                    <i class="fa-solid fa-user-check"></i> You
                                </span>
                            <% } %>

                            </td>
                        </tr>
                    <% }} %>
                    </tbody>
                </table>
            </div>
        </div>
        </main>
    </div>

<script>
    function logout() {
        if(confirm("Are you sure you want to log out?")) {
            window.location.href = "Login.jsp";
        }
    }

    window.onload = function() {
        const urlParams = new URLSearchParams(window.location.search);
        const msg = urlParams.get('msg');
        const error = urlParams.get('error');

        if (msg === 'Deleted') {
            alert("✅ SUCCESS\n\nThe employee account has been successfully deleted.");
            // Clears the URL parameters so the alert doesn't show again on refresh
            window.history.replaceState(null, null, window.location.pathname);
        } 
        
        if (error === 'DeleteFailed') {
            alert("❌ ERROR\n\nCould not delete this employee.\nPossible reason: They still have active claims in the system.");
        }
    }
</script>

</body>
</html>
