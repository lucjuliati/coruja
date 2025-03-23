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
                    padding: const EdgeInsets.only(bottom: 60),
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
          color: theme.textTheme.bodyMedium!.color!.withValues(alpha: 0.75),
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
                IconButton(
                  onPressed: () => paramsManager.deleteResource('params', index),
                  icon: FaIcon(FontAwesomeIcons.trash, size: 16),
                ),
              ],
            ),
          );
        }

        return Container(
          constraints: BoxConstraints(minHeight: 140),
          child: Table(
            border: TableBorder.all(color: Colors.transparent),
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
                  Text('Key', style: headerStyle),
                  Text('Value', style: headerStyle),
                  IconButton(
                    onPressed: () => paramsManager.addResource('params'),
                    icon: Icon(Icons.add),
                  ),
                ],
              ),
              ...rows,
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
          color: theme.textTheme.bodyMedium!.color!.withValues(alpha: 0.75),
        );

        for (final (index, header) in paramsManager!.headers.indexed) {
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
                IconButton(
                  onPressed: () => paramsManager.deleteResource('headers', index),
                  icon: FaIcon(FontAwesomeIcons.trash, size: 16),
                ),
              ],
            ),
          );
        }

        return Container(
          constraints: BoxConstraints(minHeight: 140),
          child: Table(
            border: TableBorder.all(color: Colors.transparent),
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
                  Text('Key', style: headerStyle),
                  Text('Value', style: headerStyle),
                  IconButton(
                    onPressed: () => paramsManager.addResource('headers'),
                    icon: Icon(Icons.add),
                  ),
                ],
              ),
              ...rows,
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
