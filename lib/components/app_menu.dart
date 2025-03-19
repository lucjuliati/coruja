import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppMenu extends StatelessWidget {
  const AppMenu({super.key});

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
                  menuStyle: MenuStyle(
                    visualDensity: VisualDensity(horizontal: 0.2, vertical: 0)
                  ),
                  menuChildren: [
                    MenuItemButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Saved!')));
                      },
                      child: const MenuAcceleratorLabel('&New'),
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
                  child: const MenuAcceleratorLabel('&File'),
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
                  child: const MenuAcceleratorLabel('&Help'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
