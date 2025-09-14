import 'dart:async';
import 'package:phenikaa_university_management/database/database_helper.dart';
import 'package:phenikaa_university_management/config/logger.dart';


class UniversityService {
  static UniversityService? _instance;
  static UniversityService get instance {
    _instance ??= UniversityService._internal();
    return _instance!;
  }
  UniversityService._internal();

  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // Statistics and Analytics
  Future<Map<String, int>> getUniversityStatistics() async {
    try {
      final conn = await _dbHelper.connection;
      final result = await conn.query('CALL GetUniversityStatistics()');
      
      if (result.isNotEmpty) {
        final row = result.first;
        return {
          'total_schools': row['total_schools'] ?? 0,
          'total_departments': row['total_departments'] ?? 0,
          'total_active_majors': row['total_active_majors'] ?? 0,
          'total_active_employees': row['total_active_employees'] ?? 0,
          'total_active_students': row['total_active_students'] ?? 0,
        };
      }
      return {};
    } catch (e) {
      logger.e('Error getting statistics: $e');
      return {};
    }
  }

  // Advanced School Operations
  Future<Map<String, dynamic>?> getSchoolWithDetails(String schoolId) async {
    try {
      final conn = await _dbHelper.connection;
      
      // Get school info
      final schoolResult = await conn.query(
        'SELECT * FROM schools WHERE id = ?', [schoolId]);
      
      if (schoolResult.isEmpty) return null;
      
      final school = schoolResult.first;
      
      // Get departments with major count
      final departmentsResult = await conn.query('''
        SELECT 
          d.*,
          COUNT(m.id) as major_count,
          COUNT(e.id) as employee_count
        FROM departments d
        LEFT JOIN majors m ON d.id = m.department_id AND m.is_active = TRUE
        LEFT JOIN employees e ON d.id = e.department_id AND e.is_active = TRUE
        WHERE d.school_id = ?
        GROUP BY d.id
        ORDER BY d.name
      ''', [schoolId]);

      return {
        'id': school['id'],
        'name': school['name'],
        'short_name': school['short_name'],
        'description': school['description'],
        'dean_name': school['dean_name'],
        'phone': school['phone'],
        'email': school['email'],
        'departments': departmentsResult.map((row) => {
          'id': row['id'],
          'name': row['name'],
          'description': row['description'],
          'head_name': row['head_name'],
          'major_count': row['major_count'],
          'employee_count': row['employee_count'],
        }).toList(),
      };
    } catch (e) {
      logger.e('Error getting school details: $e');
      return null;
    }
  }

  // Search functionality
  Future<List<Map<String, dynamic>>> searchUniversityData(String searchTerm) async {
    if (searchTerm.trim().isEmpty) return [];
    
    try {
      final conn = await _dbHelper.connection;
      final result = await conn.query('CALL SearchUniversityData(?)', [searchTerm]);
      
      return result.map((row) => {
        'type': row['type'],
        'id': row['id'],
        'name': row['name'],
        'description': row['description'],
      }).toList();
    } catch (e) {
      logger.e('Error searching: $e');
      return [];
    }
  }

  // Employee Management
  Future<List<Map<String, dynamic>>> getEmployeesByDepartment(String departmentId) async {
    try {
      final conn = await _dbHelper.connection;
      final result = await conn.query('''
        SELECT 
          e.*,
          d.name as department_name,
          s.name as school_name
        FROM employees e
        LEFT JOIN departments d ON e.department_id = d.id
        LEFT JOIN schools s ON d.school_id = s.id
        WHERE e.department_id = ? AND e.is_active = TRUE
        ORDER BY e.last_name, e.first_name
      ''', [departmentId]);

      return result.map((row) => {
        'id': row['id'],
        'employee_code': row['employee_code'],
        'full_name': row['full_name'],
        'first_name': row['first_name'],
        'last_name': row['last_name'],
        'email': row['email'],
        'phone': row['phone'],
        'position': row['position'],
        'job_title': row['job_title'],
        'department_name': row['department_name'],
        'school_name': row['school_name'],
        'hire_date': row['hire_date'],
      }).toList();
    } catch (e) {
      logger.e('Error getting employees: $e');
      return [];
    }
  }

  Future<bool> addEmployee({
    required String employeeCode,
    required String firstName,
    required String lastName,
    required String email,
    String? phone,
    String? position,
    String? jobTitle,
    String? departmentId,
    DateTime? hireDate,
  }) async {
    try {
      final conn = await _dbHelper.connection;
      final id = 'emp_${DateTime.now().millisecondsSinceEpoch}';
      
      await conn.query('''
        INSERT INTO employees (
          id, employee_code, first_name, last_name, email, phone, 
          position, job_title, department_id, hire_date, is_active
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, TRUE)
      ''', [
        id, employeeCode, firstName, lastName, email, phone,
        position, jobTitle, departmentId, hireDate ?? DateTime.now(),
      ]);
      
      return true;
    } catch (e) {
      logger.e('Error adding employee: $e');
      return false;
    }
  }

  // Major Management
  Future<List<Map<String, dynamic>>> getMajorsByDepartment(String departmentId) async {
    try {
      final conn = await _dbHelper.connection;
      final result = await conn.query('''
        SELECT 
          m.*,
          d.name as department_name,
          s.name as school_name
        FROM majors m
        LEFT JOIN departments d ON m.department_id = d.id
        LEFT JOIN schools s ON d.school_id = s.id
        WHERE m.department_id = ?
        ORDER BY m.name
      ''', [departmentId]);

      return result.map((row) => {
        'id': row['id'],
        'name': row['name'],
        'code': row['code'],
        'short_name': row['short_name'],
        'description': row['description'],
        'degree_level': row['degree_level'],
        'duration_years': row['duration_years'],
        'credit_hours': row['credit_hours'],
        'department_name': row['department_name'],
        'school_name': row['school_name'],
        'is_active': row['is_active'],
      }).toList();
    } catch (e) {
      logger.e('Error getting majors: $e');
      return [];
    }
  }

  Future<bool> addMajor({
    required String name,
    required String code,
    required String departmentId,
    String? shortName,
    String? description,
    String degreeLevel = 'Bachelor',
    double durationYears = 4.0,
    int creditHours = 120,
  }) async {
    try {
      final conn = await _dbHelper.connection;
      final id = 'major_${DateTime.now().millisecondsSinceEpoch}';
      
      await conn.query('''
        INSERT INTO majors (
          id, name, code, short_name, description, department_id,
          degree_level, duration_years, credit_hours, is_active
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, TRUE)
      ''', [
        id, name, code, shortName, description, departmentId,
        degreeLevel, durationYears, creditHours,
      ]);
      
      return true;
    } catch (e) {
      logger.e('Error adding major: $e');
      return false;
    }
  }

  // Data Export
  Future<Map<String, dynamic>> exportUniversityData() async {
    try {
      final schools = await _dbHelper.getAllSchools();
      final departments = await _dbHelper.getAllDepartments();
      final statistics = await getUniversityStatistics();
      
      return {
        'export_date': DateTime.now().toIso8601String(),
        'statistics': statistics,
        'schools': schools,
        'departments': departments,
      };
    } catch (e) {
      logger.e('Error exporting data: $e');
      return {};
    }
  }

  // Validation helpers
  Future<bool> isSchoolNameUnique(String name, [String? excludeId]) async {
    try {
      final conn = await _dbHelper.connection;
      String query = 'SELECT COUNT(*) as count FROM schools WHERE name = ?';
      List<dynamic> params = [name];
      
      if (excludeId != null) {
        query += ' AND id != ?';
        params.add(excludeId);
      }
      
      final result = await conn.query(query, params);
      return result.first['count'] == 0;
    } catch (e) {
      logger.e('Error checking school name: $e');
      return false;
    }
  }

  Future<bool> isDepartmentNameUnique(String name, String schoolId, [String? excludeId]) async {
    try {
      final conn = await _dbHelper.connection;
      String query = 'SELECT COUNT(*) as count FROM departments WHERE name = ? AND school_id = ?';
      List<dynamic> params = [name, schoolId];
      
      if (excludeId != null) {
        query += ' AND id != ?';
        params.add(excludeId);
      }
      
      final result = await conn.query(query, params);
      return result.first['count'] == 0;
    } catch (e) {
      logger.e('Error checking department name: $e');
      return false;
    }
  }

  Future<bool> isMajorCodeUnique(String code, [String? excludeId]) async {
    try {
      final conn = await _dbHelper.connection;
      String query = 'SELECT COUNT(*) as count FROM majors WHERE code = ?';
      List<dynamic> params = [code];
      
      if (excludeId != null) {
        query += ' AND id != ?';
        params.add(excludeId);
      }
      
      final result = await conn.query(query, params);
      return result.first['count'] == 0;
    } catch (e) {
      logger.e('Error checking major code: $e');
      return false;
    }
  }

  // Batch operations
  Future<bool> bulkUpdateSchoolStatus(List<String> schoolIds, bool isActive) async {
    try {
      final conn = await _dbHelper.connection;
      
      for (String id in schoolIds) {
        await conn.query(
          'UPDATE schools SET is_active = ? WHERE id = ?', 
          [isActive, id]
        );
      }
      
      return true;
    } catch (e) {
      logger.e('Error bulk updating schools: $e');
      return false;
    }
  }

  // Connection management
  Future<bool> testDatabaseConnection() async {
    return await _dbHelper.testConnection();
  }

  Future<void> closeConnection() async {
    await _dbHelper.close();
  }

  // Data integrity checks
  Future<List<String>> validateDataIntegrity() async {
    List<String> issues = [];
    
    try {
      final conn = await _dbHelper.connection;
      
      // Check for orphaned departments
      final orphanedDepts = await conn.query('''
        SELECT d.name FROM departments d 
        LEFT JOIN schools s ON d.school_id = s.id 
        WHERE s.id IS NULL
      ''');
      
      if (orphanedDepts.isNotEmpty) {
        issues.add('Found ${orphanedDepts.length} departments without valid schools');
      }
      
      // Check for orphaned majors
      final orphanedMajors = await conn.query('''
        SELECT m.name FROM majors m 
        LEFT JOIN departments d ON m.department_id = d.id 
        WHERE d.id IS NULL
      ''');
      
      if (orphanedMajors.isNotEmpty) {
        issues.add('Found ${orphanedMajors.length} majors without valid departments');
      }
      
      // Check for duplicate codes
      final duplicateCodes = await conn.query('''
        SELECT code, COUNT(*) as count FROM majors 
        WHERE code IS NOT NULL 
        GROUP BY code HAVING count > 1
      ''');
      
      if (duplicateCodes.isNotEmpty) {
        issues.add('Found ${duplicateCodes.length} duplicate major codes');
      }
      
    } catch (e) {
      issues.add('Error validating data integrity: $e');
    }
    
    return issues;
  }
}