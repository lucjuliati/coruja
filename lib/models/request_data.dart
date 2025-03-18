import 'dart:io';

class ResponseData {
  HttpClientResponse response;
  String? body;
  int? elapsedTime;
  bool isJson = false;

  ResponseData({
    required this.response,
    this.body,
    this.elapsedTime,
  });
}
