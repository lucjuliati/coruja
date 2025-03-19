import 'package:flutter/material.dart';

import 'label.dart';

class Input extends StatelessWidget {
  final TextEditingController? controller;
  final Function(String)? onSubmitted;
  final String? label;
  final bool autofocus;

  const Input({
    super.key,
    this.label,
    this.onSubmitted,
    required this.controller,
    this.autofocus = false,
  });

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
            autofocus: autofocus,
            onSubmitted: (value) {
              onSubmitted!(value);
            },
            style: TextStyle(fontSize: 14),
            decoration: InputDecoration(
              filled: true,
              fillColor: theme.inputDecorationTheme.fillColor,
              border: InputBorder.none,
              focusedBorder: InputBorder.none,
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.transparent),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class ParamInput extends StatelessWidget {
  final TextEditingController? controller;
  final Function(String)? onSubmitted;
  final bool autofocus;

  const ParamInput({
    super.key,
    this.onSubmitted,
    required this.controller,
    this.autofocus = false,
  });

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    return TextField(
      controller: controller,
      autofocus: autofocus,
      onSubmitted: (value) {
        onSubmitted!(value);
      },
      style: TextStyle(
        fontSize: 13,
        color: theme.textTheme.bodyMedium!.color!.withValues(alpha: 0.8),
        fontWeight: FontWeight.w300,
      ),
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.only(bottom: 4, right: 6, left: 6),
        constraints: BoxConstraints(maxHeight: 36),
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
