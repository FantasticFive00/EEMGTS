<%@ page import="java.sql.*" %>
<%@ page import="model.Employee" %>
<%@ page session="true" %>

<%
    Employee emp = (Employee) session.getAttribute("employee");
    if (emp == null) {
        response.sendRedirect("Login.jsp");
        return;
    }

    String employeeId = emp.getEmpId();

    String dbURL = "jdbc:postgresql://localhost:5432/eems";
    String dbUser = "postgres";
    String dbPass = "oracle";

    Connection conn = null;
    PreparedStatement ps = null;
    ResultSet rs = null;
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>View Claim</title>
    <link rel="stylesheet" href="CSS/ViewClaim.css">
</head>

<body>

<div class="page">
<div class="top-nav-area">
        <a href="Home.jsp" class="btn-back-home">
            <i class="fa-solid fa-arrow-left"></i> Back to Dashboard
        </a>
    </div>

    <h2 class="page-title">Your Claim</h2>

    <div class="card">
        <h3>Claim List</h3>

        <table class="claim-table">
            <thead>
                <tr>
                    <th>Claim Type</th>
                    <th>Date</th>
                    <th>Status</th>
                    <th>Actions</th>
                </tr>
            </thead>

            <tbody>
            <%
                try {
                    Class.forName("org.postgresql.Driver");
                    conn = DriverManager.getConnection(dbURL, dbUser, dbPass);

                    String sql =
                        "SELECT SUBMISSIONID, CLAIMTYPE, SUBMISSIONDATE, STATUS " +
                        "FROM SUBMISSION " +
                        "WHERE EMPLOYEEID = ? " +
                        "ORDER BY SUBMISSIONDATE DESC";

                    ps = conn.prepareStatement(sql);
                    ps.setString(1, employeeId);
                    rs = ps.executeQuery();

                    boolean hasData = false;

                    while (rs.next()) {
                        hasData = true;
                        int id = rs.getInt("SUBMISSIONID");
                        String type = rs.getString("CLAIMTYPE");
                        String status = rs.getString("STATUS");
            %>
                <tr>
                    <td><%= type %></td>
                    <td><%= rs.getDate("SUBMISSIONDATE") %></td>
                    <td class="status <%= status.toLowerCase() %>">
                        <%= status %>
                    </td>
                    <td>

                        <!-- VIEW CLAIM (always allowed) -->
                        <a href="ViewClaimDetail.jsp?id=<%= id %>"
                           class="btn blue">
                            View Claim
                        </a>

                        <!-- UPDATE CLAIM (Draft only) -->
                        <% if ("Draft".equalsIgnoreCase(status)) { %>
                            <a href="UpdateClaim1.jsp?id=<%= id %>"
                               class="btn blue">
                                Update Claim
                            </a>
                        <% } else { %>
                            <button class="btn disabled" disabled>
                                Update Claim
                            </button>
                        <% } %>

                        <!-- SUBMIT CLAIM (Draft only) -->
<% if ("Draft".equalsIgnoreCase(status)) { %>
                            
                            <form action="SubmitDraftServlet" method="post" style="display:inline;">
                                <input type="hidden" name="submissionId" value="<%= id %>">
                                
                                <button type="submit" class="btn green" 
                                        onclick="return confirm('Are you sure you want to submit? You cannot edit this claim after submitting.');">
                                    Submit Claim
                                </button>
                            </form>

                        <% } else { %>
                            
                            <button class="btn disabled" disabled>
                                Submit Claim
                            </button>

                        <% } %>

                    </td>
                </tr>
            <%
                    }

                    if (!hasData) {
            %>
                <tr>
                    <td colspan="4" style="text-align:center; color:#777;">
                        No claims submitted yet.
                    </td>
                </tr>
            <%
                    }

                } catch (Exception e) {
            %>
                <tr>
                    <td colspan="4" style="color:red;">
                        Error loading claims: <%= e.getMessage() %>
                    </td>
                </tr>
            <%
                } finally {
                    if (rs != null) rs.close();
                    if (ps != null) ps.close();
                    if (conn != null) conn.close();
                }
            %>
            </tbody>

        </table>

    </div>

</div>

</body>
</html>

