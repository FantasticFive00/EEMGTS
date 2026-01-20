<%@ page import="java.sql.*" %>
<%@ page import="model.Employee" %>
<%@ page import="util.DatabaseConnection" %>
<%@ page session="true" %>

<%
    // 1. Security Check
    Employee emp = (Employee) session.getAttribute("employee");
    if(emp == null || !"Manager".equalsIgnoreCase(emp.getRole())) {
        response.sendRedirect("Login.jsp");
        return;
    }

    // 2. Dashboard Logic: Count Employees & Pending Claims
    int pendingClaims = 0;
    int employeeCount = 0;
    String deptId = emp.getDeptId();

    Connection conn = null;
    PreparedStatement ps = null;
    ResultSet rs = null;

    try {
        conn = DatabaseConnection.getConnection();

        // Query A: Count Pending Claims for this Dept
        String sqlClaims = "SELECT COUNT(*) FROM SUBMISSION s " +
                           "JOIN EMPLOYEE e ON s.EMPLOYEEID = e.EMPLOYEEID " +
                           "WHERE e.DEPTID = ? AND s.STATUS = 'SUBMITTED'";
        ps = conn.prepareStatement(sqlClaims);
        ps.setString(1, deptId);
        rs = ps.executeQuery();
        if(rs.next()) {
            pendingClaims = rs.getInt(1);
        }
        rs.close();
        ps.close();

        // Query B: Count Employees in this Dept
        String sqlEmps = "SELECT COUNT(*) FROM EMPLOYEE WHERE DEPTID = ?";
        ps = conn.prepareStatement(sqlEmps);
        ps.setString(1, deptId);
        rs = ps.executeQuery();
        if(rs.next()) {
            employeeCount = rs.getInt(1);
        }

    } catch(Exception e) {
        e.printStackTrace();
    } finally {
        if(rs != null) rs.close();
        if(ps != null) ps.close();
        if(conn != null) conn.close();
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Manager Dashboard | Kotak Malaysia</title>
    
    <link rel="stylesheet" href="CSS/ManagerHome.css">
    
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
                <h4><%= emp.getName() %></h4>
                <span><%= emp.getRole() %></span>
            </div>
        </div>

        <div class="menu">
            <div class="menu-category">Main</div>
            <a href="#" class="menu-link active">
                <i class="fa-solid fa-gauge-high"></i> Dashboard
            </a>

            <div class="menu-category">Management</div>
            <a href="ManagerSubmissionList.jsp" class="menu-link">
                <i class="fa-solid fa-file-invoice"></i> Submission Claims
                <% if(pendingClaims > 0) { %>
                    <span style="background: #ef4444; color: white; padding: 2px 6px; border-radius: 10px; font-size: 10px; margin-left: auto;"><%= pendingClaims %></span>
                <% } %>
            </a>
            <a href="ManageEmployeeAccount.jsp" class="menu-link">
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
        
        <header class="top-bar">
            <div class="icon-btn"><i class="fa-regular fa-bell"></i></div>
            <div class="icon-btn"><i class="fa-regular fa-envelope"></i></div>
        </header>

        <div class="page-header">
            <h1>Welcome back, <%= emp.getName() %>!</h1>
            <p>Department: <strong><%= deptId %></strong> Control Panel</p>
        </div>

        <div class="stats-grid">
            
            <a href="ManagerSubmissionList.jsp" style="text-decoration: none;">
                <div class="stat-card card-blue">
                    <div class="stat-info">
                        <h3><%= pendingClaims %></h3>
                        <p>Pending Claims</p>
                    </div>
                    <div class="stat-icon">
                        <i class="fa-solid fa-clipboard-list"></i>
                    </div>
                </div>
            </a>

            <a href="ManageEmployeeAccount.jsp" style="text-decoration: none;">
                <div class="stat-card card-green">
                    <div class="stat-info">
                        <h3><%= employeeCount %></h3>
                        <p>Total Employees</p>
                    </div>
                    <div class="stat-icon">
                        <i class="fa-solid fa-users"></i>
                    </div>
                </div>
            </a>

        </div>

        <div class="banner">
            <div class="banner-content">
                <h2>Oversee Employee Operations</h2>
                <p>Ensure all claims are reviewed on time and manage your department's staff records efficiently.</p>
                <a href="ManagerSubmissionList.jsp" class="banner-btn">Review Pending Claims</a>
            </div>
            <div class="banner-img">
                <img src="https://cdn-icons-png.flaticon.com/512/3048/3048396.png" alt="Illustration">
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
</script>

</body>
</html>
