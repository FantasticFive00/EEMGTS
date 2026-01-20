package model;

public class Employee {

    private String empId;
    private String name;
    private String role;
    private String email;
    private String phone;
    private String password;
    
    // We only need the ID now. The text name (e.g. "Finance") lives in the DB.
    private String deptId; 

    // --- Getters & Setters ---

    public String getEmpId() { return empId; }
    public void setEmpId(String empId) { this.empId = empId; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public String getRole() { return role; }
    public void setRole(String role) { this.role = role; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public String getPhone() { return phone; }
    public void setPhone(String phone) { this.phone = phone; }

    public String getPassword() { return password; }
    public void setPassword(String password) { this.password = password; }

    // FIXED: Naming is now consistent (getDeptId / setDeptId)
    public String getDeptId() { return deptId; }
    public void setDeptId(String deptId) { this.deptId = deptId; }
}