<%@ page import="java.util.List" %>
<%@ page import="model.Employee" %>
<%@ page import="model.Submission" %>
<%@ page import="dao.SubmissionDAOImpl" %>
<%@ page session="true" %>

<%
    // 1. Security Check
    Employee manager = (Employee) session.getAttribute("employee");
    if (manager == null || !"Manager".equalsIgnoreCase(manager.getRole())) {
        response.sendRedirect("Login.jsp");
        return;
    }

    // 2. Fetch Claims using DeptId
    SubmissionDAOImpl dao = new SubmissionDAOImpl();
    List<Submission> list = dao.getSubmissionsForManager(manager.getDeptId());
    
    // Calculate pending count for the red badge
    int pendingCount = (list != null) ? list.size() : 0;
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Manager Dashboard | Department Claims</title>
    
    <link rel="stylesheet" href="CSS/ManagerHome.css">
    <link rel="stylesheet" href="CSS/ManagerSubmissionList.css">
    
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
                <h4><%= manager.getName() %></h4>
                <span><%= manager.getRole() %></span>
            </div>
        </div>

        <div class="menu">
            <div class="menu-category">Main</div>
            <a href="ManagerHome.jsp" class="menu-link">
                <i class="fa-solid fa-gauge-high"></i> Dashboard
            </a>

            <div class="menu-category">Management</div>
            
            <a href="ManagerSubmissionList.jsp" class="menu-link active">
                <i class="fa-solid fa-file-invoice"></i> Submission Claims
                <% if(pendingCount > 0) { %>
                    <span style="background: #ef4444; color: white; padding: 2px 6px; border-radius: 10px; font-size: 10px; margin-left: auto;">
                        <%= pendingCount %>
                    </span>
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
        
        <header class="top-bar" style="margin-bottom: 20px;">
            <div class="icon-btn"><i class="fa-regular fa-bell"></i></div>
            <div class="icon-btn"><i class="fa-regular fa-envelope"></i></div>
        </header>

        <div class="page-container">
            
            <div class="header-section">
                <div class="header-title">
                    <h2>Department Claims</h2>
                    <p>Reviewing pending submissions for Department ID: <strong><%= manager.getDeptId() %></strong></p>
                </div>
                <div class="dept-badge">
                    <i class="fa-solid fa-building-user"></i> ID: <%= manager.getDeptId() %>
                </div>
            </div>

            <div class="card">
                <div class="table-responsive">
                    <table>
                        <thead>
                            <tr>
                                <th>ID</th>
                                <th>Employee</th>
                                <th>Submission Date</th>
                                <th>Claim Type</th>
                                <th>Amount</th>
                                <th style="text-align: right;">Action</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% if (list == null || list.isEmpty()) { %>
                                <tr>
                                    <td colspan="6" class="empty-state">
                                        <i class="fa-regular fa-folder-open"></i>
                                        <p>No pending claims found for Department <%= manager.getDeptId() %>.</p>
                                        <p style="font-size: 0.85rem; margin-top: 5px;">Great job! You're all caught up.</p>
                                    </td>
                                </tr>
                            <% } else { 
                                for (Submission s : list) {
                                    String typeClass = "type-medical"; 
                                    if ("Overtime".equalsIgnoreCase(s.getClaimType())) typeClass = "type-overtime";
                                    else if ("Travel".equalsIgnoreCase(s.getClaimType())) typeClass = "type-travel";
                            %>
                                <tr>
                                    <td class="col-id">#<%= s.getSubmissionId() %></td>
                                    <td class="col-emp">
                                        <i class="fa-regular fa-user" style="color:#9ca3af; margin-right:6px;"></i>
                                        <%= s.getEmployeeId() %>
                                    </td>
                                    <td>
                                        <i class="fa-regular fa-calendar" style="color:#9ca3af; margin-right:6px;"></i>
                                        <%= s.getSubmissionDate() %>
                                    </td>
                                    <td>
                                        <span class="type-badge <%= typeClass %>">
                                            <%= s.getClaimType() %>
                                        </span>
                                    </td>
                                    <td class="col-amount">RM <%= String.format("%.2f", s.getAmount()) %></td>
                                    <td style="text-align: right;">
                                        <a href="ReviewClaim.jsp?id=<%= s.getSubmissionId() %>" class="btn-review">
                                            Review <i class="fa-solid fa-arrow-right"></i>
                                        </a>
                                    </td>
                                </tr>
                            <%  } 
                               } %>
                        </tbody>
                    </table>
                </div>
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