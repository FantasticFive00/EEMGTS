package servlet;

import java.io.File;
import java.io.IOException;
import java.sql.Timestamp;

import dao.SubmissionDAO;
import dao.SubmissionDAOImpl;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;
import model.Employee;
import model.Submission;

@WebServlet("/Submission")
@MultipartConfig(fileSizeThreshold = 1024 * 1024, // 1MB
        maxFileSize = 5 * 1024 * 1024, // 5MB
        maxRequestSize = 10 * 1024 * 1024 // 10MB
)
public class SubmissionServlet extends HttpServlet {

    private final SubmissionDAO submissionDAO = new SubmissionDAOImpl();
    // FIXED DIRECTORY for storing files
    private static final String UPLOAD_DIR = "C:/EEMS_Uploads";

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // ===== 1. SESSION CHECK =====
        HttpSession session = request.getSession(false);
        Employee emp = (session != null) ? (Employee) session.getAttribute("employee") : null;

        if (emp == null) {
            response.sendRedirect("Login.jsp");
            return;
        }

        // ===== 2. GET ACTION & ID =====
        String action = request.getParameter("action");
        // "save" (draft), "submit" (final), or "update" (edit draft)
        if (action == null || action.isEmpty())
            action = "save";

        // Check if we are updating an existing claim
        Integer submissionId = parseInt(request.getParameter("submissionId"));
        boolean isUpdate = (submissionId != null && submissionId > 0);

        // ===== 3. BUILD SUBMISSION OBJECT =====
        Submission s = new Submission();
        if (isUpdate) {
            s.setSubmissionId(submissionId);
        }

        s.setEmployeeId(emp.getEmpId());
        s.setClaimType(request.getParameter("claimType"));
        s.setAmount(parseDouble(request.getParameter("amount")));
        s.setHours(parseInt(request.getParameter("hours")));
        s.setRatePerHours(10.0);
        s.setClaimDesc(request.getParameter("description"));
        s.setClinicName(request.getParameter("clinicName"));
        s.setDiagnosis(request.getParameter("diagnosis"));
        s.setMrnDoctor(request.getParameter("mrnDoctor"));
        s.setDepartureDest(request.getParameter("departureDest"));
        s.setArrivalDest(request.getParameter("arrivalDest"));
        s.setMileage(parseDouble(request.getParameter("mileage")));
        s.setRatePerKm(parseDouble(request.getParameter("ratePerKm")));

        // Determine Status
        // If user clicks "Save & Submit", status becomes PENDING
        // Otherwise (Save Draft / Update Draft), it stays DRAFT
        if ("submit".equalsIgnoreCase(action)) {
            s.setStatus("PENDING");
        } else {
            s.setStatus("DRAFT");
        }

        // Dates
        s.setStartTime(parseDate(request.getParameter("startTime")));
        s.setEndTime(parseDate(request.getParameter("endTime")));

        // ===== 4. FILE UPLOAD LOGIC =====

        // Ensure upload directory exists
        File dir = new File(UPLOAD_DIR);
        if (!dir.exists()) {
            dir.mkdirs();
        }

        Part filePart = request.getPart("document");

        // Case A: User selected a NEW file
        if (filePart != null && filePart.getSize() > 0) {
            String originalName = getSubmittedFileName(filePart);
            String uniqueFileName = emp.getEmpId() + "_" + System.currentTimeMillis() + "_" + originalName;

            // Write file to disk
            String fullSavePath = UPLOAD_DIR + File.separator + uniqueFileName;
            filePart.write(fullSavePath);

            s.setDocumentPath(uniqueFileName);

            // Case B: No new file, but we are UPDATING (Keep the old file)
        } else if (isUpdate) {
            // Fetch the existing claim from DB to get the old filename
            Submission oldSubmission = submissionDAO.getSubmissionById(submissionId);
            if (oldSubmission != null) {
                s.setDocumentPath(oldSubmission.getDocumentPath());
            }
        }
        // Case C: New claim, no file -> documentPath remains null

        // ===== 5. SAVE TO DATABASE =====
        boolean success;
        if (isUpdate) {
            success = submissionDAO.updateSubmission(s); // You must have this method in DAO
        } else {
            success = submissionDAO.createSubmission(s);
        }

        // ===== 6. REDIRECT =====
        if (success) {
            response.sendRedirect("ViewClaim.jsp?msg=" + (isUpdate ? "Updated" : "Saved"));
        } else {
            request.setAttribute("error", "Database Error. Please try again.");
            request.getRequestDispatcher("Home.jsp").forward(request, response);
        }
    }

    // ===== HELPERS =====

    // Fix for getting filename in standard Servlet API
    private String getSubmittedFileName(Part part) {
        for (String cd : part.getHeader("content-disposition").split(";")) {
            if (cd.trim().startsWith("filename")) {
                return cd.substring(cd.indexOf('=') + 1).trim().replace("\"", "");
            }
        }
        return "unknown.pdf";
    }

    private Integer parseInt(String v) {
        try {
            return (v == null || v.isEmpty()) ? null : Integer.parseInt(v);
        } catch (NumberFormatException e) {
            return null;
        }
    }

    private Double parseDouble(String v) {
        try {
            return (v == null || v.isEmpty()) ? null : Double.parseDouble(v);
        } catch (NumberFormatException e) {
            return null;
        }
    }

    private Timestamp parseDate(String v) {
        if (v == null || v.isEmpty())
            return null;
        try {
            return Timestamp.valueOf(v + " 00:00:00");
        } catch (IllegalArgumentException e) {
            return null;
        }
    }
}
