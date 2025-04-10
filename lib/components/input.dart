import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'label.dart';

class Input extends StatelessWidget {
  final TextEditingController? controller;
  final Function(String)? onSubmitted;
  final Function(String)? onChanged;
  final String? label;
  final bool autofocus;
  final int? maxLength;

  const Input({
    super.key,
    this.label,
    this.onSubmitted,
    this.onChanged,
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
            onChanged: (value) {
              if (onChanged != null) onChanged!(value);
            },
            style: TextStyle(fontSize: 14),
            decoration: InputDecoration(
              filled: true,
              fillColor: theme.inputDecorationTheme.fillColor,
              border: InputBorder.none,
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.transparent),
              ),
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
      padding: EdgeInsets.zero,
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
          fillColor: Colors.transparent,
          contentPadding: const EdgeInsets.only(bottom: 4, right: 6, left: 6),
          constraints: BoxConstraints(maxHeight: 30),
          focusColor: Colors.red,
          filled: true,
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.transparent, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.transparent, width: 1.5),
          ),
        ),
      ),
    );
  }
}
