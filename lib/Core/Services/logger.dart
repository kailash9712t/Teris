import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';


class ErrorLogs {
  static Logger logs = Logger(level: kReleaseMode ? Level.off : Level.debug,printer: PrettyPrinter(methodCount: 1,colors: true));

  static void logError(
    String filename,
    String message,
    String methodName, [
    dynamic error,
    StackTrace? trace,
  ]) {
    final errorLog = {
      'timestamp': DateTime.now().toString(),
      'file': filename,
      'method': methodName,
      'message': error?.toString(),
      'stackTrace': trace?.toString(),
    };

    logs.w('$filename.$methodName: $message');
    logs.w('Error in Details : $errorLog');
  }
}
