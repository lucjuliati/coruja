import '../database/database.dart';

class ProjectData {
  Project project;
  List<Request> requests;
  bool isExpanded = false;
  bool isRenaming = false;

  ProjectData({required this.project, required this.requests});
}
