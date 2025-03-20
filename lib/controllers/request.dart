import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import '../components/dialog_manager.dart';
import '../database/database.dart';
import '../models/project_data.dart';
import '../models/request_data.dart';
import 'params.dart';

class RequestController extends ChangeNotifier {
  RequestController._internal();

  static final RequestController instance = RequestController._internal();

  factory RequestController(BuildContext context) {
    instance.context = context;
    return instance;
  }

  final db = AppDatabase();
  late BuildContext context;
  Request? selectedRequest;
  List<Project> projects = [];
  List<Request> requests = [];
  bool loading = false;
  var projectData = <int, ProjectData>{};
  ResponseData? responseData;
  int tabIndex = 0;

  void select(Request request) {
    selectedRequest = null;
    responseData = null;
    notifyListeners();
    selectedRequest = request;
    notifyListeners();
  }

  void setTab(int index) {
    tabIndex = index;
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
    await (db.delete(db.requests)..where((r) => r.id.equals(request.id))).go();

    if (request.id == selectedRequest?.id) {
      selectedRequest = null;
      notifyListeners();
    }

    getRequests(request.project!);
  }

  Future<void> deleteProject(Project project) async {
    await (db.delete(db.projects)..where((p) => p.id.equals(project.id))).go();
    await getProjects();
  }

  void renameProject(Project project) {
    projectData[project.id]!.isRenaming = !projectData[project.id]!.isRenaming;
    notifyListeners();
  }

  Future<void> createRequest({String? name, String? method, required int project}) async {
    try {
      if (name!.length < 5) throw ErrorDescription('InvalidLength');

      await db.into(db.requests).insert(
            RequestsCompanion.insert(
              name: name,
              method: Value('get'),
              project: Value(project),
            ),
          );

      getRequests(projectData[project]!.project.id);
    } catch (err) {
      if (err == 'InvalidLength') {
        if (context.mounted) {
          DialogManager(context).showSnackBar(title: 'Request name must have at least 5 characters!');
        }
      }

      debugPrint(err.toString());
    }
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

  Future<List<Request>> getRequests(int projectId) async {
    var query = db.select(db.requests)..where((request) => request.project.equals(projectId));
    requests = await query.get();
    projectData[projectId]!.requests = requests;

    notifyListeners();
    return requests;
  }

  Future<void> saveRequest({String? name, String? url, String? method}) async {
    try {
      await db.update(db.requests).replace(
            selectedRequest!.copyWith(
              name: name ?? selectedRequest?.name,
              url: Value(url ?? selectedRequest?.url),
              method: Value(method ?? selectedRequest?.method),
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
    var paramsController = ParamsController();
    ResponseData? data;

    responseData = null;
    notifyListeners();

    List<Map<String, String>> headers = paramsController.headers.map((h) => h.toMap()).toList();

    print(headers);

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

      HttpClientRequest request = await methodMapping[method.toUpperCase()]!();

      for (var header in headers) {
        if (header['key']!.isNotEmpty && header['value']!.isNotEmpty) {
          request.headers.set(header['key']!, header['value']!);
        }
      }

      loading = true;
      notifyListeners();

      final stopwatch = Stopwatch()..start();
      await request.close().then((res) async {
        stopwatch.stop();

        data = ResponseData(response: res);
        data!.elapsedTime = stopwatch.elapsedMilliseconds;

        if (res.statusCode == 200) {
          String initialData = await File('lib/assets/index.html').readAsString();
          String? body;

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

          data!.widget = Container(
            color: Colors.transparent,
            child: InAppWebView(
              onLoadStop: (controller, url) async {
                if (!data!.isJson) return;

                String fileContents = await File('lib/assets/jsonViewer.js').readAsString();

                await controller.evaluateJavascript(
                  source: 'let jsonData = $body; $fileContents',
                );
              },
              initialSettings: InAppWebViewSettings(
                allowsBackForwardNavigationGestures: false,
                javaScriptEnabled: true,
              ),
              initialData: InAppWebViewInitialData(data: initialData),
            ),
          );
        } else {
          print('Error: HTTP ${res.statusCode}');
        }

        loading = false;
        notifyListeners();
      });
    } catch (e) {
      print('Exception: $e');
    } finally {
      loading = false;

      if (data != null) {
        responseData = data;
      }

      httpClient.close();
      notifyListeners();
    }
  }
}
