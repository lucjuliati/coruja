import 'package:flutter/material.dart';

import '../../components/cancel_button.dart';
import '../../components/input.dart';
import '../../components/label.dart';
import '../../components/select.dart';
import '../../controllers/request.dart';
import '../../database/database.dart';

class SideMenu extends StatefulWidget {
  final RequestController controller;

  const SideMenu({super.key, required this.controller});

  @override
  State<SideMenu> createState() => _SideMenuState();
}

class _SideMenuState extends State<SideMenu> {
  final methodColor = <String, Color>{
    'GET': Color(0xFF59B156),
    'POST': Colors.orange,
    'PATCH': Colors.blue,
    'PUT': Color(0xFFA267CB),
    'DELETE': Color(0xFFE45656),
  };

  @override
  void initState() {
    super.initState();
    widget.controller.getProjects();
  }

  void newResourceDialog() {
    makeButton(String label, Color color, IconData icon, Function onTap) {
      return Container(
        height: 100,
        width: 100,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => onTap(),
              child: Column(children: [Icon(icon, size: 72, color: color), Text(label)]),
            ),
          ),
        ),
      );
    }

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: Container(
            height: 200,
            width: MediaQuery.of(context).size.width * 0.4,
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
            child: Row(
              spacing: 20,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                makeButton('Project', Color(0xFFF1B127).withValues(alpha: 0.8), Icons.folder, () {
                  Navigator.pop(context);
                  Future.delayed(Duration(milliseconds: 200), newProjectDialog);
                }),
                makeButton('Request', const Color(0xFF5A72DC), Icons.http, () {
                  Navigator.pop(context);
                  Future.delayed(Duration(milliseconds: 200), newRequestDialog);
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  void newRequestDialog({Project? project}) {
    var name = TextEditingController();
    int? selectedProject;

    if (project != null) {
      selectedProject = project.id;
    }

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: StatefulBuilder(
            builder: (context, setState) {
              List<DropdownMenuItem> menuItems = [];

              for (var project in widget.controller.projects) {
                menuItems.add(DropdownMenuItem(value: project.id, child: Text(project.name)));
              }

              return Container(
                height: 310,
                width: MediaQuery.of(context).size.width * 0.4,
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'New Request',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                    ),
                    const SizedBox(height: 15),
                    Input(label: 'Name', controller: name),
                    const SizedBox(height: 8),
                    Select(
                      label: 'Project',
                      items: menuItems,
                      onChanged: (value) => setState(() {
                        selectedProject = value;
                      }),
                      value: selectedProject,
                    ),
                    const SizedBox(height: 40),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      spacing: 6,
                      children: [
                        CancelButton(onPressed: Navigator.of(context).pop),
                        FilledButton(
                          onPressed: selectedProject != null
                              ? () {
                                  widget.controller.createRequest(name: name.text, project: selectedProject!);
                                  Navigator.of(context).pop();
                                }
                              : null,
                          child: Text('Create'),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  void newProjectDialog() {
    ThemeData theme = Theme.of(context);
    var name = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: Container(
            height: 240,
            width: MediaQuery.of(context).size.width * 0.4,
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'New Project',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                ),
                const SizedBox(height: 15),
                const Label(text: 'Name'),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: TextField(
                    controller: name,
                    autofocus: true,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: theme.inputDecorationTheme.fillColor,
                      border: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.transparent),
                      ),
                    ),
                    style: TextStyle(fontSize: 14),
                  ),
                ),
                const SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  spacing: 6,
                  children: [
                    CancelButton(onPressed: Navigator.of(context).pop),
                    FilledButton(
                      onPressed: () {
                        widget.controller.createProject(name: name.text);
                        Navigator.of(context).pop();
                      },
                      child: Text('Create'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showPopupMenu(Request request, Offset position) async {
    ThemeData theme = Theme.of(context);

    await showMenu(
      context: context,
      position: RelativeRect.fromLTRB(position.dx, position.dy, position.dx + 1, position.dy + 1),
      items: [
        PopupMenuItem(
          value: 'rename',
          height: 40,
          padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
          child: Text('Rename'),
        ),
        PopupMenuItem(
          value: 'delete',
          height: 40,
          padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
          child: Text('Delete'),
        ),
      ],
      menuPadding: const EdgeInsets.symmetric(vertical: 0),
      shape: RoundedRectangleBorder(
        side: BorderSide(color: theme.dividerColor),
      ),
    ).then((value) {
      if (value == 'delete') {
        widget.controller.deleteRequest(request);
      }
    });
  }

  void _showProjectMenu(Project project, Offset position) async {
    ThemeData theme = Theme.of(context);

    List<Map> items = [
      {'value': 'new_request', 'label': 'New request'},
      {'value': 'rename', 'label': 'Rename'},
      {'value': 'delete', 'label': 'Delete'},
    ];

    List<PopupMenuEntry> menuItems = [];

    for (var item in items) {
      menuItems.add(
        PopupMenuItem(
          value: item['value'],
          height: 40,
          padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
          child: Text(item['label']),
        ),
      );
    }

    await showMenu(
      context: context,
      color: theme.inputDecorationTheme.fillColor,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy,
        position.dx + 1,
        position.dy + 1,
      ),
      menuPadding: const EdgeInsets.symmetric(vertical: 0),
      shape: RoundedRectangleBorder(
        side: BorderSide(color: theme.dividerColor),
      ),
      items: menuItems,
    ).then((value) {
      if (value == 'new_request') {
        newRequestDialog(project: project);
      } else if (value == 'rename') {
        widget.controller.renameProject(project);
      } else if (value == 'delete') {
        widget.controller.deleteProject(project);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, child) => Container(
        color: theme.cardColor,
        width: 260,
        child: Material(
          color: Colors.transparent,
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: 12, left: 12, right: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'My projects',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      FilledButton(
                        onPressed: newResourceDialog,
                        style: FilledButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                        ),
                        child: Row(
                          spacing: 4,
                          children: [
                            Icon(Icons.add),
                            Text('New', style: TextStyle(fontSize: 13)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(child: const SizedBox(height: 12)),
              SliverToBoxAdapter(
                child: ExpansionPanelList(
                  expandedHeaderPadding: EdgeInsets.zero,
                  expansionCallback: (index, isExpanded) {
                    widget.controller.setProjectExpandedIndex(index);
                  },
                  materialGapSize: 0,
                  children: widget.controller.projects.map<ExpansionPanel>((project) {
                    bool isExpanded = widget.controller.projectData[project.id]!.isExpanded;
                    var projectData = widget.controller.projectData[project.id]!;

                    return ExpansionPanel(
                      canTapOnHeader: true,
                      isExpanded: isExpanded,
                      backgroundColor: theme.secondaryHeaderColor.withValues(alpha: 0.2),
                      headerBuilder: (context, isExpanded) {
                        Widget child = ListTile(
                          onTap: () => widget.controller.setProjectExpanded(project.id),
                          title: Text(project.name, style: TextStyle(fontSize: 14)),
                        );

                        if (projectData.isRenaming) {
                          var projectName = TextEditingController(text: project.name);
                          child = Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            child: TextField(
                              controller: projectName,
                              style: TextStyle(fontSize: 14),
                              onSubmitted: (value) => widget.controller.saveProject(projectData.project, name: value),
                            ),
                          );
                        }

                        return InkWell(
                          onSecondaryTapUp: (details) {
                            _showProjectMenu(projectData.project, details.globalPosition);
                          },
                          child: child,
                        );
                      },
                      body: Material(
                        color: theme.cardColor,
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: projectData.requests.length,
                          padding: const EdgeInsets.symmetric(vertical: 0),
                          itemBuilder: (context, index) {
                            Request request = projectData.requests[index];
                            Color borderColor = request.id == widget.controller.selectedRequest?.id
                                ? theme.colorScheme.primary.withValues(alpha: 0.7)
                                : Colors.transparent;

                            return Container(
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(color: theme.dividerColor),
                                  left: BorderSide(width: 4, color: borderColor),
                                ),
                              ),
                              child: InkWell(
                                onSecondaryTapUp: (details) {
                                  _showPopupMenu(request, details.globalPosition);
                                },
                                onTap: () => widget.controller.select(request),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Opacity(
                                        opacity: 0.8,
                                        child: Text(
                                          request.name,
                                          style: TextStyle(fontSize: 13),
                                        ),
                                      ),
                                      Text(
                                        request.method!.toUpperCase(),
                                        style: TextStyle(
                                          color: methodColor[request.method!.toUpperCase()],
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
