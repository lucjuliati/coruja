import 'package:flutter/material.dart';

class CancelButton extends StatelessWidget {
  final Function onPressed;

  const CancelButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () => onPressed(),
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
      ),
      child: Opacity(
        opacity: 0.75,
        child: Text('Cancel', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}
