package model;

import java.sql.Timestamp;
import java.util.Date;

public class Submission {

    private int submissionId;
    private String employeeId;
    private String employeeName;
    private String claimType;
    private Date submissionDate;
    private Double Amount;

    // Status & Description
    private String status; // DRAFT / PENDING / APPROVED / REJECTED
    private String claimDesc; // Claim description
    private String documentPath; // File path

    // Overtime
    private Integer hours;
    private Double ratePerHours;
    private Timestamp startTime;
    private Timestamp endTime;

    // Travel
    private Double mileage;
    private Double ratePerKm;
    private String departureDest;
    private String arrivalDest;

    // Medical
    private String clinicName;
    private String diagnosis;
    private String mrnDoctor;

    // ===== GETTERS & SETTERS =====

    public int getSubmissionId() {
        return submissionId;
    }

    public void setSubmissionId(int submissionId) {
        this.submissionId = submissionId;
    }

    public String getEmployeeId() {
        return employeeId;
    }

    public void setEmployeeId(String employeeId) {
        this.employeeId = employeeId;
    }

    public String getClaimType() {
        return claimType;
    }

    public void setClaimType(String claimType) {
        this.claimType = claimType;
    }

    public Date getSubmissionDate() {
        return submissionDate;
    }

    public void setSubmissionDate(Date submissionDate) {
        this.submissionDate = submissionDate;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getClaimDesc() {
        return claimDesc;
    }

    public void setClaimDesc(String claimDesc) {
        this.claimDesc = claimDesc;
    }

    public String getDocumentPath() {
        return documentPath;
    }

    public void setDocumentPath(String documentPath) {
        this.documentPath = documentPath;
    }

    public Integer getHours() {
        return hours;
    }

    public void setHours(Integer hours) {
        this.hours = hours;
    }

    public Double getRatePerHours() {
        return ratePerHours;
    }

    public void setRatePerHours(Double ratePerHours) {
        this.ratePerHours = ratePerHours;
    }

    public Timestamp getStartTime() {
        return startTime;
    }

    public void setStartTime(Timestamp startTime) {
        this.startTime = startTime;
    }

    public Timestamp getEndTime() {
        return endTime;
    }

    public void setEndTime(Timestamp endTime) {
        this.endTime = endTime;
    }

    public Double getMileage() {
        return mileage;
    }

    public void setMileage(Double mileage) {
        this.mileage = mileage;
    }

    public Double getRatePerKm() {
        return ratePerKm;
    }

    public void setRatePerKm(Double ratePerKm) {
        this.ratePerKm = ratePerKm;
    }

    public String getDepartureDest() {
        return departureDest;
    }

    public void setDepartureDest(String departureDest) {
        this.departureDest = departureDest;
    }

    public String getArrivalDest() {
        return arrivalDest;
    }

    public void setArrivalDest(String arrivalDest) {
        this.arrivalDest = arrivalDest;
    }

    public String getClinicName() {
        return clinicName;
    }

    public void setClinicName(String clinicName) {
        this.clinicName = clinicName;
    }

    public String getDiagnosis() {
        return diagnosis;
    }

    public void setDiagnosis(String diagnosis) {
        this.diagnosis = diagnosis;
    }

    public String getMrnDoctor() {
        return mrnDoctor;
    }

    public void setMrnDoctor(String mrnDoctor) {
        this.mrnDoctor = mrnDoctor;
    }

    public Double getAmount() {
        return Amount;
    }

    public void setAmount(Double amount) {
        Amount = amount;
    }

    public String getEmployeeName() {
        return employeeName;
    }

    public void setEmployeeName(String employeeName) {
        this.employeeName = employeeName;
    }

}
