import 'dart:io';

import 'package:flutter/cupertino.dart';

class ResponseData {
  HttpClientResponse? response;
  String? body;
  int? elapsedTime;
  bool isJson = false;
  Widget? widget;

  ResponseData({
    this.response,
    this.body,
    this.elapsedTime,
    this.isJson = false,
    this.widget,
  });
}
