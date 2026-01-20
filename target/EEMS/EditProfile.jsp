<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="model.Employee" %>
<%@ page import="model.Submission" %>
<%@ page import="dao.SubmissionDAOImpl" %>
<%@ page import="java.util.List" %>
<%@ page session="true" %>

<%
    // 1. Security Check
    Employee emp = (Employee) session.getAttribute("employee");
    if (emp == null) {
        response.sendRedirect("Login.jsp");
        return;
    }

    // 2. Sidebar Badge Logic (Calculate pending claims)
    // We only need this if the user is a Manager to show the red badge
    int pendingCount = 0;
    if ("Manager".equalsIgnoreCase(emp.getRole())) {
        SubmissionDAOImpl dao = new SubmissionDAOImpl();
        List<Submission> list = dao.getSubmissionsForManager(emp.getDeptId());
        pendingCount = (list != null) ? list.size() : 0;
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Edit Profile</title>
    
    <link rel="stylesheet" href="CSS/ManagerHome.css">
    <link rel="stylesheet" href="CSS/AccountProfile.css">
    
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
            <a href="ManagerHome.jsp" class="menu-link">
                <i class="fa-solid fa-gauge-high"></i> Dashboard
            </a>

            <% if ("Manager".equalsIgnoreCase(emp.getRole())) { %>
                <div class="menu-category">Management</div>
                <a href="ManagerSubmissionList.jsp" class="menu-link">
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
            <% } %>
            
            <div class="menu-category">Account</div>
            
            <a href="EditProfile.jsp" class="menu-link active">
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

        <h2 class="profile-title" style="margin-top: 0;">Edit Profile</h2>

        <div class="profile-card">

            <div class="profile-left">
                <div class="profile-avatar">
                    <%= (emp.getName() != null && emp.getName().length() > 0) ? emp.getName().substring(0, 1).toUpperCase() : "U" %>
                </div>
                <div class="profile-name"><%= emp.getName() %></div>
                <div class="profile-role"><%= emp.getRole() %></div>
            </div>

            <form action="UpdateProfile" method="post" class="profile-form">
                <input type="hidden" name="empId" value="<%= emp.getEmpId() %>">

                <div class="form-row">
                    <div class="form-group">
                        <label>Employee ID</label>
                        <input type="text" value="<%= emp.getEmpId() %>" readonly style="background-color: #f0f0f0; cursor: not-allowed; color: #777;">
                    </div>

                    <div class="form-group">
                        <label>Department</label>
                        <select name="deptId" required>
                            <option value="D01" <%= "D01".equals(emp.getDeptId()) ? "selected" : "" %>>Production</option>
                            <option value="D02" <%= "D02".equals(emp.getDeptId()) ? "selected" : "" %>>Finance</option>
                            <option value="D03" <%= "D03".equals(emp.getDeptId()) ? "selected" : "" %>>Operation</option>
                            <option value="D04" <%= "D04".equals(emp.getDeptId()) ? "selected" : "" %>>Marketing</option>
                        </select>
                    </div>
                </div>

                <div class="form-row">
                    <div class="form-group">
                        <label>Email Address</label>
                        <input type="email" name="email" value="<%= emp.getEmail() %>" required>
                    </div>

                    <div class="form-group">
                        <label>Phone Number</label>
                        <input type="text" name="phone" value="<%= emp.getPhone() %>" required>
                    </div>
                </div>

                <div class="form-row">
                    <div class="form-group">
                        <label>Password</label>
                        <input type="text" name="password" value="<%= emp.getPassword() %>" required>
                    </div>
                </div>

                <div class="form-actions">
                    <a href="ManagerHome.jsp" class="btn cancel">Cancel</a>
                    <button type="submit" class="btn save">Save Changes</button>
                </div>

            </form>
        </div>
        </main>
</div>

<%
    String success = request.getParameter("success");
    String error = request.getParameter("error");

    if ("true".equals(success)) {
%>
    <script>
        alert("✅ Profile updated successfully!");
        // Reload clean URL
        window.history.replaceState(null, null, "EditProfile.jsp");
    </script>
<%
    } else if ("failed".equals(error)) {
%>
    <script>
        alert("❌ Update failed. Please check your data.");
    </script>
<%
    }
%>

<script>
    function logout() {
        if(confirm("Are you sure you want to log out?")) {
            window.location.href = "Login.jsp";
        }
    }
</script>

</body>
</html>
