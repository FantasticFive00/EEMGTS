<%@ page import="model.Employee" %>
<%
    Employee emp = (Employee) session.getAttribute("employee");
    if (emp == null) {
        response.sendRedirect("Login.jsp");
        return;
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Create Overtime Claim</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <link rel="stylesheet" href="CSS/Overtime.css">

    <link rel="stylesheet"
          href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
</head>

<body>

<header class="topbar">
    <div class="topbar-inner">
        <nav class="navlinks">
            <a href="Home.jsp" class="navlink">Dashboard</a>
            <a href="account-profile.jsp" class="navlink">Account Profile</a>
            <a href="#" class="navlink active">Create Claim</a>
        </nav>
    </div>
</header>

<main class="page">

    <div class="breadcrumb">Dashboard &gt; Apply for Claim</div>

    <section class="card">

        <div class="card-head">
            <i class="fa-solid fa-user-clock" style="font-size:2rem;"></i>
            <h1>Overtime Claim Form</h1>
            <p class="subtitle">
                Fill the required fields below to apply for overtime reimbursement
            </p>
        </div>

        <form id="overtimeForm"
              action="SubmitClaim"
              method="post"
              enctype="multipart/form-data">

            <input type="hidden" name="action" id="action">

            <div class="field">
                <label>Claim Type</label>
                <input type="hidden" name="claimType" value="Overtime">
            </div>

            <div class="grid-2">
                <div class="field">
                    <label>Employee ID</label>
                    <input type="text" name="employeeId" value="<%= emp.getEmpId() %>" readonly>
                </div>
                <div class="field">
                    <label>Name</label>
                    <input type="text" name="name" value="<%= emp.getName() %>" readonly>
                </div>
            </div>

            <div class="grid-2">
                <div class="field">
                    <label>Start Date</label>
                    <input type="date"
                           name="startTime"
                           id="startDate"
                           required
                           onchange="updateAmount()">
                </div>

                <div class="field">
                    <label>End Date</label>
                    <input type="date"
                           name="endTime"
                           id="endDate"
                           required
                           onchange="updateAmount()">
                </div>
            </div>

            <div class="grid-2">
                <div class="field">
                    <label>Hours per Day</label>
                    <select name="hours"
                            id="hours"
                            required
                            onchange="updateAmount()">
                        <option value="" disabled selected>Select hours</option>
                        <option value="1">1 Hour</option>
                        <option value="2">2 Hours</option>
                        <option value="3">3 Hours</option>
                        <option value="4">4 Hours</option>
                    </select>
                    <small class="hint">
                        Rate: <b>RM 10</b> per hour
                    </small>
                </div>

<div class="field">
                    <label>Supporting Document</label>

                    <input type="file"
                           name="document"
                           id="overtimeFileInput"
                           style="display:none"
                           onchange="updateFileName(this)">

                    <label for="overtimeFileInput"
                           class="btn-document"
                           style="display: inline-block; width: 100%; padding: 10px; background-color: #5dade2; color: white; text-align: center; border-radius: 4px; cursor: pointer;">
                        <i class="fa-solid fa-paperclip"></i> Insert Document
                    </label>

                    <small id="fileNameDisplay" class="hint"></small>
                </div>
            </div>

            <div class="field">
                <label>Claim Description</label>
                <textarea name="description"
                          rows="3"
                          placeholder="e.g. Project meeting at site office"></textarea>
            </div>

            <div class="field">
                <label>Total Amount (RM)</label>
                <input type="text" id="amount" name="amount" value="0.00" readonly>
            </div>

            <div class="form-action-container">
                <div class="left-actions">
                    <button type="button"
                            class="btn btn-save"
                            onclick="handleSave('save')">
                        Save
                    </button>

                    <button type="button"
                            class="btn btn-submit"
                            onclick="handleSave('submit')">
                        Save And Submit
                    </button>
                </div>

                <div class="right-actions">
                    <button type="button"
                            class="btn btn-cancel"
                            onclick="handleCancel()">
                        Cancel
                    </button>
                </div>
            </div>

        </form>
    </section>
</main>

<script>
const RATE_PER_HOUR = 10;

function setAction(type) {
    document.getElementById("action").value = type;
}

/* ===== SAVE / SUBMIT HANDLER ===== */
function handleSave(type) {
    setAction(type);

    if (type === "save") {
        alert("Your submission is saved as draft.");
    } else if (type === "submit") {
        alert("Thank you for your submission.");
    }

    // Submit form
    document.getElementById("overtimeForm").submit();
}

/* ===== CANCEL HANDLER ===== */
function handleCancel() {
    if (confirm("Do you want to cancel the submission?")) {
        window.location.href = "Home.jsp";
    }
}

/* ===== AMOUNT CALCULATION ===== */
function updateAmount() {
    const hours = Number(document.getElementById("hours").value || 0);
    const start = document.getElementById("startDate").value;
    const end = document.getElementById("endDate").value;

    if (start && end) {
        const d1 = new Date(start);
        const d2 = new Date(end);
        const days = Math.floor((d2 - d1) / (1000*60*60*24)) + 1;
        const total = days > 0 ? days * hours * RATE_PER_HOUR : 0;
        document.getElementById("amount").value = total.toFixed(2);
    }
}

/* ===== FILE NAME DISPLAY (FIXED) ===== */
function updateFileName(input) {
    const display = document.getElementById("fileNameDisplay");
    
    // Check if a file was selected
    if (input.files && input.files.length > 0) {
        display.innerText = "File: " + input.files[0].name;
        display.style.color = "green"; 
    } else {
        display.innerText = "";
    }
}
</script>
</body>
</html>

