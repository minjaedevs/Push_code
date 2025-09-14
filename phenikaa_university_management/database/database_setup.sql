-- Tạo database cho Phenikaa University
CREATE DATABASE IF NOT EXISTS phenikaa_university 
CHARACTER SET utf8mb4 
COLLATE utf8mb4_unicode_ci;

USE phenikaa_university;

-- Tạo bảng Universities (mở rộng cho tương lai nếu có nhiều trường đại học)
CREATE TABLE IF NOT EXISTS universities (
    id VARCHAR(50) PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    short_name VARCHAR(100),
    address TEXT,
    phone VARCHAR(20),
    email VARCHAR(100),
    website VARCHAR(255),
    logo_url VARCHAR(500),
    established_year INT,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Tạo bảng Schools (các trường trong đại học)
CREATE TABLE IF NOT EXISTS schools (
    id VARCHAR(50) PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    short_name VARCHAR(100),
    description TEXT,
    university_id VARCHAR(50) DEFAULT 'phenikaa_main',
    dean_name VARCHAR(255),
    dean_email VARCHAR(100),
    office_location VARCHAR(255),
    phone VARCHAR(20),
    email VARCHAR(100),
    website VARCHAR(255),
    established_year INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_university_id (university_id),
    FOREIGN KEY (university_id) REFERENCES universities(id) ON DELETE CASCADE
);

-- Tạo bảng Departments (các khoa trong trường)
CREATE TABLE IF NOT EXISTS departments (
    id VARCHAR(50) PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    short_name VARCHAR(100),
    description TEXT,
    school_id VARCHAR(50) NOT NULL,
    head_name VARCHAR(255),
    head_email VARCHAR(100),
    office_location VARCHAR(255),
    phone VARCHAR(20),
    email VARCHAR(100),
    website VARCHAR(255),
    established_year INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_school_id (school_id),
    FOREIGN KEY (school_id) REFERENCES schools(id) ON DELETE CASCADE
);

-- Tạo bảng Majors (các ngành học)
CREATE TABLE IF NOT EXISTS majors (
    id VARCHAR(50) PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    code VARCHAR(20) UNIQUE,
    short_name VARCHAR(100),
    description TEXT,
    department_id VARCHAR(50) NOT NULL,
    degree_level ENUM('Bachelor', 'Master', 'PhD', 'Associate') DEFAULT 'Bachelor',
    duration_years DECIMAL(2,1) DEFAULT 4.0,
    credit_hours INT DEFAULT 120,
    tuition_fee DECIMAL(12,2),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_department_id (department_id),
    INDEX idx_code (code),
    FOREIGN KEY (department_id) REFERENCES departments(id) ON DELETE CASCADE
);

-- Tạo bảng Employees (nhân viên, giảng viên)
CREATE TABLE IF NOT EXISTS employees (
    id VARCHAR(50) PRIMARY KEY,
    employee_code VARCHAR(20) UNIQUE NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    full_name VARCHAR(255) GENERATED ALWAYS AS (CONCAT(first_name, ' ', last_name)) STORED,
    email VARCHAR(100) UNIQUE,
    phone VARCHAR(20),
    date_of_birth DATE,
    gender ENUM('Male', 'Female', 'Other'),
    address TEXT,
    position VARCHAR(100),
    job_title VARCHAR(100),
    department_id VARCHAR(50),
    hire_date DATE,
    salary DECIMAL(12,2),
    is_active BOOLEAN DEFAULT TRUE,
    profile_image_url VARCHAR(500),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_employee_code (employee_code),
    INDEX idx_department_id (department_id),
    INDEX idx_email (email),
    FOREIGN KEY (department_id) REFERENCES departments(id) ON DELETE SET NULL
);

-- Tạo bảng Students (sinh viên) - mở rộng cho tương lai
CREATE TABLE IF NOT EXISTS students (
    id VARCHAR(50) PRIMARY KEY,
    student_code VARCHAR(20) UNIQUE NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    full_name VARCHAR(255) GENERATED ALWAYS AS (CONCAT(first_name, ' ', last_name)) STORED,
    email VARCHAR(100) UNIQUE,
    phone VARCHAR(20),
    date_of_birth DATE,
    gender ENUM('Male', 'Female', 'Other'),
    address TEXT,
    major_id VARCHAR(50),
    enrollment_year INT,
    expected_graduation_year INT,
    current_semester INT DEFAULT 1,
    gpa DECIMAL(3,2) DEFAULT 0.00,
    status ENUM('Active', 'Graduated', 'Suspended', 'Transferred') DEFAULT 'Active',
    profile_image_url VARCHAR(500),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_student_code (student_code),
    INDEX idx_major_id (major_id),
    INDEX idx_email (email),
    INDEX idx_enrollment_year (enrollment_year),
    FOREIGN KEY (major_id) REFERENCES majors(id) ON DELETE SET NULL
);

-- Tạo bảng Courses (môn học) - mở rộng cho tương lai
CREATE TABLE IF NOT EXISTS courses (
    id VARCHAR(50) PRIMARY KEY,
    course_code VARCHAR(20) UNIQUE NOT NULL,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    credits INT NOT NULL DEFAULT 3,
    department_id VARCHAR(50),
    prerequisite_courses JSON,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_course_code (course_code),
    INDEX idx_department_id (department_id),
    FOREIGN KEY (department_id) REFERENCES departments(id) ON DELETE SET NULL
);

-- Thêm dữ liệu mẫu
INSERT INTO universities (id, name, short_name, address, phone, email, website, established_year, description) VALUES
('phenikaa_main', 'Đại học Phenikaa', 'Phenikaa University', 'Yên Nghĩa, Hà Đông, Hà Nội', '024-6291-8080', 'info@phenikaa-uni.edu.vn', 'https://phenikaa-uni.edu.vn', 2007, 'Đại học Phenikaa là một trong những trường đại học tư thục hàng đầu Việt Nam')
ON DUPLICATE KEY UPDATE name=VALUES(name);

-- Thêm dữ liệu mẫu cho Schools
INSERT INTO schools (id, name, short_name, description, university_id, dean_name, phone, email) VALUES
('school_1', 'Trường Công nghệ Thông tin', 'School of IT', 'Đào tạo các chuyên ngành về Công nghệ Thông tin và Khoa học Máy tính', 'phenikaa_main', 'PGS.TS. Nguyễn Văn A', '024-6291-8081', 'it@phenikaa-uni.edu.vn'),
('school_2', 'Trường Kinh tế & Quản trị Kinh doanh', 'School of Economics', 'Đào tạo các chuyên ngành về Kinh tế, Quản trị Kinh doanh và Tài chính', 'phenikaa_main', 'PGS.TS. Trần Thị B', '024-6291-8082', 'business@phenikaa-uni.edu.vn'),
('school_3', 'Trường Kỹ thuật', 'School of Engineering', 'Đào tạo các chuyên ngành Kỹ thuật và Công nghệ', 'phenikaa_main', 'PGS.TS. Lê Văn C', '024-6291-8083', 'engineering@phenikaa-uni.edu.vn'),
('school_4', 'Trường Y Dược', 'School of Medicine', 'Đào tạo các chuyên ngành Y học và Dược học', 'phenikaa_main', 'PGS.TS. Phạm Thị D', '024-6291-8084', 'medicine@phenikaa-uni.edu.vn')
ON DUPLICATE KEY UPDATE name=VALUES(name);

-- Thêm dữ liệu mẫu cho Departments
INSERT INTO departments (id, name, short_name, description, school_id, head_name, phone, email) VALUES
-- Trường CNTT
('dept_1', 'Khoa Hệ thống Thông tin', 'Information Systems', 'Chuyên ngành Hệ thống Thông tin, Phân tích và Thiết kế hệ thống', 'school_1', 'TS. Nguyễn Văn E', '024-6291-8101', 'is@phenikaa-uni.edu.vn'),
('dept_2', 'Khoa Khoa học Máy tính', 'Computer Science', 'Chuyên ngành Khoa học Máy tính, Lập trình và Phát triển phần mềm', 'school_1', 'TS. Trần Văn F', '024-6291-8102', 'cs@phenikaa-uni.edu.vn'),
('dept_3', 'Khoa An toàn Thông tin', 'Information Security', 'Chuyên ngành An toàn và Bảo mật Thông tin', 'school_1', 'TS. Lê Thị G', '024-6291-8103', 'security@phenikaa-uni.edu.vn'),

-- Trường Kinh tế
('dept_4', 'Khoa Quản trị Kinh doanh', 'Business Administration', 'Chuyên ngành Quản trị Kinh doanh và Khởi nghiệp', 'school_2', 'TS. Phạm Văn H', '024-6291-8201', 'ba@phenikaa-uni.edu.vn'),
('dept_5', 'Khoa Kế toán', 'Accounting', 'Chuyên ngành Kế toán và Kiểm toán', 'school_2', 'TS. Nguyễn Thị I', '024-6291-8202', 'accounting@phenikaa-uni.edu.vn'),
('dept_6', 'Khoa Tài chính - Ngân hàng', 'Finance & Banking', 'Chuyên ngành Tài chính, Ngân hàng và Bảo hiểm', 'school_2', 'TS. Trần Văn J', '024-6291-8203', 'finance@phenikaa-uni.edu.vn'),

-- Trường Kỹ thuật
('dept_7', 'Khoa Kỹ thuật Cơ khí', 'Mechanical Engineering', 'Chuyên ngành Kỹ thuật Cơ khí và Chế tạo máy', 'school_3', 'TS. Lê Văn K', '024-6291-8301', 'mechanical@phenikaa-uni.edu.vn'),
('dept_8', 'Khoa Kỹ thuật Điện - Điện tử', 'Electrical Engineering', 'Chuyên ngành Kỹ thuật Điện, Điện tử và Viễn thông', 'school_3', 'TS. Phạm Thị L', '024-6291-8302', 'electrical@phenikaa-uni.edu.vn'),
('dept_9', 'Khoa Kỹ thuật Xây dựng', 'Civil Engineering', 'Chuyên ngành Kỹ thuật Xây dựng và Kiến trúc', 'school_3', 'TS. Nguyễn Văn M', '024-6291-8303', 'civil@phenikaa-uni.edu.vn'),

-- Trường Y Dược
('dept_10', 'Khoa Y khoa', 'General Medicine', 'Chuyên ngành Y khoa tổng quát', 'school_4', 'PGS.TS. Trần Thị N', '024-6291-8401', 'medicine@phenikaa-uni.edu.vn'),
('dept_11', 'Khoa Dược', 'Pharmacy', 'Chuyên ngành Dược học', 'school_4', 'TS. Lê Văn O', '024-6291-8402', 'pharmacy@phenikaa-uni.edu.vn')
ON DUPLICATE KEY UPDATE name=VALUES(name);

-- Thêm dữ liệu mẫu cho Majors
INSERT INTO majors (id, name, code, short_name, description, department_id, degree_level, duration_years, credit_hours) VALUES
-- CNTT
('major_1', 'Hệ thống Thông tin', 'IS2024', 'Information Systems', 'Đào tạo chuyên gia phân tích, thiết kế và quản lý hệ thống thông tin', 'dept_1', 'Bachelor', 4.0, 120),
('major_2', 'Khoa học Máy tính', 'CS2024', 'Computer Science', 'Đào tạo kỹ sư phần mềm và chuyên gia công nghệ thông tin', 'dept_2', 'Bachelor', 4.0, 120),
('major_3', 'An toàn Thông tin', 'SE2024', 'Information Security', 'Đào tạo chuyên gia bảo mật và an toàn thông tin', 'dept_3', 'Bachelor', 4.0, 120),

-- Kinh tế
('major_4', 'Quản trị Kinh doanh', 'BA2024', 'Business Administration', 'Đào tạo nhà quản lý và chuyên gia kinh doanh', 'dept_4', 'Bachelor', 4.0, 120),
('major_5', 'Kế toán', 'AC2024', 'Accounting', 'Đào tạo kế toán viên và chuyên gia tài chính', 'dept_5', 'Bachelor', 4.0, 120),
('major_6', 'Tài chính - Ngân hàng', 'FB2024', 'Finance & Banking', 'Đào tạo chuyên gia tài chính và ngân hàng', 'dept_6', 'Bachelor', 4.0, 120),

-- Kỹ thuật
('major_7', 'Kỹ thuật Cơ khí', 'ME2024', 'Mechanical Engineering', 'Đào tạo kỹ sư cơ khí và chế tạo máy', 'dept_7', 'Bachelor', 4.0, 120),
('major_8', 'Kỹ thuật Điện', 'EE2024', 'Electrical Engineering', 'Đào tạo kỹ sư điện và điện tử', 'dept_8', 'Bachelor', 4.0, 120),
('major_9', 'Kỹ thuật Xây dựng', 'CE2024', 'Civil Engineering', 'Đào tạo kỹ sư xây dựng và kiến trúc sư', 'dept_9', 'Bachelor', 4.0, 120),

-- Y Dược
('major_10', 'Y khoa', 'MD2024', 'Medicine', 'Đào tạo bác sĩ y khoa', 'dept_10', 'Bachelor', 6.0, 180),
('major_11', 'Dược học', 'PH2024', 'Pharmacy', 'Đào tạo dược sĩ', 'dept_11', 'Bachelor', 5.0, 150)
ON DUPLICATE KEY UPDATE name=VALUES(name);

-- Tạo view để dễ dàng truy vấn dữ liệu
CREATE OR REPLACE VIEW v_department_info AS
SELECT 
    d.id,
    d.name as department_name,
    d.short_name as department_short_name,
    d.description as department_description,
    s.id as school_id,
    s.name as school_name,
    s.short_name as school_short_name,
    u.name as university_name,
    d.head_name,
    d.phone,
    d.email,
    d.created_at,
    d.updated_at
FROM departments d
LEFT JOIN schools s ON d.school_id = s.id
LEFT JOIN universities u ON s.university_id = u.id;

CREATE OR REPLACE VIEW v_major_info AS
SELECT 
    m.id,
    m.name as major_name,
    m.code as major_code,
    m.short_name as major_short_name,
    m.description as major_description,
    m.degree_level,
    m.duration_years,
    m.credit_hours,
    d.name as department_name,
    s.name as school_name,
    u.name as university_name,
    m.is_active,
    m.created_at,
    m.updated_at
FROM majors m
LEFT JOIN departments d ON m.department_id = d.id
LEFT JOIN schools s ON d.school_id = s.id
LEFT JOIN universities u ON s.university_id = u.id;

-- Tạo stored procedures cho các thao tác thường dùng
DELIMITER //

-- Procedure lấy tất cả thông tin trường và khoa
CREATE PROCEDURE GetUniversityStructure()
BEGIN
    SELECT 
        s.id as school_id,
        s.name as school_name,
        s.description as school_description,
        s.dean_name,
        s.phone as school_phone,
        s.email as school_email,
        COUNT(d.id) as total_departments
    FROM schools s
    LEFT JOIN departments d ON s.id = d.school_id
    GROUP BY s.id, s.name, s.description, s.dean_name, s.phone, s.email
    ORDER BY s.name;
END //

-- Procedure lấy thông tin chi tiết của một trường
CREATE PROCEDURE GetSchoolDetails(IN school_id VARCHAR(50))
BEGIN
    -- Thông tin trường
    SELECT * FROM schools WHERE id = school_id;
    
    -- Danh sách khoa thuộc trường
    SELECT 
        d.*,
        COUNT(m.id) as total_majors,
        COUNT(e.id) as total_employees
    FROM departments d
    LEFT JOIN majors m ON d.id = m.department_id
    LEFT JOIN employees e ON d.id = e.department_id
    WHERE d.school_id = school_id
    GROUP BY d.id
    ORDER BY d.name;
END //

-- Procedure thống kê tổng quan
CREATE PROCEDURE GetUniversityStatistics()
BEGIN
    SELECT 
        (SELECT COUNT(*) FROM schools) as total_schools,
        (SELECT COUNT(*) FROM departments) as total_departments,
        (SELECT COUNT(*) FROM majors WHERE is_active = TRUE) as total_active_majors,
        (SELECT COUNT(*) FROM employees WHERE is_active = TRUE) as total_active_employees,
        (SELECT COUNT(*) FROM students WHERE status = 'Active') as total_active_students;
END //

-- Procedure tìm kiếm
CREATE PROCEDURE SearchUniversityData(IN search_term VARCHAR(255))
BEGIN
    -- Tìm trong schools
    SELECT 'school' as type, id, name, description FROM schools 
    WHERE name LIKE CONCAT('%', search_term, '%') OR description LIKE CONCAT('%', search_term, '%')
    
    UNION ALL
    
    -- Tìm trong departments
    SELECT 'department' as type, id, name, description FROM departments 
    WHERE name LIKE CONCAT('%', search_term, '%') OR description LIKE CONCAT('%', search_term, '%')
    
    UNION ALL
    
    -- Tìm trong majors
    SELECT 'major' as type, id, name, description FROM majors 
    WHERE name LIKE CONCAT('%', search_term, '%') OR description LIKE CONCAT('%', search_term, '%');
END //

DELIMITER ;

-- Tạo indexes để tối ưu hiệu suất
CREATE INDEX idx_schools_name ON schools(name);
CREATE INDEX idx_departments_name ON departments(name);
CREATE INDEX idx_majors_name ON majors(name);
CREATE INDEX idx_employees_name ON employees(first_name, last_name);
CREATE INDEX idx_students_name ON students(first_name, last_name);

-- Tạo triggers để tự động cập nhật timestamp
DELIMITER //

CREATE TRIGGER update_schools_timestamp 
BEFORE UPDATE ON schools 
FOR EACH ROW 
BEGIN 
    SET NEW.updated_at = CURRENT_TIMESTAMP; 
END //

CREATE TRIGGER update_departments_timestamp 
BEFORE UPDATE ON departments 
FOR EACH ROW 
BEGIN 
    SET NEW.updated_at = CURRENT_TIMESTAMP; 
END //

CREATE TRIGGER update_majors_timestamp 
BEFORE UPDATE ON majors 
FOR EACH ROW 
BEGIN 
    SET NEW.updated_at = CURRENT_TIMESTAMP; 
END //

CREATE TRIGGER update_employees_timestamp 
BEFORE UPDATE ON employees 
FOR EACH ROW 
BEGIN 
    SET NEW.updated_at = CURRENT_TIMESTAMP; 
END //

CREATE TRIGGER update_students_timestamp 
BEFORE UPDATE ON students 
FOR EACH ROW 
BEGIN 
    SET NEW.updated_at = CURRENT_TIMESTAMP; 
END //

DELIMITER ;

-- Thêm một số dữ liệu mẫu cho Employees
INSERT INTO employees (id, employee_code, first_name, last_name, email, phone, position, job_title, department_id, hire_date, is_active) VALUES
-- IT School
('emp_1', 'EMP001', 'Nguyễn', 'Văn An', 'nvan.an@phenikaa-uni.edu.vn', '0901234567', 'Lecturer', 'Giảng viên', 'dept_1', '2020-09-01', TRUE),
('emp_2', 'EMP002', 'Trần', 'Thị Bình', 'tthi.binh@phenikaa-uni.edu.vn', '0901234568', 'Senior Lecturer', 'Giảng viên chính', 'dept_2', '2019-03-15', TRUE),
('emp_3', 'EMP003', 'Lê', 'Văn Cường', 'lvan.cuong@phenikaa-uni.edu.vn', '0901234569', 'Associate Professor', 'Phó Giáo sư', 'dept_3', '2018-01-10', TRUE),

-- Business School  
('emp_4', 'EMP004', 'Phạm', 'Thị Dung', 'pthi.dung@phenikaa-uni.edu.vn', '0901234570', 'Lecturer', 'Giảng viên', 'dept_4', '2021-02-20', TRUE),
('emp_5', 'EMP005', 'Hoàng', 'Văn Em', 'hvan.em@phenikaa-uni.edu.vn', '0901234571', 'Senior Lecturer', 'Giảng viên chính', 'dept_5', '2020-08-15', TRUE),

-- Engineering School
('emp_6', 'EMP006', 'Vũ', 'Thị Phương', 'vthi.phuong@phenikaa-uni.edu.vn', '0901234572', 'Lecturer', 'Giảng viên', 'dept_7', '2022-01-05', TRUE),
('emp_7', 'EMP007', 'Đặng', 'Văn Giang', 'dvan.giang@phenikaa-uni.edu.vn', '0901234573', 'Assistant Professor', 'Giáo sư trợ lý', 'dept_8', '2019-09-10', TRUE)
ON DUPLICATE KEY UPDATE first_name=VALUES(first_name);

-- Kiểm tra dữ liệu đã tạo
SELECT 'Database setup completed successfully!' as status;

-- Hiển thị thống kê tổng quan
CALL GetUniversityStatistics();