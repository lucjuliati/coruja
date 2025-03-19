import 'package:coruja/models/query_param.dart';
import 'package:flutter/cupertino.dart';

class ParamsController extends ChangeNotifier {
  List<QueryParam> params = [
    QueryParam(
      key: TextEditingController(),
      value: TextEditingController(),
      enabled: true,
    ),
  ];

  void addNewParam() {}
}
