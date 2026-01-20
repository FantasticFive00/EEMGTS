package dao;

import java.util.List;

import model.Employee;

public interface EmployeeDAO {

    boolean registerEmployee(Employee employee);

    boolean isEmailExists(String email);
    
    Employee login(String email, String password);
    
    void assignManagerToDepartment(String empId, String departmentName);
    
     boolean updateEmployee(Employee emp);
     
     List<Employee> getEmployeesByDepartment(String department);

	 boolean deleteEmployeeById(String empId, String department);
}