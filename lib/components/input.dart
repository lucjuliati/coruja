import 'package:flutter/material.dart';

import 'label.dart';

class Input extends StatelessWidget {
  final TextEditingController? controller;
  final String? label;

  const Input({super.key, this.label, required this.controller});

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) const Label(text: 'Name'),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: TextField(
            controller: controller,
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
      ],
    );
  }
}
