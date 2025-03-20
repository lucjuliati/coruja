import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppMenu extends StatelessWidget {
  const AppMenu({super.key});

  Text menuFormatter(String label) {
    return Text(
      label,
      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
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
                    MenuItemButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Saved!')));
                      },
                      child: MenuAcceleratorLabel('&New'),
                    ),
                    MenuItemButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Saved!')));
                      },
                      child: const MenuAcceleratorLabel('&Save'),
                    ),
                    MenuItemButton(
                      onPressed: SystemNavigator.pop,
                      child: const MenuAcceleratorLabel('&Exit'),
                    ),
                  ],
                  child: MenuAcceleratorLabel(
                    '&File',
                    builder: (context, label, index) => menuFormatter(label),
                  ),
                ),
                SubmenuButton(
                  menuChildren: [
                    MenuItemButton(
                      onPressed: () {
                        showAboutDialog(
                          context: context,
                          applicationName: 'Coruja',
                          applicationVersion: '1.0.0',
                        );
                      },
                      child: const MenuAcceleratorLabel('&About'),
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
