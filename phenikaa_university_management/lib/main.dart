import 'package:flutter/material.dart';
import 'database/database_helper.dart';
import 'package:phenikaa_university_management/config/logger.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Khởi tạo database
  try {
    await DatabaseHelper.instance.initializeDatabase();
    await DatabaseHelper.instance.insertSampleData();
    logger.i('Database setup completed');
  } catch (e) {
    logger.i('Database setup error: $e');
  }

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ĐH Phenikaa - Quản lý Cơ cấu Tổ chức',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.blue[800],
          foregroundColor: Colors.white,
        ),
      ),
      home: UniversityManagementScreen(),
    );
  }
}

// Model classes
class School {
  String id;
  String name;
  String description;
  List<Department> departments;
  DateTime? createdAt;
  DateTime? updatedAt;

  School({
    required this.id,
    required this.name,
    required this.description,
    List<Department>? departments,
    this.createdAt,
    this.updatedAt,
  }) : departments = departments ?? [];

  factory School.fromMap(Map<String, dynamic> map) {
    return School(
      id: map['id'],
      name: map['name'],
      description: map['description'] ?? '',
      createdAt: map['created_at'],
      updatedAt: map['updated_at'],
    );
  }
}

class Department {
  String id;
  String name;
  String description;
  String schoolId;
  String? schoolName;
  DateTime? createdAt;
  DateTime? updatedAt;

  Department({
    required this.id,
    required this.name,
    required this.description,
    required this.schoolId,
    this.schoolName,
    this.createdAt,
    this.updatedAt,
  });

  factory Department.fromMap(Map<String, dynamic> map) {
    return Department(
      id: map['id'],
      name: map['name'],
      description: map['description'] ?? '',
      schoolId: map['school_id'],
      schoolName: map['school_name'],
      createdAt: map['created_at'],
      updatedAt: map['updated_at'],
    );
  }
}

class UniversityManagementScreen extends StatefulWidget {
  const UniversityManagementScreen({super.key});
  @override
  State<UniversityManagementScreen> createState() =>
      _UniversityManagementScreenState();
}

class _UniversityManagementScreenState
    extends State<UniversityManagementScreen> {
  List<School> schools = [];
  List<Department> departments = [];
  bool isLoading = true;
  String? connectionStatus;

  @override
  void initState() {
    super.initState();
    _loadDataFromDatabase();
  }

  Future<void> _loadDataFromDatabase() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Kiểm tra kết nối database
      bool isConnected = await DatabaseHelper.instance.testConnection();

      if (isConnected) {
        setState(() {
          connectionStatus = 'Kết nối database thành công';
        });

        // Tải dữ liệu từ database
        await _loadSchools();
        await _loadDepartments();
        _updateSchoolDepartments();
      } else {
        setState(() {
          connectionStatus = 'Không thể kết nối database - Sử dụng dữ liệu mẫu';
        });
        _initializeLocalData();
      }
    } catch (e) {
      logger.e('Error loading data: $e');
      setState(() {
        connectionStatus = 'Lỗi kết nối database - Sử dụng dữ liệu mẫu';
      });
      _initializeLocalData();
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<void> _loadSchools() async {
    final schoolData = await DatabaseHelper.instance.getAllSchools();
    setState(() {
      schools = schoolData.map((data) => School.fromMap(data)).toList();
    });
  }

  Future<void> _loadDepartments() async {
    final departmentData = await DatabaseHelper.instance.getAllDepartments();
    setState(() {
      departments =
          departmentData.map((data) => Department.fromMap(data)).toList();
    });
  }

  void _initializeLocalData() {
    // Dữ liệu mẫu khi không kết nối được database
    schools = [
      School(
        id: 'school_1',
        name: 'Trường Công nghệ Thông tin',
        description: 'Đào tạo các chuyên ngành về CNTT',
      ),
      School(
        id: 'school_2',
        name: 'Trường Kinh tế & Quản trị Kinh doanh',
        description: 'Đào tạo các chuyên ngành kinh tế',
      ),
      School(
        id: 'school_3',
        name: 'Trường Kỹ thuật',
        description: 'Đào tạo các chuyên ngành kỹ thuật',
      ),
    ];

    departments = [
      Department(
        id: 'dept_1',
        name: 'Khoa Hệ thống Thông tin',
        description: 'Chuyên ngành hệ thống thông tin',
        schoolId: 'school_1',
      ),
      Department(
        id: 'dept_2',
        name: 'Khoa Khoa học Máy tính',
        description: 'Chuyên ngành khoa học máy tính',
        schoolId: 'school_1',
      ),
      Department(
        id: 'dept_3',
        name: 'Khoa Quản trị Kinh doanh',
        description: 'Chuyên ngành quản trị kinh doanh',
        schoolId: 'school_2',
      ),
      Department(
        id: 'dept_4',
        name: 'Khoa Kế toán',
        description: 'Chuyên ngành kế toán',
        schoolId: 'school_2',
      ),
      Department(
        id: 'dept_5',
        name: 'Khoa Kỹ thuật Cơ khí',
        description: 'Chuyên ngành cơ khí',
        schoolId: 'school_3',
      ),
    ];
  }

  void _updateSchoolDepartments() {
    for (var school in schools) {
      school.departments =
          departments.where((dept) => dept.schoolId == school.id).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ĐH Phenikaa - Quản lý Cơ cấu Tổ chức'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadDataFromDatabase,
            tooltip: 'Tải lại dữ liệu',
          ),
        ],
      ),
      body:
          isLoading
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Đang tải dữ liệu...'),
                  ],
                ),
              )
              : Column(
                children: [
                  // Header với logo và tên trường đại học
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.blue[700]!, Colors.blue[500]!],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.school, size: 48, color: Colors.white),
                        SizedBox(height: 8),
                        Text(
                          'ĐẠI HỌC PHENIKAA',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Hệ thống Quản lý Cơ cấu Tổ chức',
                          style: TextStyle(fontSize: 16, color: Colors.white70),
                        ),
                        if (connectionStatus != null) ...[
                          SizedBox(height: 8),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  connectionStatus!.contains('thành công')
                                      ? Colors.green.withValues(alpha: 0.5)
                                      : Colors.orange.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              connectionStatus!,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Action buttons
                  Container(
                    padding: EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () => _showAddSchoolDialog(),
                          icon: Icon(Icons.add),
                          label: Text('Thêm Trường'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () => _showAddDepartmentDialog(),
                          icon: Icon(Icons.add),
                          label: Text('Thêm Khoa'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Tree structure
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 16),
                      child: ListView.builder(
                        itemCount: schools.length,
                        itemBuilder: (context, index) {
                          return _buildSchoolCard(schools[index]);
                        },
                      ),
                    ),
                  ),
                ],
              ),
    );
  }

  Widget _buildSchoolCard(School school) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      elevation: 4,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.business, color: Colors.blue[800]),
          ),
          title: Text(
            school.name,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blue[800],
            ),
          ),
          subtitle: Text(
            school.description,
            style: TextStyle(color: Colors.grey[600]),
          ),
          trailing: PopupMenuButton(
            onSelected: (value) {
              if (value == 'edit') {
                _showEditSchoolDialog(school);
              } else if (value == 'delete') {
                _deleteSchool(school);
              }
            },
            itemBuilder:
                (context) => [
                  PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit, color: Colors.blue),
                        SizedBox(width: 8),
                        Text('Sửa'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Xóa'),
                      ],
                    ),
                  ),
                ],
          ),
          children:
              school.departments.isEmpty
                  ? [
                    Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'Chưa có khoa nào',
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  ]
                  : school.departments
                      .map((dept) => _buildDepartmentTile(dept))
                      .toList(),
        ),
      ),
    );
  }

  Widget _buildDepartmentTile(Department department) {
    return Container(
      margin: EdgeInsets.only(left: 16, right: 16, bottom: 8),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: ListTile(
        leading: Container(
          padding: EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.orange[100],
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(Icons.folder, color: Colors.orange[800], size: 20),
        ),
        title: Text(
          department.name,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.orange[800],
          ),
        ),
        subtitle: Text(
          department.description,
          style: TextStyle(color: Colors.grey[600]),
        ),
        trailing: PopupMenuButton(
          onSelected: (value) {
            if (value == 'edit') {
              _showEditDepartmentDialog(department);
            } else if (value == 'delete') {
              _deleteDepartment(department);
            }
          },
          itemBuilder:
              (context) => [
                PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, color: Colors.blue),
                      SizedBox(width: 8),
                      Text('Sửa'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Xóa'),
                    ],
                  ),
                ),
              ],
        ),
      ),
    );
  }

  void _showAddSchoolDialog() {
    TextEditingController nameController = TextEditingController();
    TextEditingController descController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Thêm Trường mới'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Tên Trường',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: descController,
                  decoration: InputDecoration(
                    labelText: 'Mô tả',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Hủy'),
              ),
              ElevatedButton(
  onPressed: () async {
    if (nameController.text.isEmpty) return;

    await _addSchool(nameController.text, descController.text);

    if (!mounted) return; 
    Navigator.pop(context);
  },
  child: const Text('Thêm'),
),

            ],
          ),
    );
  }

  void _showEditSchoolDialog(School school) {
    TextEditingController nameController = TextEditingController(
      text: school.name,
    );
    TextEditingController descController = TextEditingController(
      text: school.description,
    );

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Sửa Trường'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Tên Trường',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: descController,
                  decoration: InputDecoration(
                    labelText: 'Mô tả',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Hủy'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (nameController.text.isNotEmpty) {
                    await _editSchool(
                      school,
                      nameController.text,
                      descController.text,
                    );
                    Navigator.pop(context);
                  }
                },
                child: Text('Cập nhật'),
              ),
            ],
          ),
    );
  }

  void _showAddDepartmentDialog() {
    TextEditingController nameController = TextEditingController();
    TextEditingController descController = TextEditingController();
    String? selectedSchoolId;

    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setState) => AlertDialog(
                  title: Text('Thêm Khoa mới'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DropdownButtonFormField<String>(
                        value: selectedSchoolId,
                        decoration: InputDecoration(
                          labelText: 'Chọn Trường',
                          border: OutlineInputBorder(),
                        ),
                        items:
                            schools.map((school) {
                              return DropdownMenuItem(
                                value: school.id,
                                child: Text(school.name),
                              );
                            }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedSchoolId = value;
                          });
                        },
                      ),
                      SizedBox(height: 16),
                      TextField(
                        controller: nameController,
                        decoration: InputDecoration(
                          labelText: 'Tên Khoa',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 16),
                      TextField(
                        controller: descController,
                        decoration: InputDecoration(
                          labelText: 'Mô tả',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Hủy'),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        if (nameController.text.isNotEmpty &&
                            selectedSchoolId != null) {
                          await _addDepartment(
                            nameController.text,
                            descController.text,
                            selectedSchoolId!,
                          );

                          if (!mounted)
                            return; // 👈 kiểm tra trước khi dùng context
                          Navigator.pop(context);
                        }
                      },
                      child: const Text('Thêm'),
                    ),
                  ],
                ),
          ),
    );
  }

  void _showEditDepartmentDialog(Department department) {
    TextEditingController nameController = TextEditingController(
      text: department.name,
    );
    TextEditingController descController = TextEditingController(
      text: department.description,
    );
    String? selectedSchoolId = department.schoolId;

    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setState) => AlertDialog(
                  title: Text('Sửa Khoa'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DropdownButtonFormField<String>(
                        value: selectedSchoolId,
                        decoration: InputDecoration(
                          labelText: 'Chọn Trường',
                          border: OutlineInputBorder(),
                        ),
                        items:
                            schools.map((school) {
                              return DropdownMenuItem(
                                value: school.id,
                                child: Text(school.name),
                              );
                            }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedSchoolId = value;
                          });
                        },
                      ),
                      SizedBox(height: 16),
                      TextField(
                        controller: nameController,
                        decoration: InputDecoration(
                          labelText: 'Tên Khoa',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 16),
                      TextField(
                        controller: descController,
                        decoration: InputDecoration(
                          labelText: 'Mô tả',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Hủy'),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        if (nameController.text.isNotEmpty &&
                            selectedSchoolId != null) {
                          await _editDepartment(
                            department,
                            nameController.text,
                            descController.text,
                            selectedSchoolId!,
                          );

                          if (!mounted) {
                            return; // 👈 đảm bảo widget chưa bị dispose
                          }

                          Navigator.pop(context);
                        }
                      },
                      child: const Text('Cập nhật'),
                    ),
                  ],
                ),
          ),
    );
  }

  Future<void> _addSchool(String name, String description) async {
    String id = 'school_${DateTime.now().millisecondsSinceEpoch}';

    // Thử lưu vào database trước
    bool success = await DatabaseHelper.instance.insertSchool(
      id,
      name,
      description,
    );

    if (success) {
      // Nếu lưu database thành công, tải lại dữ liệu
      await _loadDataFromDatabase();
    } else {
      // Nếu không thể lưu vào database, chỉ cập nhật local
      setState(() {
        schools.add(School(id: id, name: name, description: description));
      });
      _updateSchoolDepartments();
    }
  }

  Future<void> _editSchool(
    School school,
    String name,
    String description,
  ) async {
    bool success = await DatabaseHelper.instance.updateSchool(
      school.id,
      name,
      description,
    );

    if (success) {
      await _loadDataFromDatabase();
    } else {
      // Fallback to local update
      setState(() {
        school.name = name;
        school.description = description;
      });
    }
  }

  Future<void> _deleteSchool(School school) async {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Xác nhận xóa'),
            content: Text(
              'Bạn có chắc muốn xóa trường "${school.name}"?\n'
              'Tất cả các khoa thuộc trường này cũng sẽ bị xóa.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Hủy'),
              ),
              ElevatedButton(
                onPressed: () async {
                  bool success = await DatabaseHelper.instance.deleteSchool(
                    school.id,
                  );

                  if (success) {
                    await _loadDataFromDatabase();
                  } else {
                    // Fallback to local delete
                    setState(() {
                      departments.removeWhere(
                        (dept) => dept.schoolId == school.id,
                      );
                      schools.remove(school);
                    });
                    _updateSchoolDepartments();
                  }

                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: Text('Xóa'),
              ),
            ],
          ),
    );
  }

  Future<void> _addDepartment(
    String name,
    String description,
    String schoolId,
  ) async {
    String id = 'dept_${DateTime.now().millisecondsSinceEpoch}';

    bool success = await DatabaseHelper.instance.insertDepartment(
      id,
      name,
      description,
      schoolId,
    );

    if (success) {
      await _loadDataFromDatabase();
    } else {
      // Fallback to local add
      setState(() {
        departments.add(
          Department(
            id: id,
            name: name,
            description: description,
            schoolId: schoolId,
          ),
        );
      });
      _updateSchoolDepartments();
    }
  }

  Future<void> _editDepartment(
    Department department,
    String name,
    String description,
    String schoolId,
  ) async {
    bool success = await DatabaseHelper.instance.updateDepartment(
      department.id,
      name,
      description,
      schoolId,
    );

    if (success) {
      await _loadDataFromDatabase();
    } else {
      // Fallback to local update
      setState(() {
        department.name = name;
        department.description = description;
        department.schoolId = schoolId;
      });
      _updateSchoolDepartments();
    }
  }

  Future<void> _deleteDepartment(Department department) async {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Xác nhận xóa'),
            content: Text('Bạn có chắc muốn xóa khoa "${department.name}"?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Hủy'),
              ),
              ElevatedButton(
                onPressed: () async {
                  bool success = await DatabaseHelper.instance.deleteDepartment(
                    department.id,
                  );

                  if (success) {
                    await _loadDataFromDatabase();
                  } else {
                    // Fallback to local delete
                    setState(() {
                      departments.remove(department);
                    });
                    _updateSchoolDepartments();
                  }

                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: Text('Xóa'),
              ),
            ],
          ),
    );
  }

  @override
  void dispose() {
    // Đóng kết nối database khi widget bị dispose
    DatabaseHelper.instance.close();
    super.dispose();
  }
}
