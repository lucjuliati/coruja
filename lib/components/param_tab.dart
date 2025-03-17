import 'package:flutter/material.dart';

import '../controllers/request.dart';

class ParamTabs extends StatefulWidget {
  final RequestController controller;

  const ParamTabs({super.key, required this.controller});

  @override
  State<ParamTabs> createState() => _ParamTabsState();
}

class _ParamTabsState extends State<ParamTabs> {
  final List<Widget> children = [
    ParamTab(),
    HeadersTab(),
    BodyTab(),
  ];

  @override
  Widget build(BuildContext context) {
    List<Widget> items = [];
    var labels = [
      {'label': 'Params'},
      {'label': 'Headers'},
      {'label': 'Body'},
    ];

    for (final (index, item) in labels.indexed) {
      items.add(
        Material(
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
      );
    }

    return Column(
      children: [
        Row(children: items),
        children[widget.controller.tabIndex],
      ],
    );
  }
}

class ParamTab extends StatelessWidget {
  const ParamTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

class HeadersTab extends StatelessWidget {
  const HeadersTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

class BodyTab extends StatelessWidget {
  const BodyTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
