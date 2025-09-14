import 'package:logger/logger.dart';

final logger = Logger(
  printer: PrettyPrinter(
    methodCount: 0,       // số dòng stack trace
    errorMethodCount: 5,  // số dòng stack trace cho error
    lineLength: 50,       // độ dài mỗi log
    colors: true,         // bật màu
    printEmojis: true,    // dùng emoji
   dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart, // ✅ thay cho printTime   // in timestamp
  ),
);
