import 'package:flutter/material.dart';

class QueryParam {
  TextEditingController key;
  TextEditingController value;
  bool enabled = true;
  bool hidden = false;

  QueryParam({
    required this.key,
    required this.value,
    this.enabled = true,
    required this.hidden,
  });

  Map<String, dynamic> toMap() {
    return {
      'key': key.text,
      'value': value.text,
      'enabled': enabled,
      'hidden': hidden,
    };
  }
}
