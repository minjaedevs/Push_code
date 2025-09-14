import 'package:mysql1/mysql1.dart';
import 'dart:async';

class DatabaseHelper {
  static DatabaseHelper? _instance;
  static MySqlConnection? _connection;

  DatabaseHelper._internal();

  static DatabaseHelper get instance {
    _instance ??= DatabaseHelper._internal();
    return _instance!;
  }

  // Cấu hình kết nối database
  static const String _host = '127.0.0.1'; // Hoặc IP của server MySQL
  static const int _port = 3306;
  static const String _user = 'root'; // Username MySQL của bạn
  static const String _password = 'Meo@2004'; // Password MySQL của bạn
  static const String _db = 'phenikaa_university'; // Tên database

  Future<MySqlConnection> get connection async {
  _connection ??= await MySqlConnection.connect(ConnectionSettings(
    host: _host,
    port: _port,
    user: _user,
    password: _password,
    db: _db,
  ));
  return _connection!;
}


  Future<void> close() async {
    if (_connection != null) {
      await _connection!.close();
      _connection = null;
    }
  }

  // Khởi tạo database và bảng
  Future<void> initializeDatabase() async {
    try {
      final conn = await connection;
      
      // Tạo bảng Schools
      await conn.query('''
        CREATE TABLE IF NOT EXISTS schools (
          id VARCHAR(50) PRIMARY KEY,
          name VARCHAR(255) NOT NULL,
          description TEXT,
          created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
          updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
        )
      ''');

      // Tạo bảng Departments
      await conn.query('''
        CREATE TABLE IF NOT EXISTS departments (
          id VARCHAR(50) PRIMARY KEY,
          name VARCHAR(255) NOT NULL,
          description TEXT,
          school_id VARCHAR(50) NOT NULL,
          created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
          updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
          FOREIGN KEY (school_id) REFERENCES schools(id) ON DELETE CASCADE
        )
      ''');

      // Tạo bảng Employees (mở rộng cho tương lai)
      await conn.query('''
        CREATE TABLE IF NOT EXISTS employees (
          id VARCHAR(50) PRIMARY KEY,
          name VARCHAR(255) NOT NULL,
          email VARCHAR(255) UNIQUE,
          phone VARCHAR(20),
          position VARCHAR(100),
          department_id VARCHAR(50),
          created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
          updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
          FOREIGN KEY (department_id) REFERENCES departments(id) ON DELETE SET NULL
        )
      ''');

      // Tạo bảng Majors (mở rộng cho tương lai)
      await conn.query('''
        CREATE TABLE IF NOT EXISTS majors (
          id VARCHAR(50) PRIMARY KEY,
          name VARCHAR(255) NOT NULL,
          code VARCHAR(20) UNIQUE,
          description TEXT,
          department_id VARCHAR(50) NOT NULL,
          created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
          updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
          FOREIGN KEY (department_id) REFERENCES departments(id) ON DELETE CASCADE
        )
      ''');

      print('Database initialized successfully');
    } catch (e) {
      print('Error initializing database: $e');
      rethrow;
    }
  }

  // CRUD Operations cho Schools
  Future<List<Map<String, dynamic>>> getAllSchools() async {
    try {
      final conn = await connection;
      final results = await conn.query('SELECT * FROM schools ORDER BY name');
      return results.map((row) => {
        'id': row['id'],
        'name': row['name'],
        'description': row['description'],
        'created_at': row['created_at'],
        'updated_at': row['updated_at'],
      }).toList();
    } catch (e) {
      print('Error getting schools: $e');
      return [];
    }
  }

  Future<bool> insertSchool(String id, String name, String description) async {
    try {
      final conn = await connection;
      await conn.query(
        'INSERT INTO schools (id, name, description) VALUES (?, ?, ?)',
        [id, name, description],
      );
      return true;
    } catch (e) {
      print('Error inserting school: $e');
      return false;
    }
  }

  Future<bool> updateSchool(String id, String name, String description) async {
    try {
      final conn = await connection;
      await conn.query(
        'UPDATE schools SET name = ?, description = ? WHERE id = ?',
        [name, description, id],
      );
      return true;
    } catch (e) {
      print('Error updating school: $e');
      return false;
    }
  }

  Future<bool> deleteSchool(String id) async {
    try {
      final conn = await connection;
      await conn.query('DELETE FROM schools WHERE id = ?', [id]);
      return true;
    } catch (e) {
      print('Error deleting school: $e');
      return false;
    }
  }

  // CRUD Operations cho Departments
  Future<List<Map<String, dynamic>>> getAllDepartments() async {
    try {
      final conn = await connection;
      final results = await conn.query('''
        SELECT d.*, s.name as school_name 
        FROM departments d 
        LEFT JOIN schools s ON d.school_id = s.id 
        ORDER BY s.name, d.name
      ''');
      return results.map((row) => {
        'id': row['id'],
        'name': row['name'],
        'description': row['description'],
        'school_id': row['school_id'],
        'school_name': row['school_name'],
        'created_at': row['created_at'],
        'updated_at': row['updated_at'],
      }).toList();
    } catch (e) {
      print('Error getting departments: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getDepartmentsBySchoolId(String schoolId) async {
    try {
      final conn = await connection;
      final results = await conn.query(
        'SELECT * FROM departments WHERE school_id = ? ORDER BY name',
        [schoolId],
      );
      return results.map((row) => {
        'id': row['id'],
        'name': row['name'],
        'description': row['description'],
        'school_id': row['school_id'],
        'created_at': row['created_at'],
        'updated_at': row['updated_at'],
      }).toList();
    } catch (e) {
      print('Error getting departments by school: $e');
      return [];
    }
  }

  Future<bool> insertDepartment(String id, String name, String description, String schoolId) async {
    try {
      final conn = await connection;
      await conn.query(
        'INSERT INTO departments (id, name, description, school_id) VALUES (?, ?, ?, ?)',
        [id, name, description, schoolId],
      );
      return true;
    } catch (e) {
      print('Error inserting department: $e');
      return false;
    }
  }

  Future<bool> updateDepartment(String id, String name, String description, String schoolId) async {
    try {
      final conn = await connection;
      await conn.query(
        'UPDATE departments SET name = ?, description = ?, school_id = ? WHERE id = ?',
        [name, description, schoolId, id],
      );
      return true;
    } catch (e) {
      print('Error updating department: $e');
      return false;
    }
  }

  Future<bool> deleteDepartment(String id) async {
    try {
      final conn = await connection;
      await conn.query('DELETE FROM departments WHERE id = ?', [id]);
      return true;
    } catch (e) {
      print('Error deleting department: $e');
      return false;
    }
  }

  // Kiểm tra kết nối
  Future<bool> testConnection() async {
    try {
      final conn = await connection;
      await conn.query('SELECT 1');
      return true;
    } catch (e) {
      print('Database connection failed: $e');
      return false;
    }
  }

  // Thêm dữ liệu mẫu
  Future<void> insertSampleData() async {
    try {
      // Kiểm tra xem đã có dữ liệu chưa
      final schools = await getAllSchools();
      if (schools.isNotEmpty) {
        print('Sample data already exists');
        return;
      }

      // Thêm Schools
      await insertSchool('school_1', 'Trường Công nghệ Thông tin', 'Đào tạo các chuyên ngành về CNTT');
      await insertSchool('school_2', 'Trường Kinh tế & Quản trị Kinh doanh', 'Đào tạo các chuyên ngành kinh tế');
      await insertSchool('school_3', 'Trường Kỹ thuật', 'Đào tạo các chuyên ngành kỹ thuật');

      // Thêm Departments
      await insertDepartment('dept_1', 'Khoa Hệ thống Thông tin', 'Chuyên ngành hệ thống thông tin', 'school_1');
      await insertDepartment('dept_2', 'Khoa Khoa học Máy tính', 'Chuyên ngành khoa học máy tính', 'school_1');
      await insertDepartment('dept_3', 'Khoa Quản trị Kinh doanh', 'Chuyên ngành quản trị kinh doanh', 'school_2');
      await insertDepartment('dept_4', 'Khoa Kế toán', 'Chuyên ngành kế toán', 'school_2');
      await insertDepartment('dept_5', 'Khoa Kỹ thuật Cơ khí', 'Chuyên ngành cơ khí', 'school_3');

      print('Sample data inserted successfully');
    } catch (e) {
      print('Error inserting sample data: $e');
    }
  }
}