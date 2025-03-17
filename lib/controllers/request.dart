import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:flutter_json_view/flutter_json_view.dart';

import '../database/database.dart';

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
  Widget? response;
  bool loading = false;
  var projectData = <int, ProjectData>{};
  int tabIndex = 0;

  void select(Request request) {
    response = null;
    selectedRequest = null;
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
      await db.into(db.requests).insert(
            RequestsCompanion.insert(
              name: name ?? 'New Request',
              method: Value('get'),
              project: Value(project),
            ),
          );

      var data = getRequests(projectData[project]!.project.id);
      print(data);
    } catch (err) {
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

  void clearResponse() {
    response = null;
    notifyListeners();
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

    try {
      var methodMapping = <String, dynamic>{
        'GET': await httpClient.getUrl(address),
        'POST': await httpClient.postUrl(address),
        'PATCH': await httpClient.patchUrl(address),
        'PUT': await httpClient.putUrl(address),
        'DELETE': await httpClient.deleteUrl(address),
      };

      HttpClientRequest request = methodMapping[method.toUpperCase()];

      loading = true;
      notifyListeners();

      request.close().then((res) async {
        if (res.statusCode == 200) {
          String body = await res.transform(utf8.decoder).join();

          response = JsonView.string(
            body,
            theme: JsonViewTheme(
              defaultTextStyle: TextStyle(fontSize: 12.5),
              backgroundColor: Colors.transparent,
              keyStyle: TextStyle(color: const Color.fromARGB(255, 109, 188, 224)),
              intStyle: TextStyle(color: const Color.fromARGB(255, 111, 184, 114)),
              stringStyle: TextStyle(color: const Color.fromARGB(255, 201, 129, 96)),
            ),
          );

          loading = false;
          notifyListeners();
        } else {
          print('Error: HTTP ${res.statusCode}');
        }
      });
    } catch (e) {
      print('Exception: $e');
    } finally {
      httpClient.close();
    }
  }
}

class ProjectData {
  Project project;
  List<Request> requests;
  bool isExpanded = false;
  bool isRenaming = false;

  ProjectData({required this.project, required this.requests});
}
