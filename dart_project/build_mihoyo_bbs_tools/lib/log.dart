import 'dart:io';

import 'package:logger/logger.dart';

class Log extends Logger {
  Log({
    super.filter,
    super.printer,
    super.output,
    super.level,
  });

  @override
  void e(
    dynamic message, {
    DateTime? time,
    Object? error,
    StackTrace? stackTrace,
  }) {
    log(Level.error, message, time: time, error: error, stackTrace: stackTrace);
    exit(1);
  }
}
