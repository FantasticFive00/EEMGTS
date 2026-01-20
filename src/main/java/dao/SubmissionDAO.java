package dao;

import java.util.List;
import model.Submission;

public interface SubmissionDAO {

    boolean createSubmission(Submission submission);

    List<Submission> getDraftClaimsByEmployee(String employeeId);
    
    Submission getSubmissionById(int submissionId);

    boolean updateSubmission(Submission submission);

    boolean deleteSubmission(int submissionId, String employeeId);
    
    boolean submitDraft(int id, String employeeId);
    
    void updateStatus(int submissionId, String status);
    
    List<Submission> getSubmissionsByDepartment(String department);
    
    List<Submission> getSubmissionsForManager(String department);
    
    public List<Submission> getsubmissionsForManager(String department);
    
    List<Submission> getClaimsByEmployee(String employeeId);

	boolean deleteEmployee(String empId, String department);
	
	boolean updateStatusByManager(int submissionId, String status, String managerDept);

}
