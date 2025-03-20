import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../controllers/params.dart';
import '../controllers/request.dart';
import 'input.dart';
import 'param_checkbox.dart';

class ExtraTabs extends StatefulWidget {
  final RequestController controller;

  const ExtraTabs({super.key, required this.controller});

  @override
  State<ExtraTabs> createState() => _ExtraTabsState();
}

class _ExtraTabsState extends State<ExtraTabs> {
  var paramController = ParamsController();

  List<Widget> children = [];

  @override
  void initState() {
    super.initState();
    setState(() {
      children = [
        ParamTab(controller: paramController),
        HeadersTab(controller: paramController),
        BodyTab(controller: paramController),
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    List<Widget> items = [];
    var labels = [
      {'label': 'Params'},
      {'label': 'Headers'},
      {'label': 'Body'},
    ];

    for (final (index, item) in labels.indexed) {
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
                  item['label']!,
                  style: TextStyle(fontSize: 13),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(left: 12, right: 12, bottom: 16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Row(children: items),
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: children[widget.controller.tabIndex],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ParamTab extends StatelessWidget {
  final ParamsController controller;

  const ParamTab({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    return ListenableBuilder(
      listenable: controller,
      builder: (context, child) => Builder(
        builder: (context) {
          List<TableRow> rows = [];
          TextStyle headerStyle = TextStyle(
            fontSize: 13,
            color: theme.textTheme.bodyMedium!.color!.withValues(alpha: 0.75),
          );

          for (final (index, param) in controller.params.indexed) {
            rows.add(
              TableRow(
                children: [
                  Container(
                    margin: const EdgeInsets.only(right: 7),
                    child: ParamCheckbox(
                      value: param.enabled,
                      onChanged: (value) => controller.toggleVisibility('params', index),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.only(right: 8),
                    child: ParamInput(controller: param.key),
                  ),
                  ParamInput(controller: param.value),
                  IconButton(
                    onPressed: () => controller.deleteResource('params', index),
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
                      onPressed: () => controller.addResource('params'),
                      icon: Icon(Icons.add),
                    ),
                  ],
                ),
                ...rows,
              ],
            ),
          );
        },
      ),
    );
  }
}

class HeadersTab extends StatelessWidget {
  final ParamsController controller;

  const HeadersTab({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    return ListenableBuilder(
      listenable: controller,
      builder: (context, child) => Builder(
        builder: (context) {
          List<TableRow> rows = [];
          TextStyle headerStyle = TextStyle(
            fontSize: 13,
            color: theme.textTheme.bodyMedium!.color!.withValues(alpha: 0.75),
          );

          for (final (index, header) in controller.headers.indexed) {
            rows.add(
              TableRow(
                children: [
                  Container(
                    margin: const EdgeInsets.only(right: 7),
                    child: ParamCheckbox(
                      value: header.enabled,
                      onChanged: (value) => controller.toggleVisibility('headers', index),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.only(right: 8),
                    child: ParamInput(controller: header.key),
                  ),
                  ParamInput(controller: header.value),
                  IconButton(
                    onPressed: () => controller.deleteResource('headers', index),
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
                      onPressed: () => controller.addResource('headers'),
                      icon: Icon(Icons.add),
                    ),
                  ],
                ),
                ...rows,
              ],
            ),
          );
        },
      ),
    );
  }
}

class BodyTab extends StatelessWidget {
  final ParamsController controller;

  const BodyTab({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    return TextField(
      minLines: 9,
      maxLines: 9,
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
  }
}
