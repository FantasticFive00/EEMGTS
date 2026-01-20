<%@ page import="java.sql.*" %>
<%@ page import="model.Employee" %>
<%@ page import="util.DatabaseConnection" %>
<%@ page session="true" %>

<%
    // 1. Security Check
    Employee emp = (Employee) session.getAttribute("employee");
    if(emp == null) {
        response.sendRedirect("Login.jsp");
        return;
    }

    // 2. Dashboard Logic: Count Claims for THIS Employee
    int totalClaims = 0;
    int approvedClaims = 0;
    int rejectedClaims = 0;

    Connection conn = null;
    PreparedStatement ps = null;
    ResultSet rs = null;

    try {
        conn = DatabaseConnection.getConnection();
        
        // Count All Claims
        String sql = "SELECT " +
                     "COUNT(*) as TOTAL, " +
                     "SUM(CASE WHEN STATUS = 'APPROVED' THEN 1 ELSE 0 END) as APP, " +
                     "SUM(CASE WHEN STATUS = 'REJECTED' THEN 1 ELSE 0 END) as REJ " +
                     "FROM SUBMISSION WHERE EMPLOYEEID = ?";
        
        ps = conn.prepareStatement(sql);
        ps.setString(1, emp.getEmpId());
        rs = ps.executeQuery();
        
        if(rs.next()) {
            totalClaims = rs.getInt("TOTAL");
            approvedClaims = rs.getInt("APP");
            rejectedClaims = rs.getInt("REJ");
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
    <title>Employee Dashboard | Kotak Malaysia</title>
    <link rel="stylesheet" href="CSS/Home.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
</head>

<body>

<div class="dashboard-container">

    <nav class="sidebar">
        <div class="brand">
            <h2>KOTAK MALAYSIA</h2>
        </div>

        <div class="profile-section">
            <img src="https://cdn-icons-png.flaticon.com/512/610/610120.png" alt="Profile" class="profile-img">
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

            <div class="menu-category">Applications</div>
            <a href="CreateClaim1.jsp" class="menu-link">
                <i class="fa-solid fa-pen-to-square"></i> Create Claim
            </a>
            <a href="ViewClaim.jsp" class="menu-link">
                <i class="fa-solid fa-folder-open"></i> View My Claims
            </a>
            <a href="EmployeeClaimStatus.jsp" class="menu-link">
                <i class="fa-solid fa-list-check"></i> Claim Status
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
            <p>Here is an overview of your claim applications.</p>
        </div>

        <div class="stats-grid">
            
            <div class="stat-card card-blue">
                <div class="stat-info">
                    <h3><%= totalClaims %></h3>
                    <p>Total Claims</p>
                </div>
                <div class="stat-icon">
                    <i class="fa-solid fa-file-invoice"></i>
                </div>
            </div>

            <div class="stat-card card-green">
                <div class="stat-info">
                    <h3><%= approvedClaims %></h3>
                    <p>Approved</p>
                </div>
                <div class="stat-icon">
                    <i class="fa-solid fa-circle-check"></i>
                </div>
            </div>

            <div class="stat-card card-yellow">
                <div class="stat-info">
                    <h3><%= rejectedClaims %></h3>
                    <p>Rejected / Pending</p>
                </div>
                <div class="stat-icon">
                    <i class="fa-solid fa-circle-exclamation"></i>
                </div>
            </div>

        </div>

        <div class="banner">
            <div class="banner-content">
                <h2>Manage Your Claim Applications</h2>
                <p>Submit your medical, travel, or overtime claims easily and track their status in real-time.</p>
                <a href="CreateClaim1.jsp" class="banner-btn">
                    <i class="fa-solid fa-plus"></i> New Claim
                </a>
            </div>
            <div class="banner-img">
                <img src="https://cdn-icons-png.flaticon.com/512/1995/1995574.png" alt="Illustration">
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
