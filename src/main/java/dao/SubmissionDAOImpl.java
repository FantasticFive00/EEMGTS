package dao;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import model.Submission;
import util.DatabaseConnection;

public class SubmissionDAOImpl implements SubmissionDAO {

    // ================= 1. CREATE SUBMISSION (TRANSACTION) =================
    @Override
    public boolean createSubmission(Submission s) {
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DatabaseConnection.getConnection();
            conn.setAutoCommit(false); // Start Transaction

            // STEP 1: Insert into Parent Table (SUBMISSION)
            String sqlParent = "INSERT INTO SUBMISSION " +
                    "(EMPLOYEEID, CLAIMTYPE, SUBMISSIONDATE, CLAIM_DESC, STATUS, AMOUNT, DOCUMENT_PATH) " +
                    "VALUES (?, ?, CURRENT_DATE, ?, ?, ?, ?)";

            // We need to return the generated SUBMISSIONID
            ps = conn.prepareStatement(sqlParent, Statement.RETURN_GENERATED_KEYS);
            ps.setString(1, s.getEmployeeId());
            ps.setString(2, s.getClaimType());
            ps.setString(3, s.getClaimDesc());
            ps.setString(4, s.getStatus());
            ps.setDouble(5, s.getAmount());
            ps.setString(6, s.getDocumentPath());

            int rows = ps.executeUpdate();
            if (rows == 0)
                throw new SQLException("Creating submission failed, no rows affected.");

            // Get the Generated ID
            rs = ps.getGeneratedKeys();
            int newId = 0;
            if (rs.next()) {
                newId = rs.getInt(1);
            } else {
                // Fallback for Oracle versions that don't return keys nicely
                // You might need a sequence query here if this fails
            }

            // STEP 2: Insert into Child Table based on Type
            if ("Medical".equalsIgnoreCase(s.getClaimType())) {
                String sqlMed = "INSERT INTO MEDICAL_CLAIM (SUBMISSIONID, CLINICNAME, MRNDOCTOR, DIAGNOSIS) VALUES (?, ?, ?, ?)";
                try (PreparedStatement psChild = conn.prepareStatement(sqlMed)) {
                    psChild.setInt(1, newId);
                    psChild.setString(2, s.getClinicName());
                    psChild.setString(3, s.getMrnDoctor());
                    psChild.setString(4, s.getDiagnosis());
                    psChild.executeUpdate();
                }
            } else if ("Overtime".equalsIgnoreCase(s.getClaimType())) {
                String sqlOT = "INSERT INTO OVERTIME_CLAIM (SUBMISSIONID, HOURS, STARTTIME, ENDTIME, RATEPERHOURS) VALUES (?, ?, ?, ?, ?)";
                try (PreparedStatement psChild = conn.prepareStatement(sqlOT)) {
                    psChild.setInt(1, newId);
                    psChild.setInt(2, s.getHours());
                    psChild.setTimestamp(3, s.getStartTime());
                    psChild.setTimestamp(4, s.getEndTime());
                    psChild.setDouble(5, s.getRatePerHours());
                    psChild.executeUpdate();
                }
            } else if ("Travel".equalsIgnoreCase(s.getClaimType())) {
                String sqlTravel = "INSERT INTO TRAVEL_CLAIM (SUBMISSIONID, DEPARTUREDEST, ARRIVALDEST, MILEAGE, RATEPERKM) VALUES (?, ?, ?, ?, ?)";
                try (PreparedStatement psChild = conn.prepareStatement(sqlTravel)) {
                    psChild.setInt(1, newId);
                    psChild.setString(2, s.getDepartureDest());
                    psChild.setString(3, s.getArrivalDest());
                    psChild.setDouble(4, s.getMileage());
                    psChild.setDouble(5, s.getRatePerKm());
                    psChild.executeUpdate();
                }
            }

            conn.commit(); // Save Everything
            return true;

        } catch (Exception e) {
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (SQLException ex) {
                    ex.printStackTrace();
                }
            }
            e.printStackTrace();
            return false;
        } finally {
            try {
                if (rs != null)
                    rs.close();
            } catch (Exception e) {
            }
            try {
                if (ps != null)
                    ps.close();
            } catch (Exception e) {
            }
            try {
                if (conn != null)
                    conn.close();
            } catch (Exception e) {
            }
        }
    }

    // ================= 2. GET SUBMISSION BY ID (JOINED) =================
    @Override
    public Submission getSubmissionById(int id) {
        Submission s = null;

        // This Query Joins ALL tables so we get the data regardless of type
        String sql = "SELECT s.*, " +
                "m.CLINICNAME, m.MRNDOCTOR, m.DIAGNOSIS, " +
                "o.HOURS, o.STARTTIME, o.ENDTIME, o.RATEPERHOURS, " +
                "t.DEPARTUREDEST, t.ARRIVALDEST, t.MILEAGE, t.RATEPERKM " +
                "FROM SUBMISSION s " +
                "LEFT JOIN MEDICAL_CLAIM m ON s.SUBMISSIONID = m.SUBMISSIONID " +
                "LEFT JOIN OVERTIME_CLAIM o ON s.SUBMISSIONID = o.SUBMISSIONID " +
                "LEFT JOIN TRAVEL_CLAIM t ON s.SUBMISSIONID = t.SUBMISSIONID " +
                "WHERE s.SUBMISSIONID = ?";

        try (Connection conn = DatabaseConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, id);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                s = new Submission();
                // Common Fields
                s.setSubmissionId(rs.getInt("SUBMISSIONID"));
                s.setEmployeeId(rs.getString("EMPLOYEEID"));
                s.setClaimType(rs.getString("CLAIMTYPE"));
                s.setSubmissionDate(rs.getDate("SUBMISSIONDATE"));
                s.setClaimDesc(rs.getString("CLAIM_DESC"));
                s.setStatus(rs.getString("STATUS"));
                s.setAmount(rs.getDouble("AMOUNT"));
                s.setDocumentPath(rs.getString("DOCUMENT_PATH"));

                // Specific Fields (Only populated if they exist in that row)
                if ("Medical".equalsIgnoreCase(s.getClaimType())) {
                    s.setClinicName(rs.getString("CLINICNAME"));
                    s.setDiagnosis(rs.getString("DIAGNOSIS"));
                    s.setMrnDoctor(rs.getString("MRNDOCTOR"));
                } else if ("Overtime".equalsIgnoreCase(s.getClaimType())) {
                    s.setHours(rs.getInt("HOURS"));
                    s.setRatePerHours(rs.getDouble("RATEPERHOURS"));
                    s.setStartTime(rs.getTimestamp("STARTTIME"));
                    s.setEndTime(rs.getTimestamp("ENDTIME"));
                } else if ("Travel".equalsIgnoreCase(s.getClaimType())) {
                    s.setMileage(rs.getDouble("MILEAGE"));
                    s.setRatePerKm(rs.getDouble("RATEPERKM"));
                    s.setDepartureDest(rs.getString("DEPARTUREDEST"));
                    s.setArrivalDest(rs.getString("ARRIVALDEST"));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return s;
    }

    // ================= 3. GET DRAFTS =================
    @Override
    public List<Submission> getDraftClaimsByEmployee(String employeeId) {
        List<Submission> list = new ArrayList<>();
        String sql = "SELECT SUBMISSIONID, CLAIMTYPE, SUBMISSIONDATE, STATUS " +
                "FROM SUBMISSION WHERE EMPLOYEEID = ? AND STATUS = 'DRAFT' " +
                "ORDER BY SUBMISSIONDATE DESC";

        try (Connection conn = DatabaseConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, employeeId);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                Submission s = new Submission();
                s.setSubmissionId(rs.getInt("SUBMISSIONID"));
                s.setClaimType(rs.getString("CLAIMTYPE"));
                s.setSubmissionDate(rs.getDate("SUBMISSIONDATE"));
                s.setStatus(rs.getString("STATUS"));
                list.add(s);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    // ================= 4. MANAGER VIEW (FIXED for EmployeeID) =================
    @Override
    public List<Submission> getSubmissionsForManager(String managerDeptId) {
        List<Submission> list = new ArrayList<>();

        // Use 'e.EMPLOYEEID' not 'e.EMPID'
        String sql = "SELECT s.SUBMISSIONID, s.EMPLOYEEID, s.SUBMISSIONDATE, " +
                "s.CLAIMTYPE, s.STATUS, s.AMOUNT, e.NAME as EMP_NAME " +
                "FROM SUBMISSION s " +
                "JOIN EMPLOYEE e ON s.EMPLOYEEID = e.EMPLOYEEID " +
                "WHERE e.DEPTID = ? " +
                "AND s.STATUS = 'PENDING' " +
                "ORDER BY s.SUBMISSIONDATE DESC";

        // DEBUG: Print query info
        System.out.println("=== MANAGER QUERY DEBUG ===");
        System.out.println("SQL: " + sql);
        System.out.println("DeptID Parameter: " + managerDeptId);

        try (Connection conn = DatabaseConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, managerDeptId);
            ResultSet rs = ps.executeQuery();

            int count = 0;
            while (rs.next()) {
                Submission s = new Submission();
                s.setSubmissionId(rs.getInt("SUBMISSIONID"));
                s.setEmployeeId(rs.getString("EMPLOYEEID"));
                s.setSubmissionDate(rs.getDate("SUBMISSIONDATE"));
                s.setClaimType(rs.getString("CLAIMTYPE"));
                s.setStatus(rs.getString("STATUS"));
                s.setAmount(rs.getDouble("AMOUNT"));
                list.add(s);
                count++;

                // DEBUG: Print each found claim
                System.out.println("Found claim #" + s.getSubmissionId() +
                        " by " + s.getEmployeeId() +
                        " - Status: " + s.getStatus());
            }

            System.out.println("Total claims found: " + count);
            System.out.println("=========================");
        } catch (Exception e) {
            System.err.println("ERROR in getSubmissionsForManager: " + e.getMessage());
            e.printStackTrace();
        }
        return list;
    }

    // ================= 5. MANAGER APPROVE/REJECT =================
    @Override
    public boolean updateStatusByManager(int submissionId, String status, String managerDeptId) {
        String sql = "UPDATE SUBMISSION SET STATUS = ? " +
                "WHERE SUBMISSIONID = ? " +
                "AND EMPLOYEEID IN (SELECT EMPLOYEEID FROM EMPLOYEE WHERE DEPTID = ?)";

        try (Connection conn = DatabaseConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, status);
            ps.setInt(2, submissionId);
            ps.setString(3, managerDeptId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    // ================= 6. DELETE EMPLOYEE (FIXED ID NAME) =================
    @Override
    public boolean deleteEmployee(String empId, String managerDeptId) {
        // Corrected to use EMPLOYEEID
        String sql = "DELETE FROM EMPLOYEE WHERE EMPLOYEEID = ? AND DEPTID = ?";

        try (Connection conn = DatabaseConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, empId);
            ps.setString(2, managerDeptId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace(); // Likely foreign key issue if Cascade isn't set
        }
        return false;
    }

    // ================= 7. SUBMIT DRAFT =================
    // ================= SUBMIT DRAFT (Update Status to PENDING) =================
    @Override
    public boolean submitDraft(int id, String employeeId) {
        String sql = "UPDATE SUBMISSION SET STATUS='PENDING' WHERE SUBMISSIONID=? AND EMPLOYEEID=?";

        try (java.sql.Connection conn = util.DatabaseConnection.getConnection();
                java.sql.PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, id);
            ps.setString(2, employeeId); // Security: Ensures users can only submit THEIR OWN claims

            int rows = ps.executeUpdate();
            return rows > 0; // Returns true if the update happened

        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    // ================= 8. UPDATE SUBMISSION (COMPLEX) =================
    // Note: To fully support editing with inheritance, you'd need logic similar
    // to createSubmission (Update Parent, then Update Child).
    // For now, this updates common fields.
    // ================= 8. UPDATE SUBMISSION (FIXED FOR CHILD TABLES)
    // =================
    @Override
    public boolean updateSubmission(Submission s) {
        Connection conn = null;
        PreparedStatement ps = null;

        try {
            conn = DatabaseConnection.getConnection();
            conn.setAutoCommit(false); // 1. Start Transaction

            // STEP 1: Update Parent Table (SUBMISSION)
            // We update Description, Doc Path, and Amount
            String sqlParent = "UPDATE SUBMISSION SET CLAIM_DESC=?, DOCUMENT_PATH=?, AMOUNT=? WHERE SUBMISSIONID=?";

            ps = conn.prepareStatement(sqlParent);
            ps.setString(1, s.getClaimDesc());
            ps.setString(2, s.getDocumentPath());
            ps.setDouble(3, s.getAmount());
            ps.setInt(4, s.getSubmissionId());

            int rows = ps.executeUpdate();
            if (rows == 0) {
                // If parent update failed, stop here
                throw new SQLException("Update failed, submission ID not found.");
            }
            ps.close(); // Close this statement to reuse variable

            // STEP 2: Update Child Table based on Type
            // We use the Claim Type stored in the object to decide which table to edit
            if ("Medical".equalsIgnoreCase(s.getClaimType())) {
                String sqlMed = "UPDATE MEDICAL SET CLINICNAME=?, DIAGNOSIS=?, MRNDOCTOR=? WHERE SUBMISSIONID=?";
                ps = conn.prepareStatement(sqlMed);
                ps.setString(1, s.getClinicName());
                ps.setString(2, s.getDiagnosis());
                ps.setString(3, s.getMrnDoctor());
                ps.setInt(4, s.getSubmissionId());
                ps.executeUpdate();
            } else if ("Overtime".equalsIgnoreCase(s.getClaimType())) {
                String sqlOT = "UPDATE OVERTIME SET HOURS=?, RATEPERHOURS=?, STARTTIME=?, ENDTIME=? WHERE SUBMISSIONID=?";
                ps = conn.prepareStatement(sqlOT);
                ps.setInt(1, s.getHours());
                ps.setDouble(2, s.getRatePerHours());
                ps.setTimestamp(3, s.getStartTime());
                ps.setTimestamp(4, s.getEndTime());
                ps.setInt(5, s.getSubmissionId());
                ps.executeUpdate();
            } else if ("Travel".equalsIgnoreCase(s.getClaimType())) {
                String sqlTravel = "UPDATE TRAVEL SET MILEAGE=?, RATEPERKM=?, DEPARTUREDEST=?, ARRIVALDEST=? WHERE SUBMISSIONID=?";
                ps = conn.prepareStatement(sqlTravel);
                ps.setDouble(1, s.getMileage());
                ps.setDouble(2, s.getRatePerKm());
                ps.setString(3, s.getDepartureDest());
                ps.setString(4, s.getArrivalDest());
                ps.setInt(5, s.getSubmissionId());
                ps.executeUpdate();
            }

            conn.commit(); // 3. Save All Changes
            return true;

        } catch (Exception e) {
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (SQLException ex) {
                    ex.printStackTrace();
                }
            }
            e.printStackTrace();
            return false;
        } finally {
            try {
                if (ps != null)
                    ps.close();
            } catch (Exception e) {
            }
            try {
                if (conn != null)
                    conn.close();
            } catch (Exception e) {
            }
        }
    }

    // ================= 9. GET CLAIMS BY EMPLOYEE =================
    @Override
    public List<Submission> getClaimsByEmployee(String employeeId) {
        List<Submission> list = new ArrayList<>();
        String sql = "SELECT SUBMISSIONID, CLAIMTYPE, SUBMISSIONDATE, STATUS " +
                "FROM SUBMISSION WHERE EMPLOYEEID=? ORDER BY SUBMISSIONDATE DESC";
        try (Connection conn = DatabaseConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, employeeId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Submission s = new Submission();
                s.setSubmissionId(rs.getInt("SUBMISSIONID"));
                s.setClaimType(rs.getString("CLAIMTYPE"));
                s.setSubmissionDate(rs.getDate("SUBMISSIONDATE"));
                s.setStatus(rs.getString("STATUS"));
                list.add(s);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    // Unused / Placeholder Methods
    @Override
    public void updateStatus(int submissionId, String status) {
    }

    @Override
    public List<Submission> getSubmissionsByDepartment(String department) {
        return null;
    }

    @Override
    public List<Submission> getsubmissionsForManager(String department) {
        return null;
    }

    @Override
    public boolean deleteSubmission(int id, String employeeId) {
        return false;
    }
}