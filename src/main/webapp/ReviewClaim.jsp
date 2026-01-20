<%@ page import="java.sql.*" %>
    <%@ page import="model.Employee" %>
        <%@ page import="util.DatabaseConnection" %>
            <%@ page session="true" %>

                <% Employee currentUser=(Employee) session.getAttribute("employee"); if (currentUser==null) {
                    response.sendRedirect("Login.jsp"); return; } if
                    (!"Manager".equalsIgnoreCase(currentUser.getRole())) { response.sendRedirect("AccessDenied.jsp");
                    return; } String submissionId=request.getParameter("id"); if (submissionId==null) {
                    response.sendRedirect("ManagerSubmissionList.jsp"); return; } Connection conn=null;
                    PreparedStatement ps=null; ResultSet rs=null; %>

                    <!DOCTYPE html>
                    <html lang="en">

                    <head>
                        <meta charset="UTF-8">
                        <title>Review Claim | EEMS</title>
                        <link rel="stylesheet" href="CSS/ReviewClaim.css">
                        <link rel="stylesheet"
                            href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
                    </head>

                    <body>

                        <div class="page-container">

                            <div class="header-container">
                                <div>
                                    <h2>Review Submission #<%= submissionId %>
                                    </h2>
                                    <p>Please review the details below before approving.</p>
                                </div>
                                <a href="ManagerSubmissionList.jsp" class="btn btn-back">
                                    <i class="fa-solid fa-arrow-left"></i> Back
                                </a>
                            </div>

                            <% try { conn=DatabaseConnection.getConnection(); String
                                sql="SELECT s.*, e.NAME as EMP_NAME, " + "m.CLINICNAME, m.MRNDOCTOR, m.DIAGNOSIS, "
                                + "o.HOURS, o.STARTTIME, o.ENDTIME, " + "t.DEPARTUREDEST, t.ARRIVALDEST, t.MILEAGE "
                                + "FROM SUBMISSION s " + "JOIN EMPLOYEE e ON s.EMPLOYEEID = e.EMPLOYEEID "
                                + "LEFT JOIN MEDICAL_CLAIM m ON s.SUBMISSIONID = m.SUBMISSIONID "
                                + "LEFT JOIN OVERTIME_CLAIM o ON s.SUBMISSIONID = o.SUBMISSIONID "
                                + "LEFT JOIN TRAVEL_CLAIM t ON s.SUBMISSIONID = t.SUBMISSIONID "
                                + "WHERE s.SUBMISSIONID = ?" ; ps=conn.prepareStatement(sql); ps.setInt(1,
                                Integer.parseInt(submissionId)); rs=ps.executeQuery(); if (!rs.next()) { %>
                                <div class="review-card" style="text-align: center; color: #D32F2F;">
                                    <h3><i class="fa-solid fa-triangle-exclamation"></i> Claim Not Found</h3>
                                    <p>The claim ID #<%= submissionId %> does not exist.</p>
                                    <br>
                                    <a href="ManagerSubmissionList.jsp" class="btn btn-back">Return to Dashboard</a>
                                </div>
                                <% } else { String type=rs.getString("CLAIMTYPE"); String status=rs.getString("STATUS");
                                    String doc=rs.getString("DOCUMENT_PATH"); %>

                                    <div class="review-card">

                                        <div class="section-title"><i class="fa-regular fa-id-card"></i> Applicant
                                            Information</div>
                                        <div class="info-grid">
                                            <div class="info-item">
                                                <label>Employee Name</label>
                                                <div class="value">
                                                    <%= rs.getString("EMP_NAME") %>
                                                </div>
                                            </div>
                                            <div class="info-item">
                                                <label>Submission Date</label>
                                                <div class="value">
                                                    <%= rs.getDate("SUBMISSIONDATE") %>
                                                </div>
                                            </div>
                                        </div>

                                        <div class="section-title"><i class="fa-solid fa-list-check"></i>
                                            <%= type %> Details
                                        </div>
                                        <div class="info-grid">

                                            <% if ("Travel".equalsIgnoreCase(type)) { %>
                                                <div class="info-item">
                                                    <label>From</label>
                                                    <div class="value">
                                                        <%= rs.getString("DEPARTUREDEST") %>
                                                    </div>
                                                </div>
                                                <div class="info-item">
                                                    <label>To</label>
                                                    <div class="value">
                                                        <%= rs.getString("ARRIVALDEST") %>
                                                    </div>
                                                </div>
                                                <div class="info-item">
                                                    <label>Total Distance</label>
                                                    <div class="value">
                                                        <%= rs.getDouble("MILEAGE") %> KM
                                                    </div>
                                                </div>
                                                <% } else if ("Medical".equalsIgnoreCase(type)) { %>
                                                    <div class="info-item">
                                                        <label>Clinic Name</label>
                                                        <div class="value">
                                                            <%= rs.getString("CLINICNAME") %>
                                                        </div>
                                                    </div>
                                                    <div class="info-item">
                                                        <label>Doctor</label>
                                                        <div class="value">
                                                            <%= rs.getString("MRNDOCTOR") %>
                                                        </div>
                                                    </div>
                                                    <div class="info-item full-width">
                                                        <label>Diagnosis</label>
                                                        <div class="value">
                                                            <%= rs.getString("DIAGNOSIS") %>
                                                        </div>
                                                    </div>
                                                    <% } else if ("Overtime".equalsIgnoreCase(type)) { %>
                                                        <div class="info-item">
                                                            <label>Start Time</label>
                                                            <div class="value">
                                                                <%= rs.getTimestamp("STARTTIME") %>
                                                            </div>
                                                        </div>
                                                        <div class="info-item">
                                                            <label>End Time</label>
                                                            <div class="value">
                                                                <%= rs.getTimestamp("ENDTIME") %>
                                                            </div>
                                                        </div>
                                                        <div class="info-item">
                                                            <label>Total Duration</label>
                                                            <div class="value">
                                                                <%= rs.getInt("HOURS") %> Hours
                                                            </div>
                                                        </div>
                                                        <% } %>
                                        </div>

                                        <div class="section-title"><i class="fa-solid fa-file-invoice-dollar"></i> Claim
                                            Summary</div>
                                        <div class="info-grid">
                                            <div class="info-item">
                                                <label>Amount Requested</label>
                                                <div class="value" style="color: #2E3A8C; font-size: 1.2rem;">
                                                    RM <%= String.format("%.2f", rs.getDouble("AMOUNT")) %>
                                                </div>
                                            </div>
                                            <div class="info-item">
                                                <label>Current Status</label>
                                                <div>
                                                    <span class="status-badge status-<%= status %>">
                                                        <%= status %>
                                                    </span>
                                                </div>
                                            </div>
                                            <div class="info-item full-width">
                                                <label>Description / Remarks</label>
                                                <div class="value" style="font-weight: normal; color: #555;">
                                                    <%= rs.getString("CLAIM_DESC") !=null ? rs.getString("CLAIM_DESC")
                                                        : "No description provided." %>
                                                </div>
                                            </div>

                                            <div class="info-item full-width">
                                                <label>Supporting Document</label>
                                                <% if (doc !=null && !doc.isEmpty()) { %>
                                                    <a href="DownloadServlet?filename=<%= doc %>" target="_blank"
                                                        class="doc-link">
                                                        <i class="fa-solid fa-paperclip"></i> View Attachment
                                                    </a>
                                                    <% } else { %>
                                                        <span style="color: #999; font-style: italic;">No document
                                                            attached.</span>
                                                        <% } %>
                                            </div>
                                        </div>

                                        <% if ("SUBMITTED".equalsIgnoreCase(status)) { %>
                                            <div class="action-bar">
                                                <form action="ManagerActionServlet" method="post"
                                                    style="display:inline;">
                                                    <input type="hidden" name="submissionId"
                                                        value="<%= submissionId %>">
                                                    <input type="hidden" name="action" value="approve">
                                                    <button type="submit" class="btn btn-approve">
                                                        <i class="fa-solid fa-check"></i> Approve Claim
                                                    </button>
                                                </form>

                                                <form action="ManagerActionServlet" method="post"
                                                    style="display:inline;">
                                                    <input type="hidden" name="submissionId"
                                                        value="<%= submissionId %>">
                                                    <input type="hidden" name="action" value="reject">
                                                    <button type="submit" class="btn btn-reject"
                                                        onclick="return confirm('Are you sure you want to REJECT this claim?');">
                                                        <i class="fa-solid fa-xmark"></i> Reject Claim
                                                    </button>
                                                </form>
                                            </div>
                                            <% } %>

                                    </div>
                                    <% } } catch (Exception e) { e.printStackTrace(); %>
                                        <p style="color:red; text-align:center;">Error: <%= e.getMessage() %>
                                        </p>
                                        <% } finally { if (rs !=null) try { rs.close(); } catch (SQLException e) {} if
                                            (ps !=null) try { ps.close(); } catch (SQLException e) {} if (conn !=null)
                                            try { conn.close(); } catch (SQLException e) {} } %>
                        </div>

                    </body>

                    </html>