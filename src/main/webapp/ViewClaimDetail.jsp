<%@ page import="java.sql.*" %>
    <%@ page import="model.Employee" %>
        <%@ page import="util.DatabaseConnection" %>
            <%@ page session="true" %>

                <% Employee emp=(Employee) session.getAttribute("employee"); if (emp==null) {
                    response.sendRedirect("Login.jsp"); return; } String submissionId=request.getParameter("id"); if
                    (submissionId==null) { response.sendRedirect("ViewClaim.jsp"); return; } Connection conn=null;
                    PreparedStatement ps=null; ResultSet rs=null; %>

                    <!DOCTYPE html>
                    <html lang="en">

                    <head>
                        <meta charset="UTF-8">
                        <title>Claim Details | EEMS</title>
                        <link rel="stylesheet" href="CSS/ViewClaimDetail.css">
                        <link rel="stylesheet"
                            href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
                    </head>

                    <body>

                        <div class="container">

                            <% try { conn=DatabaseConnection.getConnection(); String sql="SELECT s.*, "
                                + "m.CLINICNAME, m.MRNDOCTOR, m.DIAGNOSIS, " + "o.HOURS, o.STARTTIME, o.ENDTIME, "
                                + "t.MILEAGE, t.RATEPERKM, t.DEPARTUREDEST, t.ARRIVALDEST " + "FROM SUBMISSION s "
                                + "LEFT JOIN MEDICAL_CLAIM m ON s.SUBMISSIONID = m.SUBMISSIONID "
                                + "LEFT JOIN OVERTIME_CLAIM o ON s.SUBMISSIONID = o.SUBMISSIONID "
                                + "LEFT JOIN TRAVEL_CLAIM t ON s.SUBMISSIONID = t.SUBMISSIONID "
                                + "WHERE s.SUBMISSIONID = ? AND s.EMPLOYEEID = ?" ; ps=conn.prepareStatement(sql);
                                ps.setInt(1, Integer.parseInt(submissionId)); ps.setString(2, emp.getEmpId());
                                rs=ps.executeQuery(); if (rs.next()) { String type=rs.getString("CLAIMTYPE"); String
                                status=rs.getString("STATUS"); %>

                                <div class="detail-card">
                                    <div class="card-header">
                                        <div>
                                            <h2>
                                                <%= type %> Claim
                                            </h2>
                                            <div style="font-size: 13px; color: #6b7280; margin-top: 4px;">ID: #<%=
                                                    submissionId %>
                                            </div>
                                        </div>
                                        <span class="status-badge status-<%= status %>">
                                            <%= status %>
                                        </span>
                                    </div>

                                    <div class="card-body">

                                        <div class="section-title">General Information</div>
                                        <div class="grid-row">
                                            <div class="info-group">
                                                <label>Submission Date</label>
                                                <div class="value">
                                                    <%= rs.getDate("SUBMISSIONDATE") %>
                                                </div>
                                            </div>
                                            <div class="info-group">
                                                <label>Employee Name</label>
                                                <div class="value">
                                                    <%= emp.getName() %>
                                                </div>
                                            </div>
                                        </div>

                                        <div class="section-title">
                                            <%= type %> Details
                                        </div>
                                        <div class="grid-row">

                                            <% if ("Overtime".equalsIgnoreCase(type)) { %>
                                                <div class="info-group">
                                                    <label>Start Time</label>
                                                    <div class="value">
                                                        <%= rs.getTimestamp("STARTTIME") %>
                                                    </div>
                                                </div>
                                                <div class="info-group">
                                                    <label>End Time</label>
                                                    <div class="value">
                                                        <%= rs.getTimestamp("ENDTIME") %>
                                                    </div>
                                                </div>
                                                <div class="info-group">
                                                    <label>Total Hours</label>
                                                    <div class="value">
                                                        <%= rs.getInt("HOURS") %> Hours
                                                    </div>
                                                </div>
                                                <% } else if ("Medical".equalsIgnoreCase(type)) { %>
                                                    <div class="info-group">
                                                        <label>Clinic Name</label>
                                                        <div class="value">
                                                            <%= rs.getString("CLINICNAME") %>
                                                        </div>
                                                    </div>
                                                    <div class="info-group">
                                                        <label>Doctor Name</label>
                                                        <div class="value">
                                                            <%= rs.getString("MRNDOCTOR") %>
                                                        </div>
                                                    </div>
                                                    <div class="info-group">
                                                        <label>Diagnosis</label>
                                                        <div class="value" style="text-transform: capitalize;">
                                                            <%= rs.getString("DIAGNOSIS") %>
                                                        </div>
                                                    </div>
                                                    <% } else if ("Travel".equalsIgnoreCase(type)) { %>
                                                        <div class="info-group">
                                                            <label>From</label>
                                                            <div class="value">
                                                                <%= rs.getString("DEPARTUREDEST") %>
                                                            </div>
                                                        </div>
                                                        <div class="info-group">
                                                            <label>To</label>
                                                            <div class="value">
                                                                <%= rs.getString("ARRIVALDEST") %>
                                                            </div>
                                                        </div>
                                                        <div class="info-group">
                                                            <label>Mileage</label>
                                                            <div class="value">
                                                                <%= rs.getDouble("MILEAGE") %> KM
                                                            </div>
                                                        </div>
                                                        <div class="info-group">
                                                            <label>Rate</label>
                                                            <div class="value">RM <%= rs.getDouble("RATEPERKM") %>/km
                                                            </div>
                                                        </div>
                                                        <% } %>
                                        </div>

                                        <div class="section-title">Financial Summary</div>
                                        <div class="grid-row">
                                            <div class="info-group">
                                                <label>Total Claim Amount</label>
                                                <div class="value highlight">RM <%= String.format("%.2f",
                                                        rs.getDouble("AMOUNT")) %>
                                                </div>
                                            </div>
                                        </div>

                                        <div class="info-group">
                                            <label>Description / Remarks</label>
                                            <div class="desc-box">
                                                <%= rs.getString("CLAIM_DESC") !=null ? rs.getString("CLAIM_DESC")
                                                    : "No description provided." %>
                                            </div>
                                        </div>

                                        <br>

                                        <div class="section-title">Attachments</div>
                                        <% String doc=rs.getString("DOCUMENT_PATH"); if (doc !=null && !doc.isEmpty()) {
                                            %>
                                            <a href="DownloadServlet?filename=<%= doc %>" target="_blank"
                                                class="btn-download" style="text-decoration: none; color: #2563eb;">
                                                <i class="fa-solid fa-file-pdf"></i> View Supporting Document
                                            </a>
                                            <% } else { %>
                                                <span style="color: #9ca3af; font-style: italic;">No document
                                                    attached.</span>
                                                <% } %>

                                    </div>

                                    <div class="card-footer">
                                        <a href="ViewClaim.jsp" class="btn-back">
                                            <i class="fa-solid fa-arrow-left"></i> Back to List
                                        </a>
                                    </div>
                                </div>

                                <% } else { %>
                                    <div style="text-align: center; margin-top: 50px;">
                                        <h3 style="color: red;">Claim Not Found</h3>
                                        <p>This claim ID does not exist or does not belong to you.</p>
                                        <a href="ViewClaim.jsp" class="btn-back">Go Back</a>
                                    </div>
                                    <% } } catch (Exception e) { e.printStackTrace(); %>
                                        <div style="text-align: center; margin-top: 50px; color: red;">
                                            <h3>Error Occurred</h3>
                                            <p>
                                                <%= e.getMessage() %>
                                            </p>
                                            <a href="ViewClaim.jsp" class="btn-back">Go Back</a>
                                        </div>
                                        <% } finally { if (rs !=null) try { rs.close(); } catch (SQLException e) {} if
                                            (ps !=null) try { ps.close(); } catch (SQLException e) {} if (conn !=null)
                                            try { conn.close(); } catch (SQLException e) {} } %>

                        </div>

                    </body>

                    </html>