<%@ page import="java.util.List" %>
<%@ page import="model.Employee" %>
<%@ page import="model.Submission" %>
<%@ page import="dao.SubmissionDAO" %>
<%@ page import="dao.SubmissionDAOImpl" %>
<%@ page session="true" %>

<%
    Employee emp = (Employee) session.getAttribute("employee");

    if (emp == null) {
        response.sendRedirect("Login.jsp");
        return;
    }
    SubmissionDAO dao = new SubmissionDAOImpl();
    List<Submission> claims = dao.getClaimsByEmployee(emp.getEmpId());
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>My Claim Status</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    
    <style>
        /* --- EMBEDDED CSS --- */
        
        /* Global Reset */
        * {
            box-sizing: border-box;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
        }

        body {
            background-color: #f3f4f6;
            margin: 0;
            padding: 40px 20px;
        }

        /* Layout */
        .page-container {
            max-width: 1000px;
            margin: 0 auto;
        }

        .header-text {
            margin-bottom: 25px;
        }

        .header-text h2 {
            color: #111827;
            margin-bottom: 5px;
            font-size: 24px;
        }

        .header-text p {
            color: #6b7280;
            margin: 0;
            font-size: 14px;
        }

        /* Back Button */
        .top-nav-area {
            margin-bottom: 20px;
        }

        .btn-back {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            text-decoration: none;
            color: #4b5563;
            font-weight: 600;
            font-size: 14px;
            transition: color 0.2s;
            background: white;
            padding: 8px 15px;
            border-radius: 6px;
            box-shadow: 0 1px 2px rgba(0,0,0,0.05);
        }

        .btn-back:hover {
            color: #2563eb;
            box-shadow: 0 4px 6px rgba(0,0,0,0.1);
        }

        /* Card Styling */
        .card {
            background: white;
            border-radius: 12px;
            box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06);
            overflow: hidden;
            border: 1px solid #e5e7eb;
        }

        /* Table Styling */
        .styled-table {
            width: 100%;
            border-collapse: collapse;
            text-align: left;
        }

        .styled-table thead {
            background-color: #f9fafb;
            border-bottom: 2px solid #e5e7eb;
        }

        .styled-table th {
            padding: 16px 20px;
            font-size: 13px;
            font-weight: 700;
            color: #374151;
            text-transform: uppercase;
            letter-spacing: 0.05em;
        }

        .styled-table td {
            padding: 16px 20px;
            border-bottom: 1px solid #f3f4f6;
            font-size: 14px;
            color: #1f2937;
            vertical-align: middle;
        }

        .styled-table tbody tr:hover {
            background-color: #f9fafb;
        }

        /* Column Specifics */
        .id-col {
            font-family: monospace;
            color: #6b7280 !important;
            font-weight: bold;
            width: 15%; /* Added width control */
        }

        .type-col i {
            margin-right: 8px;
            width: 20px;
            text-align: center;
        }

        /* Status Badges */
        .status-badge {
            display: inline-block;
            padding: 4px 12px;
            border-radius: 9999px;
            font-size: 12px;
            font-weight: 600;
            text-transform: uppercase;
        }

        .status-badge.approved { background-color: #d1fae5; color: #065f46; }
        .status-badge.rejected { background-color: #fee2e2; color: #991b1b; }
        .status-badge.submitted { background-color: #dbeafe; color: #1e40af; }
        .status-badge.draft { background-color: #f3f4f6; color: #4b5563; }

        /* Empty State */
        .empty-state {
            text-align: center;
            padding: 40px !important;
            color: #9ca3af;
        }
        .empty-state i {
            font-size: 32px;
            margin-bottom: 10px;
            display: block;
        }
    </style>
</head>

<body>

<div class="page-container">
    
    <div class="top-nav-area">
        <a href="Home.jsp" class="btn-back">
            <i class="fa-solid fa-arrow-left"></i> Back to Dashboard
        </a>
    </div>

    <div class="header-text">
        <h2>My Claim History</h2>
        <p>Track the current status of your submitted claims.</p>
    </div>

    <div class="card">
        <table class="styled-table">
            <thead>
                <tr>
                    <th>ID</th>
                    <th>Type</th>
                    <th>Date</th>
                    <th>Status</th>
                    </tr>
            </thead>

            <tbody>
            <% if (claims.isEmpty()) { %>
                <tr>
                    <td colspan="4" class="empty-state">
                        <i class="fa-regular fa-folder-open"></i>
                        <p>No claims found.</p>
                    </td>
                </tr>
            <% } else {
                for (Submission s : claims) { 
                    String status = s.getStatus();
                    if(status == null) status = "Draft"; 
            %>
                <tr>
                    <td class="id-col">#<%= s.getSubmissionId() %></td>
                    <td class="type-col">
                        <% if("Medical".equalsIgnoreCase(s.getClaimType())) { %>
                            <i class="fa-solid fa-notes-medical" style="color: #e11d48;"></i>
                        <% } else if("Travel".equalsIgnoreCase(s.getClaimType())) { %>
                            <i class="fa-solid fa-car-side" style="color: #2563eb;"></i>
                        <% } else { %>
                            <i class="fa-solid fa-clock" style="color: #d97706;"></i>
                        <% } %>
                        <%= s.getClaimType() %>
                    </td>
                    <td><%= s.getSubmissionDate() %></td>
                    <td>
                        <span class="status-badge <%= status.toLowerCase() %>">
                            <%= status %>
                        </span>
                    </td>
                    </tr>
            <% }} %>
            </tbody>
        </table>
    </div>
</div>

</body>
</html>
