import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../components/input.dart';
import '../../../components/param_checkbox.dart';
import '../../../controllers/request.dart';

class ExtraTabs extends StatefulWidget {
  final RequestController controller;

  const ExtraTabs({super.key, required this.controller});

  @override
  State<ExtraTabs> createState() => _ExtraTabsState();
}

class _ExtraTabsState extends State<ExtraTabs> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    List<Widget> items = [];
    List<String> labels = ['Params', 'Headers', 'Body'];

    List<Widget> children = [
      ParamTab(controller: widget.controller),
      HeadersTab(controller: widget.controller),
      BodyTab(controller: widget.controller),
    ];

    for (final (index, label) in labels.indexed) {
      bool isSelected = index == widget.controller.tabIndex;

      items.add(
        AnimatedContainer(
          duration: const Duration(milliseconds: 320),
          curve: Curves.bounceInOut,
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                width: 2,
                color: isSelected ? theme.colorScheme.primary : Colors.transparent,
              ),
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => widget.controller.setTab(index),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                child: Text(
                  label,
                  style: TextStyle(fontSize: 13),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, child) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.only(
              left: 12,
              right: 12,
            ),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Row(children: items),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 60, top: 8),
                    child: children[widget.controller.tabIndex],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class ParamTab extends StatelessWidget {
  final RequestController controller;

  const ParamTab({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    var paramsManager = controller.paramsManager;

    return Builder(
      builder: (context) {
        List<TableRow> rows = [];
        TextStyle headerStyle = TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: theme.textTheme.bodyMedium!.color!.withValues(alpha: 0.6),
        );

        for (final (index, param) in paramsManager!.params.indexed) {
          rows.add(
            TableRow(
              children: [
                Container(
                  margin: const EdgeInsets.only(right: 7),
                  child: ParamCheckbox(
                    value: param.enabled,
                    onChanged: (value) => paramsManager.toggleVisibility('params', index),
                  ),
                ),
                ParamInput(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  controller: param.key,
                  onChanged: (String value) => controller.changeParam(),
                ),
                ParamInput(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  controller: param.value,
                  onChanged: (String value) => controller.changeParam(),
                ),
                InkWell(
                  onTap: () => paramsManager.deleteResource('params', index),
                  child: Center(
                    child: FaIcon(
                      FontAwesomeIcons.trash,
                      size: 14,
                      color: theme.textTheme.bodyMedium!.color!.withValues(alpha: 0.75),
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return Container(
          constraints: BoxConstraints(minHeight: 140),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Opacity(opacity: 0.7, child: Text('Params')),
              ),
              Table(
                border: TableBorder.all(
                  color: theme.dividerColor,
                  borderRadius: BorderRadius.circular(4),
                ),
                columnWidths: const <int, TableColumnWidth>{
                  0: IntrinsicColumnWidth(),
                  1: FlexColumnWidth(),
                  2: FlexColumnWidth(),
                  3: IntrinsicColumnWidth(),
                },
                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                children: [
                  TableRow(
                    children: [
                      Container(),
                      Padding(padding: const EdgeInsets.only(left: 6), child: Text('Key', style: headerStyle)),
                      Padding(padding: const EdgeInsets.only(left: 6), child: Text('Value', style: headerStyle)),
                      InkWell(
                        onTap: () => paramsManager.addResource('params'),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                          child: Icon(
                            Icons.add,
                            size: 20,
                            color: theme.textTheme.bodyMedium!.color!.withValues(alpha: 0.75),
                          ),
                        ),
                      ),
                    ],
                  ),
                  ...rows,
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class HeadersTab extends StatelessWidget {
  final RequestController controller;

  const HeadersTab({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    var paramsManager = controller.paramsManager;

    return Builder(
      builder: (context) {
        List<TableRow> rows = [];
        TextStyle headerStyle = TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: theme.textTheme.bodyMedium!.color!.withValues(alpha: 0.6),
        );

        for (final (index, header) in paramsManager!.headers.indexed) {
          if (controller.hiddenHeaders && header.hidden) continue;

          rows.add(
            TableRow(
              children: [
                Container(
                  margin: const EdgeInsets.only(right: 7),
                  child: ParamCheckbox(
                    value: header.enabled,
                    onChanged: (value) => paramsManager.toggleVisibility('headers', index),
                  ),
                ),
                ParamInput(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  controller: header.key,
                ),
                ParamInput(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  controller: header.value,
                ),
                InkWell(
                  onTap: () => paramsManager.deleteResource('headers', index),
                  child: Center(
                    child: FaIcon(
                      FontAwesomeIcons.trash,
                      size: 14,
                      color: theme.textTheme.bodyMedium!.color!.withValues(alpha: 0.75),
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return Container(
          constraints: BoxConstraints(minHeight: 140),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    Opacity(opacity: 0.7, child: Text('Headers')),
                    Padding(
                      padding: const EdgeInsets.only(left: 16),
                      child: InkWell(
                        onTap: controller.toggleHeaderVisibility,
                        child: Text(
                          controller.hiddenHeaders ? 'Show hidden headers' : 'Hide headers',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: const Color.fromARGB(255, 90, 165, 226),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Table(
                border: TableBorder.all(
                  color: theme.dividerColor,
                  borderRadius: BorderRadius.circular(4),
                ),
                columnWidths: const <int, TableColumnWidth>{
                  0: IntrinsicColumnWidth(),
                  1: FlexColumnWidth(),
                  2: FlexColumnWidth(),
                  3: IntrinsicColumnWidth(),
                },
                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                children: [
                  TableRow(
                    children: [
                      Container(),
                      Padding(padding: const EdgeInsets.only(left: 6), child: Text('Key', style: headerStyle)),
                      Padding(padding: const EdgeInsets.only(left: 6), child: Text('Value', style: headerStyle)),
                      InkWell(
                        onTap: () => paramsManager.addResource('headers'),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                          child: Icon(
                            Icons.add,
                            size: 20,
                            color: theme.textTheme.bodyMedium!.color!.withValues(alpha: 0.75),
                          ),
                        ),
                      ),
                    ],
                  ),
                  ...rows,
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class BodyTab extends StatelessWidget {
  final RequestController controller;

  const BodyTab({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    var paramsManager = controller.paramsManager;

    return Builder(
      builder: (context) {
        if (['GET', 'DELETE'].contains(controller.selectedRequest!.method)) {
          return Container(
            padding: const EdgeInsets.only(top: 15),
            child: Opacity(opacity: 0.8, child: Text('This request does not have a body')),
          );
        }

        return TextField(
          minLines: 9,
          maxLines: 9,
          controller: paramsManager?.body,
          style: TextStyle(
            fontSize: 13,
            color: theme.textTheme.bodyMedium!.color!.withValues(alpha: 0.85),
          ),
          decoration: InputDecoration(
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(2),
              borderSide: BorderSide(color: theme.dividerColor, width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(2),
              borderSide: BorderSide(color: theme.colorScheme.primary, width: 1.5),
            ),
          ),
        );
      },
    );
  }
}
