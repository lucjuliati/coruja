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

  MenuItemButton makeButton(BuildContext context, {required String label, required Function() onPressed}) {
    return MenuItemButton(
      onPressed: onPressed,
      leadingIcon: SizedBox(width: 120, child: MenuAcceleratorLabel(label)),
      style: MenuItemButton.styleFrom(
        backgroundColor: Theme.of(context).secondaryHeaderColor.withValues(alpha: 0.5),
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
                    makeButton(context, label: '&New', onPressed: () {}),
                    makeButton(context, label: '&Save', onPressed: () {}),
                    Divider(height: 0, color: Colors.black45),
                    makeButton(context, label: '&Exit', onPressed: SystemNavigator.pop),
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
