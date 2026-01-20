package servlet;

import java.io.File;
import java.io.IOException;
import java.sql.Timestamp;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;

import dao.SubmissionDAO;
import dao.SubmissionDAOImpl;
import model.Employee;
import model.Submission;

@WebServlet("/SubmitClaim")
@MultipartConfig(fileSizeThreshold = 1024 * 1024 * 2, // 2MB
        maxFileSize = 1024 * 1024 * 10, // 10MB
        maxRequestSize = 1024 * 1024 * 50 // 50MB
)
public class SubmitClaimServlet extends HttpServlet {

    private SubmissionDAO dao = new SubmissionDAOImpl();
    private static final String UPLOAD_DIR = "uploads";

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // 1. Security Check
        HttpSession session = request.getSession(false);
        Employee emp = (session != null) ? (Employee) session.getAttribute("employee") : null;
        if (emp == null) {
            response.sendRedirect("Login.jsp");
            return;
        }

        // 2. Get Parameters
        String action = request.getParameter("action"); // "save", "submit", or "update"
        String claimType = request.getParameter("claimType"); // "Medical", "Travel", etc.
        String submissionIdStr = request.getParameter("submissionId");

        // 3. Prepare Object
        Submission s = new Submission();
        s.setEmployeeId(emp.getEmpId());
        s.setClaimType(claimType);

        // ==========================================
        // FIX: CHECK ACTION TO SET STATUS
        // ==========================================
        if ("submit".equalsIgnoreCase(action)) {
            s.setStatus("PENDING"); // User clicked "Save & Submit"
        } else {
            s.setStatus("DRAFT"); // User clicked "Save" (Default)
        }

        try {
            // Common Fields
            double amount = Double.parseDouble(request.getParameter("amount"));
            s.setAmount(amount);
            s.setClaimDesc(request.getParameter("description"));

            // ================= HANDLE FILE UPLOAD =================
            String fileName = processFileUpload(request);

            // CHECK IF CREATE OR UPDATE
            boolean isUpdate = (submissionIdStr != null && !submissionIdStr.isEmpty());

            if (isUpdate) {
                int id = Integer.parseInt(submissionIdStr);
                s.setSubmissionId(id);

                // Keep old file if no new one uploaded
                if (fileName == null || fileName.isEmpty()) {
                    Submission oldData = dao.getSubmissionById(id);
                    if (oldData != null) {
                        fileName = oldData.getDocumentPath();
                    }
                }
            }
            s.setDocumentPath(fileName);

            // ================= HANDLE CHILD TABLES =================
            if ("Medical".equalsIgnoreCase(claimType)) {
                s.setClinicName(request.getParameter("clinicName"));
                s.setMrnDoctor(request.getParameter("mrnDoctor"));

                // Handle "Others" diagnosis logic
                String diagnosis = request.getParameter("diagnosis");
                if ("others".equalsIgnoreCase(diagnosis)) {
                    diagnosis = request.getParameter("otherDiagnosis");
                }
                s.setDiagnosis(diagnosis);
            } else if ("Travel".equalsIgnoreCase(claimType)) {
                s.setDepartureDest(request.getParameter("departureDest"));
                s.setArrivalDest(request.getParameter("arrivalDest"));

                String mileStr = request.getParameter("mileage");
                if (mileStr != null && !mileStr.isEmpty())
                    s.setMileage(Double.parseDouble(mileStr));

                String rateStr = request.getParameter("ratePerKm");
                if (rateStr != null && !rateStr.isEmpty())
                    s.setRatePerKm(Double.parseDouble(rateStr));
            } else if ("Overtime".equalsIgnoreCase(claimType)) {
                s.setHours(Integer.parseInt(request.getParameter("hours")));

                String startStr = request.getParameter("startTime");
                String endStr = request.getParameter("endTime");

                // Fix: Ensure time component exists for Timestamp conversion
                if (startStr != null && !startStr.isEmpty()) {
                    if (!startStr.contains(":"))
                        startStr += " 09:00:00";
                    s.setStartTime(Timestamp.valueOf(startStr));
                }
                if (endStr != null && !endStr.isEmpty()) {
                    if (!endStr.contains(":"))
                        endStr += " 18:00:00";
                    s.setEndTime(Timestamp.valueOf(endStr));
                }
                s.setRatePerHours(15.00);
            }

            // ================= SAVE TO DATABASE =================
            boolean success = false;

            if (isUpdate) {
                success = dao.updateSubmission(s);
            } else {
                success = dao.createSubmission(s);
            }

            if (success) {
                response.sendRedirect("ViewClaim.jsp?msg=saved");
            } else {
                response.sendRedirect("ViewClaim.jsp?error=failed");
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("ViewClaim.jsp?error=" + e.getMessage());
        }
    }

    // Helper method to handle file upload
    private String processFileUpload(HttpServletRequest request) throws IOException, ServletException {
        Part filePart = request.getPart("document");
        if (filePart != null && filePart.getSize() > 0) {
            String fileName = getFileName(filePart);
            String uploadPath = getServletContext().getRealPath("") + File.separator + UPLOAD_DIR;
            File uploadDir = new File(uploadPath);
            if (!uploadDir.exists())
                uploadDir.mkdir();

            filePart.write(uploadPath + File.separator + fileName);
            return fileName;
        }
        return null;
    }

    private String getFileName(Part part) {
        for (String content : part.getHeader("content-disposition").split(";")) {
            if (content.trim().startsWith("filename")) {
                return content.substring(content.indexOf("=") + 2, content.length() - 1);
            }
        }
        return "unknown_file";
    }
}