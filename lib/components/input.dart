import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'label.dart';

class Input extends StatelessWidget {
  final TextEditingController? controller;
  final Function(String)? onSubmitted;
  final String? label;
  final bool autofocus;
  final int? maxLength;

  const Input({
    super.key,
    this.label,
    this.onSubmitted,
    required this.controller,
    this.maxLength,
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
            maxLength: maxLength,
            maxLengthEnforcement: MaxLengthEnforcement.enforced,
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
  final Function(String)? onChanged;
  final EdgeInsets? padding;
  final bool autofocus;

  const ParamInput({
    super.key,
    this.onSubmitted,
    this.onChanged,
    this.padding = EdgeInsets.zero,
    required this.controller,
    this.autofocus = false,
  });

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    return Padding(
      padding: padding!,
      child: TextField(
        controller: controller,
        autofocus: autofocus,
        onChanged: (value) {
          if (onChanged != null) {
            onChanged!(value);
          }
        },
        style: TextStyle(
          fontSize: 13,
          color: theme.textTheme.bodyMedium!.color!.withValues(alpha: 0.8),
          fontWeight: FontWeight.w300,
        ),
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.only(bottom: 4, right: 6, left: 6),
          constraints: BoxConstraints(maxHeight: 32),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(2),
            borderSide: BorderSide(color: theme.dividerColor, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(2),
            borderSide: BorderSide(color: theme.colorScheme.primary, width: 1.5),
          ),
        ),
      ),
    );
  }
}
