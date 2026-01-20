<%@ page import="model.Employee" %>
<%@ page session="true" %>
<%
    // Get logged-in employee from session
    Employee emp = (Employee) session.getAttribute("employee");
    if(emp == null) {
        response.sendRedirect("Login.jsp"); // Redirect if not logged in
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Create Claim Option</title>
    <link rel="stylesheet" href="CSS/CreateClaim1.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
</head>
<body>

<!-- Top Navigation -->
<header class="top-nav">
    <div class="nav-title">Create Claim Option</div>

    <nav class="nav-menu">
        <a href="Home.jsp">Dashboard</a>
        <a href="account-profile.jsp">Account Profile</a>
        <a href="#" class="active">Create Claim</a>
    </nav>

    <div class="nav-icons">
        <i class="fa-solid fa-bell"></i>
        <i class="fa-solid fa-envelope"></i>
        <i class="fa-solid fa-user-circle"></i>
    </div>
</header>

<!-- Breadcrumb -->
<div class="breadcrumb">
    Dashboard &gt; Apply for Claim
</div>

<!-- Main Container -->
<main class="page-container">

    <section class="claim-card">
        <div class="claim-header">
            <i class="fa-solid fa-book-open"></i>
            <h2>Claim Form</h2>
        </div>

        <p class="claim-desc">
            Select the type of claim you want to submit.
        </p>

        <div class="form-group">
            <label for="claimType">Please Select Your Claim</label>
            <select id="claimType" onchange="handleClaimChange()">
                <option value="">-- Select Claim --</option>
                <option value="overtime">OverTime</option>
                <option value="medical">Medical</option>
                <option value="travel">Travel</option>
            </select>
        </div>

        <script>
            function handleClaimChange() {
                const claimType = document.getElementById("claimType").value;

                if (claimType === "overtime") {
                    window.location.href = "Overtime.jsp";
                } else if (claimType === "medical") {
                    window.location.href = "Medical.jsp";
                } else if (claimType === "travel") {
                    window.location.href = "Travel.jsp";
                }
            }
        </script>

        <div class="form-action">
            <button type="submit">Create</button>
        </div>
    </section>

</main>

</body>
</html>
