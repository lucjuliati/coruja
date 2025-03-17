import 'package:flutter/material.dart';

import 'label.dart';

class Select<T> extends StatelessWidget {
  final String? label;
  final List<DropdownMenuItem<T>> items;
  final Function(T?) onChanged;
  final T? value;

  const Select({
    super.key,
    this.label,
    required this.onChanged,
    required this.items,
    this.value,
  });

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) Label(text: label!),
        SizedBox(
          width: MediaQuery.of(context).size.width,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Material(
              color: theme.inputDecorationTheme.fillColor,
              child: DropdownButton(
                onChanged: (T? value) => onChanged(value),
                padding: const EdgeInsets.symmetric(horizontal: 8),
                underline: Container(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: theme.dividerColor),
                    ),
                  ),
                ),
                style: TextStyle(fontSize: 14),
                value: value,
                icon: const Icon(Icons.arrow_drop_down),
                isExpanded: true,
                items: items,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
