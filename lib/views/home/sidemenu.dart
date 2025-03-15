import 'package:flutter/material.dart';

import '../../components/label.dart';
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
                  widget.controller.createProject();
                  Navigator.of(context).pop();
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

  void newRequestDialog() {
    ThemeData theme = Theme.of(context);
    var name = TextEditingController();
    int? selectedProject;

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
                    const Label(text: 'Request name'),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: TextField(
                        controller: name,
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
                    const SizedBox(height: 8),
                    const Label(text: 'Project'),
                    SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: Material(
                          color: theme.inputDecorationTheme.fillColor,
                          child: DropdownButton(
                            onChanged: (value) => setState(() {
                              selectedProject = value;
                            }),
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            underline: Container(
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(color: theme.dividerColor),
                                ),
                              ),
                            ),
                            style: TextStyle(fontSize: 14),
                            value: selectedProject,
                            icon: const Icon(Icons.arrow_drop_down),
                            isExpanded: true,
                            items: menuItems,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: FilledButton(
                        onPressed: selectedProject != null
                            ? () => widget.controller.createRequest(name: name.text, project: selectedProject!)
                            : null,
                        child: Text('Create'),
                      ),
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

  void _showPopupMenu(Request request, Offset position) async {
    await showMenu(
      context: context,
      position: RelativeRect.fromLTRB(position.dx, position.dy, position.dx + 1, position.dy + 1),
      items: [
        PopupMenuItem(value: 'rename', child: Text('Rename')),
        PopupMenuItem(value: 'delete', child: Text('Delete')),
      ],
    ).then((value) {
      if (value != null) {
        print('Selected: $value');
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
                        child: Row(spacing: 6, children: [Icon(Icons.add), Text('New')]),
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
                        return ListTile(
                          onTap: () => widget.controller.setProjectExpanded(project.id),
                          title: Opacity(
                            opacity: 0.85,
                            child: Text(project.name, style: TextStyle(fontSize: 14)),
                          ),
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

                            return Container(
                              margin: const EdgeInsets.symmetric(vertical: 12),
                              child: InkWell(
                                onSecondaryTapUp: (details) {
                                  _showPopupMenu(request, details.globalPosition);
                                },
                                onTap: () => widget.controller.select(request),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(request.name, style: TextStyle(fontWeight: FontWeight.bold)),
                                      Text(
                                        request.method!.toUpperCase(),
                                        style: TextStyle(
                                          color: methodColor[request.method!.toUpperCase()],
                                          fontWeight: FontWeight.bold,
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
