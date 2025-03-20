import 'package:flutter/material.dart';

class QueryParam {
  TextEditingController key;
  TextEditingController value;
  bool enabled = true;

  QueryParam({
    required this.key,
    required this.value,
    this.enabled = true,
  });

  Map<String, String> toMap() {
    return <String, String>{'key': key.text, 'value': value.text};
  }
}
