import 'dart:collection';

import 'package:flutter/material.dart';

import '../../controllers/request.dart';

class RequestInterface extends StatefulWidget {
  final RequestController controller;

  const RequestInterface({super.key, required this.controller});

  @override
  State<RequestInterface> createState() => _RequestInterfaceState();
}

class _RequestInterfaceState extends State<RequestInterface> {
  var name = TextEditingController();
  var url = TextEditingController();
  var urlFocus = FocusNode();
  MethodLabel? selectedMethod = MethodLabel.get;

  @override
  void dispose() {
    super.dispose();
    name.dispose();
    url.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    if (widget.controller.selectedRequest == null) {
      return Container();
    }

    return Expanded(
      child: Container(
        width: MediaQuery.of(context).size.width,
        color: theme.scaffoldBackgroundColor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 16,
                children: [
                  SizedBox(
                    width: 320,
                    child: TextField(
                      controller: name,
                      cursorRadius: Radius.circular(12),
                      decoration: InputDecoration(
                        label: Opacity(opacity: 0.7, child: Text('Name')),
                        alignLabelWithHint: false,
                        constraints: BoxConstraints(maxHeight: 45),
                        // border: OutlineInputBorder(borderSide: BorderSide(color: Colors.transparent)),
                      ),
                    ),
                  ),
                  Row(
                    spacing: 8,
                    children: [
                      SizedBox(
                        width: 115,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: Material(
                            shape: RoundedRectangleBorder(
                              side: BorderSide(color: theme.dividerColor, width: 2),
                              borderRadius: BorderRadius.circular(4),
                            ),

                            child: PopupMenuButton<MethodLabel>(
                              initialValue: MethodLabel.get,
                              itemBuilder: (BuildContext context) => MethodLabel.entries,
                              onSelected: (MethodLabel item) {
                                setState(() {
                                  selectedMethod = item;
                                });
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(top: 9.5, bottom: 9.5, left: 10, right: 14),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Opacity(opacity: 0.7, child: Icon(Icons.arrow_drop_down)),
                                    Text(
                                      selectedMethod?.label ?? "---",
                                      textAlign: TextAlign.right,
                                      style: TextStyle(
                                        color: selectedMethod?.color,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: TextField(
                          controller: url,
                          focusNode: urlFocus,
                          cursorRadius: Radius.circular(12),
                          decoration: InputDecoration(
                            alignLabelWithHint: false,
                            filled: true,
                            fillColor: Colors.transparent,
                            border: InputBorder.none,
                            constraints: BoxConstraints(maxHeight: 42),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: theme.dividerColor, width: 2),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: theme.dividerColor, width: 2),
                            ),
                            hintText: "https://example.com",
                            hintStyle: TextStyle(
                              color: theme.textTheme.bodyMedium!.color!.withValues(alpha: 0.45),
                              fontSize: 15,
                            ),
                          ),
                          style: TextStyle(fontSize: 15),
                          onSubmitted: (String value) {
                            widget.controller.send(url: url.text, method: selectedMethod!.label);
                            urlFocus.requestFocus();
                          },
                        ),
                      ),
                      TextButton(
                        onPressed: () => widget.controller.send(url: url.text, method: selectedMethod!.label),
                        style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 18)),
                        child: Row(spacing: 6, children: [Text("Send"), Icon(Icons.subdirectory_arrow_right_rounded)]),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 120),
            Expanded(
              child: Container(
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: theme.secondaryHeaderColor.withValues(alpha: 0.125),
                  border: Border(top: BorderSide(color: theme.dividerColor)),
                ),
                child: Column(children: [Text("HTTP response")]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

typedef MethodEntry = PopupMenuItem<MethodLabel>;

enum MethodLabel {
  get('GET', Color(0xFF59B156)),
  post('POST', Colors.orange),
  patch('PATCH', Colors.blue),
  delete('DELETE', Color(0xFFE45656));

  const MethodLabel(this.label, this.color);
  final String label;
  final Color color;

  static final List<MethodEntry> entries = UnmodifiableListView<MethodEntry>(
    values.map<MethodEntry>(
      (MethodLabel color) => MethodEntry(
        value: color,
        child: Text(color.label, style: TextStyle(color: color.color, fontWeight: FontWeight.bold)),
      ),
    ),
  );
}
