import 'dart:convert';
import 'dart:io';

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
  var projectData = <int, ProjectData>{};

  void select(Request request) {
    selectedRequest = request;
    notifyListeners();
  }

  void setProjectExpanded(int id) {
    projectData[id]?.isExpanded = !projectData[id]!.isExpanded;
    getRequests(projectData[id]!.project);
    notifyListeners();
  }

  void setProjectExpandedIndex(int index) {
    int key = projectData.entries.toList()[index].key;
    projectData[key]?.isExpanded = !projectData[key]!.isExpanded;

    getRequests(projectData[key]!.project);
    notifyListeners();
  }

  Future<void> createResource(String key, bool value) async {
    if (key == "request") {
      // await db
      //     .into(db.requests)
      //     .insert(RequestsCompanion.insert(name: "New request", method: Value("get")))
      //     .then((id) {
      //       var data = getSavedRequests();
      //       print(data);
      //     });
    } else if (key == "project") {
      await db.into(db.projects).insert(ProjectsCompanion.insert(name: "New Project")).then((id) {
        var data = getProjects();
        print(data);
      });
    }

    notifyListeners();
  }

  Future<List<Project>> getProjects() async {
    projects = (await db.select(db.projects).get());

    for (Project project in projects) {
      projectData[project.id] = ProjectData(project: project, requests: [], isExpanded: false);
    }

    notifyListeners();

    print("total projects ${requests.length}");
    return projects;
  }

  Future<List<Request>> getRequests(Project project) async {
    print(project.id);
    // requests = (await db.select(db.requests) .get());
    var query = db.select(db.requests)..where((request) => request.project.equals(project.id));
    requests = await query.get();

    notifyListeners();

    print("total requests ${requests.length}");
    return requests;
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
                    "Invalid URL!",
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

    var address = Uri.parse('https://jsonplaceholder.typicode.com/posts/1');
    var httpClient = HttpClient();

    try {
      var request = await httpClient.getUrl(address); // Open the request
      var response = await request.close(); // Send the request

      if (response.statusCode == 200) {
        var responseBody = await response.transform(utf8.decoder).join();
        print('Response: $responseBody');
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
