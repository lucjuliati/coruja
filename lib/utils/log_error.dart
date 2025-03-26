import 'dart:io';

import 'package:path_provider/path_provider.dart';

Future<void> logError(String error, StackTrace? stack) async {
  final logFile = await _getLogFile();
  final timeStamp = DateTime.now().toIso8601String();
  final logEntry = '$timeStamp - ERROR: $error\nSTACKTRACE: $stack\n\n';

  logFile.writeAsStringSync(logEntry, mode: FileMode.append);
}

Future<File> _getLogFile() async {
  final directory = await getApplicationSupportDirectory();
  final filePath = '${directory.path}/errors.log';
  return File(filePath);
}
