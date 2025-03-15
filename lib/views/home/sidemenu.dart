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
                makeButton("Project", Color(0xFFF1B127).withValues(alpha: 0.8), Icons.folder, () {
                  widget.controller.createResource("project", true);
                  Navigator.of(context).pop();
                }),
                makeButton("Request", const Color(0xFF5A72DC), Icons.http, () {
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
    var selectedProject;

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
                      "New Request",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                    ),
                    const SizedBox(height: 15),
                    const Label(text: "Request name"),
                    TextField(decoration: InputDecoration(), style: TextStyle(fontSize: 14)),
                    const SizedBox(height: 8),
                    const Label(text: "Project"),
                    SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: DropdownButton(
                        onChanged:
                            (value) => setState(() {
                              selectedProject = value;
                            }),
                        value: selectedProject,
                        icon: const Icon(Icons.arrow_drop_down),
                        isExpanded: true,
                        items: menuItems,
                      ),
                    ),
                    const SizedBox(height: 40),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: FilledButton(
                        onPressed: selectedProject != null ? () {} : null,
                        child: Text("Create"),
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
      builder:
          (context, child) => Container(
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
                            "My projects",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          FilledButton(
                            onPressed: newResourceDialog,
                            child: Row(spacing: 6, children: [Icon(Icons.add), Text("New")]),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(child: const SizedBox(height: 12)),
                  SliverToBoxAdapter(
                    child: ExpansionPanelList(
                      expandedHeaderPadding: const EdgeInsets.all(0),
                      expansionCallback: (index, isExpanded) {
                        widget.controller.setProjectExpandedIndex(index);
                      },
                      children:
                          widget.controller.projects.map<ExpansionPanel>((project) {
                            bool isExpanded = widget.controller.projectData[project.id]!.isExpanded;

                            return ExpansionPanel(
                              canTapOnHeader: true,
                              isExpanded: isExpanded,
                              headerBuilder: (context, isExpanded) {
                                return ListTile(
                                  onTap: () => widget.controller.setProjectExpanded(project.id),
                                  title: Opacity(
                                    opacity: 0.85,
                                    child: Text(project.name, style: TextStyle(fontSize: 14)),
                                  ),
                                );
                              },
                              body: Column(children: [Text("bordy")]),
                            );
                          }).toList(),
                    ),
                  ),

                  // SliverList.builder(
                  //   itemCount: widget.controller.requests.length,
                  //   itemBuilder: (context, index) {
                  //     var request = widget.controller.requests[index];
                  //     return Container(
                  //       margin: const EdgeInsets.symmetric(vertical: 12),
                  //       child: InkWell(
                  //         onSecondaryTapUp: (details) {
                  //           _showPopupMenu(request, details.globalPosition);
                  //         },
                  //         onTap: () => widget.controller.select(request),
                  //         child: Padding(
                  //           padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  //           child: Column(
                  //             crossAxisAlignment: CrossAxisAlignment.start,
                  //             children: [
                  //               Text(request.name, style: TextStyle(fontWeight: FontWeight.bold)),
                  //               Text(request.method!.toUpperCase()),
                  //             ],
                  //           ),
                  //         ),
                  //       ),
                  //     );
                  //   },
                  // ),
                ],
              ),
            ),
          ),
    );
  }
}
