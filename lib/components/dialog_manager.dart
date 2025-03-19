import 'package:flutter/material.dart';

class DialogManager {
  BuildContext context;

  DialogManager(this.context);

  void showSnackBar({required String title}) {
    ScaffoldMessenger.of(context).clearSnackBars();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        content: Align(
          alignment: Alignment.bottomRight,
          child: Container(
            width: 350,
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            decoration: BoxDecoration(
              color: Theme.of(context).secondaryHeaderColor.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              spacing: 8,
              children: [
                IconButton(onPressed: Navigator.of(context).pop, icon: Icon(Icons.close)),
                Text(
                  title,
                  style: TextStyle(color: Theme.of(context).textTheme.bodySmall!.color),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
