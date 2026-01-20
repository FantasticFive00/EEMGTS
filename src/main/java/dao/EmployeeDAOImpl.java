package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import model.Employee;
import util.DatabaseConnection;

public class EmployeeDAOImpl implements EmployeeDAO {

    @Override
    public boolean isEmailExists(String email) {
        String sql = "SELECT 1 FROM EMPLOYEE WHERE EMAIL = ?";
        try (Connection con = DatabaseConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, email);
            ResultSet rs = ps.executeQuery();
            return rs.next();
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    @Override
    public boolean registerEmployee(Employee emp) {
        // FIXED: Now inserting into DEPTID, not DEPARTMENT
        String sql = "INSERT INTO EMPLOYEE " +
                "(EMPLOYEEID, NAME, ROLE, DEPTID, PHONE, EMAIL, PASSWORD) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?)";

        try (Connection con = DatabaseConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, emp.getEmpId());
            ps.setString(2, emp.getName());
            ps.setString(3, emp.getRole());

            // FIXED: Make sure your Employee model uses getDeptID() (matching your Servlet)
            ps.setString(4, emp.getDeptId());

            ps.setString(5, emp.getPhone());
            ps.setString(6, emp.getEmail());
            ps.setString(7, emp.getPassword());

            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    @Override
    public Employee login(String email, String password) {
        Employee emp = null;
        String sql = "SELECT * FROM EMPLOYEE WHERE EMAIL = ? AND PASSWORD = ?";

        System.out.println("=== DAO LOGIN QUERY ===");
        System.out.println("SQL: " + sql);
        System.out.println("Email param: " + email);
        System.out.println("Password param: " + password);

        try (Connection con = DatabaseConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, email);
            ps.setString(2, password);

            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                emp = new Employee();
                emp.setEmpId(rs.getString("EMPLOYEEID"));
                emp.setName(rs.getString("NAME"));
                emp.setRole(rs.getString("ROLE"));

                // FIXED: Retrieve the ID from the database
                emp.setDeptId(rs.getString("DEPTID"));

                emp.setEmail(rs.getString("EMAIL"));
                emp.setPhone(rs.getString("PHONE"));

                System.out.println("Employee found in DB: " + emp.getName() + " (Role: " + emp.getRole() + ")");
            } else {
                System.out.println("No employee found with these credentials");
            }
            System.out.println("======================");

        } catch (Exception e) {
            System.err.println("ERROR in login: " + e.getMessage());
            e.printStackTrace();
        }
        return emp;
    }

    @Override
    public void assignManagerToDepartment(String empId, String deptId) {
        // FIXED: Update based on DEPTID (e.g., 'D01'), not text name
        String sql = "UPDATE DEPARTMENT SET MANAGER_ID = ? WHERE DEPTID = ?";

        try (Connection con = DatabaseConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, empId);
            ps.setString(2, deptId);
            ps.executeUpdate();

        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    @Override
    public boolean updateEmployee(Employee e) {
        String sql = "UPDATE EMPLOYEE SET DEPTID=?, EMAIL=?, PHONE=?, PASSWORD=? WHERE EMPLOYEEID=?";

        try (Connection conn = DatabaseConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, e.getDeptId());
            ps.setString(2, e.getEmail());
            ps.setString(3, e.getPhone());
            ps.setString(4, e.getPassword());
            ps.setString(5, e.getEmpId()); // WHERE clause

            int rows = ps.executeUpdate();
            return rows > 0;

        } catch (Exception ex) {
            ex.printStackTrace();
            return false;
        }
    }

    @Override
    public List<Employee> getEmployeesByDepartment(String deptId) {
        List<Employee> list = new ArrayList<>();
        // FIXED: Filter by DEPTID
        String sql = "SELECT EMPLOYEEID, NAME, ROLE, PHONE, EMAIL " +
                "FROM EMPLOYEE " +
                "WHERE DEPTID = ?";

        try (Connection conn = DatabaseConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, deptId);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                Employee e = new Employee();
                e.setEmpId(rs.getString("EMPLOYEEID"));
                e.setName(rs.getString("NAME"));
                e.setRole(rs.getString("ROLE"));
                e.setPhone(rs.getString("PHONE"));
                e.setEmail(rs.getString("EMAIL"));

                // We know the DeptID is what we searched for
                e.setDeptId(deptId);

                list.add(e);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    @Override
    public boolean deleteEmployeeById(String empId, String deptId) {
        // FIXED: Filter by DEPTID
        String sql = "DELETE FROM EMPLOYEE WHERE EMPLOYEEID = ? AND DEPTID = ?";

        try (Connection conn = DatabaseConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, empId);
            ps.setString(2, deptId);

            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }
}
