import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import '../components/dialog_manager.dart';
import '../database/database.dart';
import '../models/params_manager.dart';
import '../models/project_data.dart';
import '../models/request_data.dart';
import '../utils/helper.dart';

class RequestController extends ChangeNotifier {
  RequestController._internal();

  static final RequestController instance = RequestController._internal();

  factory RequestController(BuildContext context) {
    instance.context = context;

    return instance;
  }

  var name = TextEditingController();
  var url = TextEditingController();
  final db = AppDatabase();
  ParamsManager? paramsManager;
  late BuildContext context;
  Request? selectedRequest;
  List<Project> projects = [];
  List<Request> requests = [];
  bool loading = false;
  bool hiddenHeaders = true;
  var projectData = <int, ProjectData>{};
  ResponseData? responseData;
  int tabIndex = 0;

  void select(Request request) {
    selectedRequest = null;
    responseData = null;
    selectedRequest = request;
    paramsManager = ParamsManager(request, this);
    notifyListeners();
  }

  void forceUpdate() {
    notifyListeners();
  }

  void setTab(int index) {
    tabIndex = index;
    notifyListeners();
  }

  void findParams() {
    Uri uri = Uri.parse(url.text);

    for (var param in uri.queryParameters.entries) {
      var found = Helper.findOrNull(paramsManager!.params, (p) => p.key.text == param.key);
      if (found != null) {
        found.value.text = param.value;
      }
    }
  }

  void changeParam() {
    Map<String, dynamic> replaceMap = {};

    for (var param in paramsManager!.params) {
      if (param.key.text.isEmpty) continue;

      replaceMap[param.key.text] = param.value.text;
    }

    Uri newUri = Uri.parse(url.text).replace(queryParameters: replaceMap);

    if (replaceMap.isEmpty) {
      url.text = newUri.toString().replaceAll('?', '');
    } else {
      url.text = newUri.toString();
    }
  }

  void toggleHeaderVisibility() {
    hiddenHeaders = !hiddenHeaders;
    notifyListeners();
  }

  void setProjectExpanded(int id) {
    projectData[id]?.isExpanded = !projectData[id]!.isExpanded;
    getRequests(projectData[id]!.project.id);
    notifyListeners();
  }

  void setProjectExpandedIndex(int index) {
    int key = projectData.entries.toList()[index].key;
    projectData[key]?.isExpanded = !projectData[key]!.isExpanded;
    projectData[key]?.isRenaming = false;

    getRequests(projectData[key]!.project.id);
    notifyListeners();
  }

  Future<void> deleteRequest(Request request) async {
    try {
      await (db.delete(db.requests)..where((r) => r.id.equals(request.id))).go();

      if (request.id == selectedRequest?.id) {
        selectedRequest = null;
        notifyListeners();
      }

      getRequests(request.project!);
    } catch (err) {
      debugPrint(err.toString());
    }
  }

  Future<void> deleteProject(Project project) async {
    try {
      await (db.delete(db.requests)..where((r) => r.project.equals(project.id))).go();
      await (db.delete(db.projects)..where((p) => p.id.equals(project.id))).go();

      await getProjects();
    } catch (err) {
      debugPrint(err.toString());
    }
  }

  void renameProject(Project project) {
    projectData[project.id]!.isRenaming = !projectData[project.id]!.isRenaming;
    notifyListeners();
  }

  Future<bool> createRequest({String? name, String? method, required int project}) async {
    bool status = false;

    try {
      if (name!.isEmpty || name.length > 64) {
        DialogManager(context).showModal(title: 'Error', content: 'Invalid name length!');
        throw ErrorDescription('InvalidLength');
      }

      int id = await db.into(db.requests).insert(
            RequestsCompanion.insert(
              name: name,
              method: Value('get'),
              project: Value(project),
            ),
          );

      await getRequests(projectData[project]!.project.id, set: id);
      setProjectExpanded(project);
      status = true;
    } catch (err) {
      if (err == 'InvalidLength') {
        if (context.mounted) {
          DialogManager(context).showSnackBar(title: 'Request name must have at least 5 characters!');
        }
      }

      debugPrint(err.toString());
    }

    return status;
  }

  Future<void> createProject({String? name}) async {
    try {
      await db.into(db.projects).insert(ProjectsCompanion.insert(name: name ?? 'New Project'));
      await getProjects();

      notifyListeners();
    } catch (err) {
      debugPrint(err.toString());
    }
  }

  Future<List<Project>> getProjects() async {
    projects = (await db.select(db.projects).get());
    projectData = {};

    for (Project project in projects) {
      projectData[project.id] = ProjectData(
        project: project,
        requests: [],
      );
    }

    notifyListeners();
    return projects;
  }

  Future<List<Request>> getRequests(int projectId, {int? set}) async {
    var query = db.select(db.requests)..where((request) => request.project.equals(projectId));
    requests = await query.get();
    projectData[projectId]!.requests = requests;

    if (set != null) {
      var request = requests.firstWhere((r) => r.id == set);
      select(request);
    }

    notifyListeners();
    return requests;
  }

  Future<void> saveRequest({String? name, String? url, String? method}) async {
    try {
      List<Map> headersMap = paramsManager!.headers.map((p) => p.toMap()).toList();

      await db.update(db.requests).replace(
            selectedRequest!.copyWith(
              name: name ?? selectedRequest?.name,
              url: Value(url ?? selectedRequest?.url),
              method: Value(method ?? selectedRequest?.method),
              body: Value(paramsManager?.body.text ?? ''),
              headers: Value(json.encode(headersMap)),
            ),
          );

      await getRequests(selectedRequest!.project!);

      var query = db.select(db.requests)..where((request) => request.id.equals(selectedRequest!.id));

      selectedRequest = (await query.getSingle());
      notifyListeners();
    } catch (err) {
      debugPrint(err.toString());
    }
  }

  Future<void> saveProject(Project project, {String? name}) async {
    try {
      await db.update(db.projects).replace(project.copyWith(name: name));
      getProjects();
    } catch (err) {
      debugPrint(err.toString());
    }
  }

  Future<void> send({required String url, required String method}) async {
    Uri address = Uri.parse(url);
    HttpClient httpClient = HttpClient();
    ResponseData? data;
    final stopwatch = Stopwatch();
    var headers = paramsManager?.headers.where((h) => h.enabled).map((h) => h.toMap()).toList();
    responseData = null;

    notifyListeners();

    try {
      var methodMapping = <String, Future<HttpClientRequest> Function()>{
        'GET': () => httpClient.getUrl(address),
        'POST': () => httpClient.postUrl(address),
        'PATCH': () => httpClient.patchUrl(address),
        'PUT': () => httpClient.putUrl(address),
        'DELETE': () => httpClient.deleteUrl(address),
      };

      if (!methodMapping.containsKey(method)) {
        DialogManager(context).showSnackBar(title: 'Invalid HTTP method!');
        return;
      }

      var request = await methodMapping[method.toUpperCase()]!();

      if (headers != null) {
        for (var header in headers) {
          if (header['key']!.isNotEmpty && header['value']!.isNotEmpty) {
            request.headers.set(header['key']!, header['value']!);
          }
        }
      }

      if (['POST', 'PUT', 'PATCH'].contains(method.toUpperCase())) {
        request.write(paramsManager!.body.text);
      }

      loading = true;
      notifyListeners();

      stopwatch.start();
      await request.close().then((res) async {
        String initialData = await rootBundle.loadString('lib/assets/index.html');
        stopwatch.stop();

        data = ResponseData(response: res);
        data!.elapsedTime = stopwatch.elapsedMilliseconds;
        String? body;

        if (res.statusCode == 200) {
          if (res.headers['content-type']![0].contains('application/json')) {
            body = await res.transform(utf8.decoder).join();
            data!.isJson = true;
            data!.body = body;
          } else {
            body = await res.transform(latin1.decoder).join();
            data!.body = body;
          }

          if (data!.isJson == false) {
            initialData = body;
          }
        } else {
          print('Error: HTTP ${res.statusCode}');
          body = await res.transform(latin1.decoder).join();
          data!.body = body;
          data!.isJson = false;

          if (data!.body == '{}') {
            initialData = '';
          } else {
            initialData = data!.body ?? '';
          }
        }

        data!.widget = ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Container(
            color: Colors.transparent,
            child: InAppWebView(
              onLoadStop: (controller, url) async {
                if (!data!.isJson) return;
                String fileContents = await rootBundle.loadString('lib/assets/jsonViewer.js');

                controller.evaluateJavascript(
                  source: 'let jsonData = $body; $fileContents',
                );
              },
              initialSettings: InAppWebViewSettings(
                allowsBackForwardNavigationGestures: false,
                javaScriptEnabled: true,
              ),
              initialData: InAppWebViewInitialData(data: initialData),
            ),
          ),
        );

        loading = false;
        notifyListeners();
      });
    } catch (e) {
      print('Exception: $e');
      stopwatch.stop();

      data = ResponseData(response: null);
      data!.elapsedTime = stopwatch.elapsedMilliseconds;
    } finally {
      loading = false;

      if (data != null) {
        responseData = data;
      }

      httpClient.close();
      notifyListeners();
    }
  }

  close() {
    selectedRequest = null;
    responseData = null;
    notifyListeners();
  }
}
