<%@ page import="model.Employee" %>
<%@ page session="true" %>
<%
    Employee emp = (Employee) session.getAttribute("employee");
    if(emp == null){
        response.sendRedirect("Login.jsp");
        return;
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Create Travel Claim</title>
    <link rel="stylesheet" href="CSS/Travel.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
</head>
<body>

<header class="top-nav">
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

<div class="breadcrumb">
    Dashboard &gt; Apply for Claim
</div>

<main class="page-container">

<section class="claim-card">

    <div class="claim-header">
        <i class="fa-solid fa-car-side"></i>
        <h2>Travel Claim Form</h2>
    </div>

    <p class="claim-desc">
        Fill the required fields below to apply for travel reimbursement
    </p>

    <form id="travelForm" action="SubmitClaim" method="post" enctype="multipart/form-data">
        <input type="hidden" name="action" id="action" value="save">

        <div class="form-group full">
            <label>Claim Type</label>
            <input type="text" name="claimType" value="Travel" readonly>
        </div>

        <div class="form-row">
            <div class="form-group">
                <label>Employee ID</label>
                <input type="text" name="employeeId" value="<%= emp.getEmpId() %>" readonly>
            </div>

            <div class="form-group">
                <label>Name</label>
                <input type="text" name="name" value="<%= emp.getName() %>" readonly>
            </div>
        </div>

        <div class="form-row">
            <div class="form-group">
                <label>Departure Dest. (Fixed)</label>
                <input type="text" name="departureDest" value="Ayer Keroh" readonly>
            </div>

            <div class="form-group">
                <label>Arrival Dest. State</label>
                <select name="arrivalDest" id="arrivalDest" required>
                    <option value="" disabled selected>-- Select Destination --</option>
                    <option value="Kuala Lumpur">Kuala Lumpur</option>
                    <option value="Selangor">Selangor</option>
                    <option value="P.Pinang">P.Pinang</option>
                    <option value="Johor">Johor</option>
                </select>
            </div>
        </div>

        <div class="form-row">
            <div class="form-group">
                <label>Mileage (KM)</label>
                <input type="number" name="mileage" id="mileage" step="0.1" placeholder="Enter distance" oninput="calculateDetails()" required>
            </div>

            <div class="form-group">
                <label>Rate per KM (Auto-Calculated)</label>
                <input type="number" name="ratePerKm" id="rate" step="0.01" readonly>
                
                <small class="hint">1-50km: RM0.70 | 51-200km: RM0.55 | >200km: RM0.45</small>
            </div>
        </div>

        <div class="form-group full">
            <label>Claim Description</label>
            <input type="text" name="description" placeholder="e.g. Project meeting at site office">
        </div>

        <div class="form-row">
            <div class="form-group">
                <label>Total Amount (RM)</label>
                <input type="number" id="amount" name="amount" step="0.01" placeholder="0.00" readonly class="highlight-total">
            </div>

            <div class="form-group">
                <label>Supporting Document</label>
                
                <input type="file" name="document" id="travelFileInput" style="display:none" onchange="updateFileName(this)">

                <label for="travelFileInput" class="btn-document">
                    <i class="fa-solid fa-paperclip"></i> Insert Document
                </label>

                <small id="fileNameDisplay" class="hint"></small>
            </div>
        </div>

        <div class="form-action-container">
            <div class="left-actions">
                <button type="button" class="btn-save" onclick="saveDraft()">Save</button>
                <button type="button" class="btn-submit" onclick="submitClaim()">Save And Submit</button>
            </div>
            <div class="right-actions">
                <button type="button" class="btn-cancel" onclick="cancelSubmission()">Cancel</button>
            </div>
        </div>

    </form>

</section>
</main>

<script>
/* ===== AUTOMATIC CALCULATION LOGIC ===== */
function calculateDetails() {
    const mileageInput = document.getElementById('mileage').value;
    const rateField = document.getElementById('rate');
    const amountField = document.getElementById('amount');

    let dist = parseFloat(mileageInput);
    let rate = 0;

    // ==========================================
    //  UPDATED RATES
    //  1-50km   -> 0.70
    //  51-200km -> 0.55
    //  >200km   -> 0.45
    // ==========================================
    if (isNaN(dist) || dist <= 0) {
        rate = 0;
    } else if (dist >= 1 && dist <= 50) {
        rate = 0.70;
    } else if (dist > 50 && dist <= 200) {
        rate = 0.55;
    } else if (dist > 200) {
        rate = 0.45;
    }

    // 2. Update Rate Field (Fixed to 2 decimal places)
    rateField.value = rate.toFixed(2);

    // 3. Calculate Total Amount (Rate * Mileage)
    if (dist > 0) {
        let total = dist * rate;
        amountField.value = total.toFixed(2);
    } else {
        amountField.value = "0.00";
    }
}

/* ===== FILE NAME DISPLAY ===== */
function updateFileName(input) {
    const display = document.getElementById('fileNameDisplay');
    if(input.files && input.files.length > 0){
        display.innerText = "Selected: " + input.files[0].name;
        display.style.color = "green";
    } else {
        display.innerText = "";
    }
}

/* ===== SAVE DRAFT ===== */
function saveDraft() {
    alert("Your submission has been saved as draft.");
    document.getElementById("action").value = "save";
    document.getElementById("travelForm").submit();
}

/* ===== FINAL SUBMIT ===== */
function submitClaim() {
    const amt = document.getElementById("amount").value;
    if(amt === "" || parseFloat(amt) <= 0) {
        alert("Please enter valid mileage to calculate the Total Amount.");
        return;
    }

    if(confirm("Are you sure you want to submit this claim? You cannot edit it afterwards.")) {
        alert("Thank you! Your claim has been submitted for review.");
        document.getElementById("action").value = "submit";
        document.getElementById("travelForm").submit();
    }
}

/* ===== CANCEL ===== */
function cancelSubmission() {
    if (confirm("Do you want to cancel the submission?")) {
        document.getElementById("travelForm").reset();
        document.getElementById('fileNameDisplay').innerText = "";
        document.getElementById('amount').value = "0.00";
        document.getElementById('rate').value = "";
    }
}
</script>

</body>
</html>