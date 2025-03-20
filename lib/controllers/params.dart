import 'package:flutter/cupertino.dart';

import '../models/query_param.dart';

class ParamsController extends ChangeNotifier {
  ParamsController._internal();

  static final ParamsController instance = ParamsController._internal();

  factory ParamsController() {
    return instance;
  }

  List<QueryParam> params = [
    QueryParam(
      key: TextEditingController(),
      value: TextEditingController(),
      enabled: true,
    ),
  ];

  List<QueryParam> headers = [
    QueryParam(
      key: TextEditingController(text: 'Cache-Control'),
      value: TextEditingController(text: 'no-cache'),
      enabled: true,
    ),
    QueryParam(
      key: TextEditingController(text: 'Accept'),
      value: TextEditingController(text: '*/*'),
      enabled: true,
    ),
    QueryParam(
      key: TextEditingController(text: 'Connection'),
      value: TextEditingController(text: 'keep-alive'),
      enabled: true,
    ),
    QueryParam(
      key: TextEditingController(text: 'Authorization'),
      value: TextEditingController(),
      enabled: true,
    ),
  ];

  void toggleVisibility(String type, int index) {
    if (type == 'params') {
      params[index].enabled = !params[index].enabled;
    } else if (type == 'headers') {
      headers[index].enabled = !headers[index].enabled;
    }

    notifyListeners();
  }

  void deleteResource(String type, int index) {
    if (type == 'params') {
      params.removeAt(index);
    } else if (type == 'headers') {
      headers.removeAt(index);
    }

    notifyListeners();
  }

  void addResource(String type) {
    var newItem = QueryParam(
      key: TextEditingController(),
      value: TextEditingController(),
      enabled: true,
    );

    if (type == 'params') {
      params.add(newItem);
    } else if (type == 'headers') {
      headers.add(newItem);
    }

    notifyListeners();
  }
}
