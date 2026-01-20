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
    <title>Create Medical Claim</title>
    <link rel="stylesheet" href="CSS/Medical.css">
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
        <i class="fa-solid fa-book-medical"></i>
        <h2>Medical Claim Form</h2>
    </div>

    <p class="claim-desc">
        Fill the required fields below to apply for medical reimbursement
    </p>

    <form id="medicalForm" action="SubmitClaim" method="post" enctype="multipart/form-data">
        <input type="hidden" name="action" id="action" value="save">

        <div class="form-group full">
            <label>Claim Type</label>
            <input type="text" name="claimType" value="Medical" readonly>
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
                <label>Clinic Name</label>
                <input type="text" name="clinicName" required>
            </div>

            <div class="form-group">
                <label>MRN Doctor (Number)</label>
                <input type="number" name="mrnDoctor" required>
            </div>
        </div>

        <div class="form-row">
            <div class="form-group">
                <label>Diseases</label>
                <select name="diagnosis" id="diseaseSelect" onchange="toggleOtherDisease()" required>
                    <option value="" disabled selected>-- Select Disease --</option>
                    <option value="flu">Flu</option>
                    <option value="fever">Fever</option>
                    <option value="cough">Cough</option>
                    <option value="others">Others</option>
                </select>
            </div>

            <div class="form-group">
                <label>Amount (RM)</label>
                <input type="number" id="amount" name="amount" step="0.01" required>
            </div>
        </div>

        <div class="form-group full" id="otherDiseaseGroup" style="display:none;">
            <label>Specify Other Disease</label>
            <input type="text" name="otherDiagnosis">
        </div>

        <div class="form-group full">
            <label>Claim Description</label>
            <textarea name="description" rows="3"></textarea>
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

        <div class="form-action-container">
            <div class="left-actions">
                <button type="button" class="btn-save" onclick="saveDraft()">Save</button>
                <button type="button" class="btn-submit" onclick="openModal()">Save And Submit</button>
            </div>
            <div class="right-actions">
                <button type="button" class="btn-cancel" onclick="cancelSubmission()">Cancel</button>
            </div>
        </div>

    </form>

</section>
</main>

<div id="submitModal" class="modal-overlay">
    <div class="modal-box">
        <div class="modal-icon">
            <i class="fa-solid fa-circle-question"></i>
        </div>
        <h2>Confirm Submission?</h2>
        <p>This claim will be sent for review. You cannot edit it after submitting.</p>
        <div class="modal-btns">
            <button class="btn-cancel" onclick="closeModal()">Go Back</button>
            <button class="btn-save" onclick="processFinalSubmit()">Yes, Submit</button>
        </div>
    </div>
</div>

<script>
function toggleOtherDisease() {
    const disease = document.getElementById("diseaseSelect").value;
    document.getElementById("otherDiseaseGroup").style.display =
        (disease === "others") ? "block" : "none";
}

/* Updated to accept 'input' */
function updateFileName(input) {
    const display = document.getElementById("fileNameDisplay");
    
    if (input.files && input.files.length > 0) {
        display.innerText = "Selected: " + input.files[0].name;
        display.style.color = "green";
    } else {
        display.innerText = "";
    }
}

function saveDraft() {
    alert("Your submission has been saved as draft.");
    document.getElementById("action").value = "save";
    document.getElementById("medicalForm").submit();
}

function openModal() {
    const amount = document.getElementById("amount").value;
    if(amount === "" || amount <= 0){
        alert("Please enter a valid amount before submitting.");
        return;
    }
    document.getElementById("submitModal").classList.add("active");
}

function closeModal() {
    document.getElementById("submitModal").classList.remove("active");
}

function processFinalSubmit() {
    closeModal();
    alert("Thank you for your submission.");
    document.getElementById("action").value = "submit";
    document.getElementById("medicalForm").submit();
}

function cancelSubmission() {
    if(confirm("Do you want to cancel the submission?")){
        document.getElementById("medicalForm").reset();
        document.getElementById("otherDiseaseGroup").style.display = "none";
        document.getElementById("fileNameDisplay").innerText = "";
    }
}
</script>
</body>
</html>