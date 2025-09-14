class DatabaseConfig {
  // Cấu hình kết nối MySQL
  static const String host = 'localhost'; // Thay đổi thành IP server của bạn
  static const int port = 3306;
  static const String username = 'root'; // Username MySQL của bạn
  static const String password = 'Meo@2004'; // Password MySQL của bạn
  static const String database = 'phenikaa_university';

  // Timeout settings
  static const int connectionTimeout = 30; // seconds
  static const int maxRetryAttempts = 3;

  // Thông tin kết nối cho các môi trường khác nhau
  static const Map<String, Map<String, dynamic>> environments = {
    'development': {
      'host': 'localhost',
      'port': 3306,
      'username': 'root',
      'password': 'Meo@2004',
      'database': 'phenikaa_university',
    },
    'production': {
      'host': 'your-production-server.com',
      'port': 3306,
      'username': 'prod_user',
      'password': 'your_secure_password',
      'database': 'phenikaa_university_prod',
    },
    'testing': {
      'host': 'localhost',
      'port': 3306,
      'username': 'test_user',
      'password': 'test_password',
      'database': 'phenikaa_university_test',
    },
  };

  // Lấy cấu hình theo môi trường
  static Map<String, dynamic> getConfig([String environment = 'development']) {
    return environments[environment] ?? environments['development']!;
  }
}
