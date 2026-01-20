<%@ page import="model.Employee" %>
<%@ page session="true" %>
<%
    Employee emp = (Employee) session.getAttribute("employee");
    if (emp == null) {
        response.sendRedirect("Login.jsp");
        return;
    }

    /* Sample data – replace with DB later */
    String claimType = "Travel";
    String description = "Project meeting at site office";
    String amount = "120.00";
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Update Claim</title>
    <link rel="stylesheet" href="CSS/ClaimDetail.css">
</head>
<body>

<div class="container">

    <h2>✏️ Update Claim</h2>

    <form action="SubmitClaim" method="post">

        <input type="hidden" name="action" id="action" value="save">

        <div class="card">

            <div class="row">
                <label>Claim Type</label>
                <input type="text" name="claimType" value="<%= claimType %>" readonly>
            </div>

            <div class="row">
                <label>Description</label>
                <textarea name="description"><%= description %></textarea>
            </div>

            <div class="row">
                <label>Total Amount (RM)</label>
                <input type="number" name="amount" step="0.01" value="<%= amount %>">
            </div>

            <div class="actions">
                <button type="submit" class="btn save"
                        onclick="document.getElementById('action').value='save'">
                    Save Draft
                </button>

                <button type="submit" class="btn submit"
                        onclick="document.getElementById('action').value='submit'">
                    Submit Claim
                </button>

                <a href="ViewClaimList.jsp" class="btn back">Cancel</a>
            </div>

        </div>

    </form>

</div>

</body>
</html>
