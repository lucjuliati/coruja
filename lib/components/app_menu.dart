import 'dart:io';

import 'package:flutter/material.dart';

import '../controllers/request.dart';
import '../utils/event_emitter.dart';

EventEmitter emitter = EventEmitter();

class AppMenu extends StatelessWidget {
  final RequestController controller;

  const AppMenu({super.key, required this.controller});

  Text menuFormatter(String label) {
    return Text(
      label,
      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
    );
  }

  MenuItemButton makeButton(
    BuildContext context, {
    required String label,
    required Function() onPressed,
    bool disabled = false,
  }) {
    return MenuItemButton(
      onPressed: disabled ? null : onPressed,
      leadingIcon: SizedBox(width: 120, child: MenuAcceleratorLabel(label)),
      style: MenuItemButton.styleFrom(
        backgroundColor: Theme.of(context).secondaryHeaderColor.withValues(alpha: 0.35),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: theme.dividerColor, width: 1.5),
        ),
        color: theme.cardColor
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: MenuBar(
              style: MenuStyle(
                backgroundColor: WidgetStateProperty.resolveWith((states) {
                  return theme.cardColor;
                }),
              ),
              children: [
                SubmenuButton(
                  menuChildren: [
                    makeButton(
                      context,
                      label: '&New',
                      onPressed: () => emitter.emit('new_resource'),
                    ),
                    makeButton(
                      context,
                      label: '&Save',
                      onPressed: () => emitter.emit('save'),
                      disabled: controller.selectedRequest == null,
                    ),
                    Divider(height: 0, color: Colors.black45),
                    makeButton(
                      context,
                      label: '&Exit',
                      onPressed: () => exit(0),
                    ),
                  ],
                  child: MenuAcceleratorLabel(
                    '&File',
                    builder: (context, label, index) => menuFormatter(label),
                  ),
                ),
                SubmenuButton(
                  menuChildren: [
                    makeButton(
                      context,
                      label: '&About',
                      onPressed: () => showAboutDialog(
                        context: context,
                        applicationName: 'Coruja',
                        applicationVersion: '1.0.0',
                      ),
                    ),
                  ],
                  child: MenuAcceleratorLabel(
                    '&Help',
                    builder: (context, label, index) => menuFormatter(label),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
