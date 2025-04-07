import 'dart:convert';

import 'package:flutter/cupertino.dart';

import '../controllers/request.dart';
import '../database/database.dart';
import 'query_param.dart';

class ParamsManager {
  late final RequestController controller;
  final Request? request;
  var body = TextEditingController();

  List<QueryParam> params = [
    QueryParam(
      key: TextEditingController(),
      value: TextEditingController(),
      enabled: true,
      hidden: false,
    ),
  ];

  List<QueryParam> headers = [
    QueryParam(
      key: TextEditingController(text: 'Cache-Control'),
      value: TextEditingController(text: 'no-cache'),
      enabled: true,
      hidden: true,
    ),
    QueryParam(
      key: TextEditingController(text: 'Accept'),
      value: TextEditingController(text: '*/*'),
      enabled: true,
      hidden: true,
    ),
    QueryParam(
      key: TextEditingController(text: 'Connection'),
      value: TextEditingController(text: 'keep-alive'),
      enabled: true,
      hidden: true,
    ),
  ];

  ParamsManager(this.request, this.controller) {
    if (request != null) {
      body.text = request!.body ?? '';
      getHeaders(request!);
      getParamsFromURL(request!);
    }
  }

  void getHeaders(Request request) {
    if (request.headers == null || request.headers!.isEmpty) return;

    var headers = <QueryParam>[];

    for (var header in json.decode(request.headers!)) {
      headers.add(
        QueryParam(
          key: TextEditingController(text: header['key'] ?? ''),
          value: TextEditingController(text: header['value'] ?? ''),
          enabled: header['enabled'] ?? true,
          hidden: header['hidden'] ?? true,
        ),
      );
    }

    this.headers = headers;
    controller.forceUpdate();
  }

  void getParamsFromURL(Request? request) {
    if (request == null) return;

    Uri uri = Uri.parse(request.url ?? '');

    if (uri.queryParameters.entries.isEmpty) return;

    var params = <QueryParam>[];

    for (var param in uri.queryParameters.entries) {
      params.add(
        QueryParam(
          key: TextEditingController(text: param.key),
          value: TextEditingController(text: param.value),
          enabled: true,
          hidden: false,
        ),
      );
    }

    this.params = params;
    controller.forceUpdate();
  }

  void toggleVisibility(String type, int index) {
    if (type == 'params') {
      params[index].enabled = !params[index].enabled;
    } else if (type == 'headers') {
      headers[index].enabled = !headers[index].enabled;
    }

    controller.forceUpdate();
  }

  void deleteResource(String type, int index) {
    if (type == 'params') {
      params.removeAt(index);
    } else if (type == 'headers') {
      headers.removeAt(index);
    }

    controller.forceUpdate();
    Future.delayed(const Duration(milliseconds: 100), () => controller.changeParam());
  }

  void addResource(String type) {
    var newItem = QueryParam(
      key: TextEditingController(),
      value: TextEditingController(),
      hidden: false,
      enabled: true,
    );

    if (type == 'params') {
      params.add(newItem);
    } else if (type == 'headers') {
      headers.add(newItem);
    }

    controller.forceUpdate();
    Future.delayed(const Duration(milliseconds: 100), () => controller.changeParam());
  }
}
