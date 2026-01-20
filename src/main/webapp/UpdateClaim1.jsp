<%@ page import="java.sql.*" %>
    <%@ page import="model.Employee" %>
        <%@ page import="util.DatabaseConnection" %>
            <%@ page session="true" %>

                <% Employee emp=(Employee) session.getAttribute("employee"); if (emp==null) {
                    response.sendRedirect("Login.jsp"); return; } String employeeId=emp.getEmpId(); String
                    submissionId=request.getParameter("id"); if (submissionId==null) {
                    response.sendRedirect("ViewClaim.jsp"); return; } Connection conn=null; PreparedStatement ps=null;
                    ResultSet rs=null; %>

                    <!DOCTYPE html>
                    <html lang="en">

                    <head>
                        <meta charset="UTF-8">
                        <meta name="viewport" content="width=device-width, initial-scale=1.0">
                        <title>Update Claim | EEMS</title>
                        <link rel="stylesheet" href="CSS/UpdateClaim1.css">
                        <link rel="stylesheet"
                            href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
                    </head>

                    <body>

                        <div class="page">
                            <div class="header-container">
                                <h2>Update Claim Details</h2>
                                <p>Review and modify your submission information below</p>
                            </div>

                            <% try { conn=DatabaseConnection.getConnection(); String sql="SELECT s.*, "
                                + "m.CLINICNAME, m.MRNDOCTOR, m.DIAGNOSIS, " + "o.HOURS, o.STARTTIME, o.ENDTIME, "
                                + "t.MILEAGE, t.RATEPERKM, t.DEPARTUREDEST, t.ARRIVALDEST " + "FROM SUBMISSION s "
                                + "LEFT JOIN MEDICAL_CLAIM m ON s.SUBMISSIONID = m.SUBMISSIONID "
                                + "LEFT JOIN OVERTIME_CLAIM o ON s.SUBMISSIONID = o.SUBMISSIONID "
                                + "LEFT JOIN TRAVEL_CLAIM t ON s.SUBMISSIONID = t.SUBMISSIONID "
                                + "WHERE s.SUBMISSIONID = ? AND s.EMPLOYEEID = ?" ; ps=conn.prepareStatement(sql);
                                ps.setInt(1, Integer.parseInt(submissionId)); ps.setString(2, employeeId);
                                rs=ps.executeQuery(); if (!rs.next()) { %>
                                <div class="card" style="text-align: center; padding: 50px;">
                                    <i class="fa-solid fa-triangle-exclamation"
                                        style="font-size: 40px; color: #ef4444; margin-bottom: 20px;"></i>
                                    <h3 style="color: #374151;">Claim Not Found</h3>
                                    <p style="color: #6b7280; margin-bottom: 20px;">The claim does not exist or you
                                        cannot access it.</p>
                                    <a href="ViewClaim.jsp" class="btn btn-update"
                                        style="display:inline-block; width:auto;">Return to Dashboard</a>
                                </div>
                                <% } else { String type=rs.getString("CLAIMTYPE"); String status=rs.getString("STATUS");
                                    String statusColor="DRAFT" .equalsIgnoreCase(status) ? "#d97706" : "#2563eb" ;
                                    String startVal="" ; String endVal="" ; if (rs.getTimestamp("STARTTIME") !=null) {
                                    startVal=rs.getTimestamp("STARTTIME").toString().substring(0, 10); } if
                                    (rs.getTimestamp("ENDTIME") !=null) {
                                    endVal=rs.getTimestamp("ENDTIME").toString().substring(0, 10); } %>

                                    <div class="card">
                                        <form action="SubmitClaim" method="post" enctype="multipart/form-data">

                                            <input type="hidden" name="action" value="update">
                                            <input type="hidden" name="submissionId" value="<%= submissionId %>">
                                            <input type="hidden" name="claimType" value="<%= type %>">

                                            <div class="form-section-title">Submission Information</div>

                                            <div class="form-grid">
                                                <div class="form-group">
                                                    <label><i class="fa-solid fa-tag"></i> Claim Type</label>
                                                    <input type="text" value="<%= type %>" readonly>
                                                </div>

                                                <div class="form-group">
                                                    <label><i class="fa-solid fa-circle-info"></i> Current
                                                        Status</label>
                                                    <input type="text" value="<%= status %>" readonly
                                                        style="color: <%= statusColor %>; font-weight: bold;">
                                                </div>
                                            </div>

                                            <div class="form-section-title">
                                                <%= type %> Details
                                            </div>

                                            <% if ("Overtime".equalsIgnoreCase(type)) { int hours=rs.getInt("HOURS"); %>
                                                <div class="form-grid">
                                                    <div class="form-group">
                                                        <label><i class="fa-regular fa-calendar"></i> Start Date</label>
                                                        <input type="date" name="startTime" value="<%= startVal %>"
                                                            required>
                                                    </div>
                                                    <div class="form-group">
                                                        <label><i class="fa-regular fa-calendar-check"></i> End
                                                            Date</label>
                                                        <input type="date" name="endTime" value="<%= endVal %>"
                                                            required>
                                                    </div>
                                                    <div class="form-group full-width">
                                                        <label><i class="fa-regular fa-clock"></i> Hours per Day</label>
                                                        <select name="hours">
                                                            <option value="1" <%=hours==1 ? "selected" : "" %>>1 Hour
                                                            </option>
                                                            <option value="2" <%=hours==2 ? "selected" : "" %>>2 Hours
                                                            </option>
                                                            <option value="3" <%=hours==3 ? "selected" : "" %>>3 Hours
                                                            </option>
                                                            <option value="4" <%=hours==4 ? "selected" : "" %>>4 Hours
                                                            </option>
                                                        </select>
                                                    </div>
                                                </div>
                                                <% } else if ("Medical".equalsIgnoreCase(type)) { String
                                                    clinicName=rs.getString("CLINICNAME"); String
                                                    mrnDoctor=rs.getString("MRNDOCTOR"); String
                                                    diagnosis=rs.getString("DIAGNOSIS"); %>
                                                    <div class="form-grid">
                                                        <div class="form-group">
                                                            <label><i class="fa-solid fa-hospital"></i> Clinic
                                                                Name</label>
                                                            <input type="text" name="clinicName"
                                                                value="<%= clinicName %>" required>
                                                        </div>
                                                        <div class="form-group">
                                                            <label><i class="fa-solid fa-user-doctor"></i> MRN
                                                                Doctor</label>
                                                            <input type="text" name="mrnDoctor" value="<%= mrnDoctor %>"
                                                                required>
                                                        </div>
                                                        <div class="form-group full-width">
                                                            <label><i class="fa-solid fa-stethoscope"></i>
                                                                Diagnosis</label>
                                                            <select name="diagnosis">
                                                                <option value="flu" <%="flu" .equals(diagnosis)
                                                                    ? "selected" : "" %>>Flu</option>
                                                                <option value="fever" <%="fever" .equals(diagnosis)
                                                                    ? "selected" : "" %>>Fever</option>
                                                                <option value="cough" <%="cough" .equals(diagnosis)
                                                                    ? "selected" : "" %>>Cough</option>
                                                                <option value="others" <%="others" .equals(diagnosis)
                                                                    ? "selected" : "" %>>Others</option>
                                                            </select>
                                                        </div>
                                                    </div>
                                                    <% } else if ("Travel".equalsIgnoreCase(type)) { String
                                                        departureDest=rs.getString("DEPARTUREDEST"); String
                                                        arrivalDest=rs.getString("ARRIVALDEST"); double
                                                        mileage=rs.getDouble("MILEAGE"); double
                                                        ratePerKm=rs.getDouble("RATEPERKM"); %>
                                                        <div class="form-grid">
                                                            <div class="form-group">
                                                                <label><i class="fa-solid fa-plane-departure"></i>
                                                                    Departure</label>
                                                                <input type="text" name="departureDest"
                                                                    value="<%= departureDest %>" required>
                                                            </div>
                                                            <div class="form-group">
                                                                <label><i class="fa-solid fa-plane-arrival"></i>
                                                                    Arrival</label>
                                                                <select name="arrivalDest">
                                                                    <option value="Ayer Keroh" <%="Ayer Keroh"
                                                                        .equals(arrivalDest) ? "selected" : "" %>>Ayer
                                                                        Keroh</option>
                                                                    <option value="Kajang" <%="Kajang"
                                                                        .equals(arrivalDest) ? "selected" : "" %>>Kajang
                                                                    </option>
                                                                    <option value="Simpang Ampat" <%="Simpang Ampat"
                                                                        .equals(arrivalDest) ? "selected" : "" %>
                                                                        >Simpang Ampat</option>
                                                                    <option value="Petaling Jaya" <%="Petaling Jaya"
                                                                        .equals(arrivalDest) ? "selected" : "" %>
                                                                        >Petaling Jaya</option>
                                                                </select>
                                                            </div>
                                                            <div class="form-group">
                                                                <label><i class="fa-solid fa-road"></i> Mileage
                                                                    (KM)</label>
                                                                <input type="number" name="mileage" step="0.1"
                                                                    value="<%= mileage %>">
                                                            </div>
                                                            <div class="form-group">
                                                                <label><i class="fa-solid fa-coins"></i> Rate Per
                                                                    KM</label>
                                                                <input type="number" name="ratePerKm" step="0.01"
                                                                    value="<%= ratePerKm %>">
                                                            </div>
                                                        </div>
                                                        <% } double amount=rs.getDouble("AMOUNT"); String
                                                            claimDesc=rs.getString("CLAIM_DESC"); String
                                                            doc=rs.getString("DOCUMENT_PATH"); %>

                                                            <div class="form-section-title">Claim Summary</div>

                                                            <div class="form-group">
                                                                <label><i class="fa-solid fa-money-bill-wave"></i> Total
                                                                    Amount (RM)</label>
                                                                <input type="number" name="amount" step="0.01"
                                                                    value="<%= amount %>" required
                                                                    style="font-size: 18px; font-weight: bold; color: #111827;">
                                                            </div>

                                                            <div class="form-group">
                                                                <label><i class="fa-solid fa-align-left"></i>
                                                                    Description</label>
                                                                <textarea name="description"
                                                                    placeholder="Enter details..."><%= claimDesc != null ? claimDesc : "" %></textarea>
                                                            </div>

                                                            <div class="form-group file-upload-box">
                                                                <label style="margin-bottom: 15px;"><i
                                                                        class="fa-solid fa-paperclip"></i> Supporting
                                                                    Document</label>
                                                                <% if (doc !=null && !doc.isEmpty()) { %>
                                                                    <div style="margin-bottom: 10px;">
                                                                        <a href="DownloadServlet?filename=<%= doc %>"
                                                                            target="_blank"
                                                                            style="color: blue; text-decoration: underline;">
                                                                            <i class="fa-regular fa-file-pdf"></i> View
                                                                            Current Document
                                                                        </a>
                                                                    </div>
                                                                    <% } else { %>
                                                                        <p
                                                                            style="color: #9ca3af; font-size: 13px; margin-bottom: 10px;">
                                                                            No document currently uploaded</p>
                                                                        <% } %>
                                                                            <input type="file" name="document"
                                                                                id="uploadFile">
                                                            </div>

                                                            <div class="button-group">
                                                                <a href="ViewClaim.jsp"
                                                                    class="btn btn-cancel">Cancel</a>
                                                                <button type="submit" class="btn btn-update">
                                                                    <i class="fa-solid fa-floppy-disk"
                                                                        style="margin-right:8px;"></i> Save Changes
                                                                </button>
                                                            </div>
                                        </form>
                                    </div>
                                    <% } } catch (Exception e) { e.printStackTrace(); %>
                                        <div class="card" style="border-left: 5px solid red;">
                                            <h3>System Error</h3>
                                            <p>
                                                <%= e.getMessage() %>
                                            </p>
                                            <a href="ViewClaim.jsp">Back</a>
                                        </div>
                                        <% } finally { if (rs !=null) try { rs.close(); } catch (SQLException e) {} if
                                            (ps !=null) try { ps.close(); } catch (SQLException e) {} if (conn !=null)
                                            try { conn.close(); } catch (SQLException e) {} } %>
                        </div>
                    </body>

                    </html>