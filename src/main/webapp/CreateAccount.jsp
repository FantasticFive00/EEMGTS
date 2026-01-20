<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>EEMS - Create Account</title>
    <link rel="stylesheet" href="CSS/style.css">
</head>
<body>

<div class="container">
    <!-- LEFT PANEL -->
    <div class="left-panel">
        <h1>Kotak Malaysia</h1>
        <h2>Employee Expenses Management System</h2>
        <p>Allows employees to create and submit expense claims online.</p>
    </div>
    <!-- RIGHT PANEL -->
    <div class="right-panel">
        <div class="form-box">
            <h2>Welcome to EEMS</h2>
            <p>Register your account</p>

            <!-- Error message -->
            <%
                String error = (String) request.getAttribute("error");
                if (error != null) {
            %>
                <p style="color:red;"><%= error %></p>
            <%
                }
            %>

            <form action="<%= request.getContextPath() %>/CreateAccount" method="post">
                <div class="form-grid">

                    <div class="form-group">
                        <label>Employee ID</label>
                        <input type="text" name="employeeId" required>
                    </div>

                    <div class="form-group">
                        <label>Name</label>
                        <input type="text" name="name" required>
                    </div>
                    <div class="form-group">
                        <label>Role</label>
                        <select name="role" required>
                            <option value="">-- Select Role --</option>
                            <option value="Employee">Employee</option>
                            <option value="Manager">Manager</option>
                        </select>
                    </div>
                    <div class="form-group">
    <label>Department</label>
    <select name="deptId" required>
        <option value="">-- Select Department --</option>
        <option value="D01">Production</option>
        <option value="D02">Finance</option>
        <option value="D03">Operation</option>
        <option value="D04">Marketing</option>
    </select>
</div>
                    <div class="form-group">
                        <label>Email Address</label>
                        <input type="email" name="email" required>
                    </div>

                    <div class="form-group">
                        <label>Phone Number</label>
                        <input type="tel" name="phone" pattern="[0-9]{10,11}" required>
                    </div>

                    <div class="form-group">
                        <label>Password</label>
                        <input type="password" name="password" required>
                    </div>

                </div>

                <div class="checkbox">
                    <input type="checkbox" required>
                    I agree to all the <a href="#">Terms</a>, <a href="#">Privacy Policy</a>
                </div>
                <button type="submit">Submit</button>
                <div class="login">
                    Already have an account?
                    <a href="<%= request.getContextPath() %>/Login.jsp">Log In</a>
                </div>
            </form>
        </div>
    </div>
</div>
<%
    String success = request.getParameter("success");
    if ("true".equals(success)) {
%>
<script>
    // 1. Show the success message
    alert("🎉 Account created successfully! You will be redirected to the Login page.");
    
    // 2. Automatically go to Login.jsp after user clicks 'OK'
    window.location.href = "Login.jsp";
</script>
<%
    }
%>
</body>
</html>