import '../controllers/params.dart';
import 'package:flutter/material.dart';

import '../controllers/request.dart';
import 'input.dart';

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
        HeadersTab(),
        BodyTab(),
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

    return Padding(
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

          for (final param in controller.params) {
            rows.add(
              TableRow(
                children: <Widget>[
                  Container(
                    width: 32,
                    margin: const EdgeInsets.only(right: 7),
                    child: Checkbox(value: param.enabled, onChanged: (value) {}),
                  ),
                  Container(
                    padding: const EdgeInsets.only(right: 8),
                    child: ParamInput(controller: param.key),
                  ),
                  ParamInput(controller: param.value),
                  IconButton(onPressed: () {}, icon: Icon(Icons.delete)),
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
                    IconButton(onPressed: controller.addNewParam, icon: Icon(Icons.add)),
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
  const HeadersTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text('Headers');
  }
}

class BodyTab extends StatelessWidget {
  const BodyTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text('Body');
  }
}
