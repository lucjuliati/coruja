import 'package:flutter/material.dart';

class ParamCheckbox extends StatelessWidget {
  final bool value;
  final Function(bool) onChanged;

  const ParamCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    Color color = value ? theme.primaryColor.withValues(alpha: 0.9) : Colors.transparent;
    Color? iconColor = value ? Colors.white : Colors.transparent;

    return AnimatedContainer(
      width: 21,
      height: 21,
      duration: const Duration(milliseconds: 300),
      curve: Curves.fastOutSlowIn,
      margin: const EdgeInsets.only(left: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: theme.dividerColor, width: 1.5),
      ),
      child: InkWell(
        onTap: () => onChanged(value),
        child: Icon(Icons.check, color: iconColor, size: 16),
      ),
    );
  }
}
