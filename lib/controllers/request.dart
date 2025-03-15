import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:flutter/material.dart';

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
  dynamic response;
  var projectData = <int, ProjectData>{};

  void select(Request request) {
    selectedRequest = request;
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

    getRequests(projectData[key]!.project.id);
    notifyListeners();
  }

  Future<void> deleteRequest(Request request) async {
    await (db.delete(db.requests)..where((req) => req.id.equals(request.id))).go();

    if (request.id == selectedRequest?.id) {
      selectedRequest = null;
      notifyListeners();
    }

    getRequests(request.project!);
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

  Future<void> createProject() async {
    try {
      await db.into(db.projects).insert(ProjectsCompanion.insert(name: 'New Project')).then((id) {
        var data = getProjects();
        print(data);
      });

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

    for (Project project in projects) {
      projectData[project.id] = ProjectData(project: project, requests: [], isExpanded: false);
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
              name: name,
              url: Value(url),
              method: Value(method ?? 'get'),
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

  Future<void> send({required String url, required String method}) async {
    final RegExp urlRegex = RegExp(
      r'^(https?:\/\/)'
      r'((localhost|\d{1,3}(\.\d{1,3}){3}|[a-zA-Z0-9.-]+)'
      r'(:\d{1,5})?)'
      r'(\/[^\s]*)?$',
      caseSensitive: false,
      multiLine: false,
    );

    if (!urlRegex.hasMatch(url)) {
      ScaffoldMessenger.of(context).clearSnackBars();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          content: Align(
            alignment: Alignment.bottomRight,
            child: Container(
              width: 350,
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
              decoration: BoxDecoration(
                color: Theme.of(context).secondaryHeaderColor.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                spacing: 8,
                children: [
                  Icon(Icons.close),
                  Text(
                    'Invalid URL!',
                    style: TextStyle(color: Theme.of(context).textTheme.bodySmall!.color),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      return;
    }

    // var address = Uri.parse('https://jsonplaceholder.typicode.com/posts/1');
    var address = Uri.parse(url);
    print(address);
    var httpClient = HttpClient();

    try {
      var request = await httpClient.getUrl(address);
      var response = await request.close();

      if (response.statusCode == 200) {
        var responseBody = await response.transform(utf8.decoder).join();
        print('Response: $responseBody');
        this.response = responseBody;
        notifyListeners();
      } else {
        print('Error: HTTP ${response.statusCode}');
      }
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
  bool isExpanded;

  ProjectData({required this.project, required this.requests, required this.isExpanded});
}
