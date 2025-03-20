import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../components/dialog_manager.dart';
import '../../components/extra_tabs.dart';
import '../../controllers/request.dart';
import 'components/response_body.dart';

class RequestInterface extends StatefulWidget {
  final RequestController controller;

  const RequestInterface({super.key, required this.controller});

  @override
  State<RequestInterface> createState() => _RequestInterfaceState();
}

WebViewEnvironment? webViewEnvironment;

class _RequestInterfaceState extends State<RequestInterface> {
  late int id;
  var name = TextEditingController();
  var url = TextEditingController();
  FocusNode urlFocus = FocusNode();
  FocusNode keyboardFocus = FocusNode();
  MethodLabel? selectedMethod = MethodLabel.get;
  bool hasChanged = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(requestListener);

    var method = MethodLabel.values.firstWhere(
      (element) => element.label == widget.controller.selectedRequest?.method,
      orElse: () {
        return MethodLabel.get;
      },
    );

    setState(() {
      id = widget.controller.selectedRequest?.id ?? 0;
      selectedMethod = method;
    });

    name.text = widget.controller.selectedRequest?.name ?? '';
    url.text = widget.controller.selectedRequest?.url ?? '';

    keyboardFocus.requestFocus();
  }

  void requestListener() {
    var selected = widget.controller.selectedRequest;

    if (selected != null && id != selected.id) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (name.text != selected.name) {
          name.text = selected.name;
        }

        if (url.text != selected.url) {
          url.text = selected.url ?? '';
        }
      });

      var method = MethodLabel.values.firstWhere(
        (element) => element.label == widget.controller.selectedRequest?.method!.toUpperCase(),
        orElse: () => MethodLabel.get,
      );

      setState(() {
        selectedMethod = method;
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    name.dispose();
    url.dispose();
    widget.controller.removeListener(requestListener);
  }

  void _handleKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent) {
      bool isControlPressed = event.logicalKey == LogicalKeyboardKey.controlLeft ||
          event.logicalKey == LogicalKeyboardKey.controlRight ||
          HardwareKeyboard.instance.logicalKeysPressed.contains(LogicalKeyboardKey.controlLeft) ||
          HardwareKeyboard.instance.logicalKeysPressed.contains(LogicalKeyboardKey.controlRight);

      if (isControlPressed && event.logicalKey == LogicalKeyboardKey.keyS) {
        save();
      }
    }
  }

  void save() {
    widget.controller.saveRequest(
      name: name.text,
      url: url.text,
      method: selectedMethod!.label,
    );
  }

  void send() {
    if (widget.controller.loading) return;

    save();

    final RegExp urlRegex = RegExp(
      r'^(https?:\/\/)'
      r'((localhost|\d{1,3}(\.\d{1,3}){3}|[a-zA-Z0-9.-]+)'
      r'(:\d{1,5})?)'
      r'(\/[^\s]*)?$',
      caseSensitive: false,
      multiLine: false,
    );

    if (!urlRegex.hasMatch(url.text)) {
      DialogManager(context).showSnackBar(title: 'Invalid URL!');
      return;
    } else {
      widget.controller.send(url: url.text, method: selectedMethod!.label);
    }
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    if (widget.controller.selectedRequest == null) {
      return Container();
    }

    return Expanded(
      child: KeyboardListener(
        focusNode: keyboardFocus,
        onKeyEvent: _handleKeyEvent,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Container(
            width: MediaQuery.of(context).size.width,
            margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            decoration: BoxDecoration(color: theme.cardColor, borderRadius: BorderRadius.circular(4)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 8,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 380,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: MediaQuery.of(context).size.width,
                                  child: TextField(
                                    controller: name,
                                    cursorRadius: Radius.circular(12),
                                    style: TextStyle(fontSize: 13),
                                    decoration: InputDecoration(
                                      contentPadding: const EdgeInsets.only(bottom: 4),
                                      constraints: BoxConstraints(maxHeight: 36),
                                      enabledBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(color: theme.dividerColor, width: 1.5),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          TextButton(
                            onPressed: save,
                            style: FilledButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                            ),
                            child: Opacity(
                              opacity: 0.75,
                              child: Row(
                                spacing: 7,
                                children: [
                                  FaIcon(FontAwesomeIcons.floppyDisk, size: 18, color: Colors.white),
                                  Text('Save', style: TextStyle(color: Colors.white)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        spacing: 8,
                        children: [
                          SizedBox(
                            width: 115,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: Material(
                                color: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  side: BorderSide(color: theme.dividerColor, width: 1.5),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: PopupMenuButton<MethodLabel>(
                                  tooltip: null,
                                  initialValue: MethodLabel.get,
                                  color: theme.inputDecorationTheme.fillColor,
                                  padding: const EdgeInsets.symmetric(vertical: 0),
                                  shape: RoundedRectangleBorder(side: BorderSide(color: theme.dividerColor)),
                                  itemBuilder: (BuildContext context) => MethodLabel.entries,
                                  onSelected: (MethodLabel item) {
                                    widget.controller.saveRequest(method: item.label);
                                    setState(() {
                                      selectedMethod = item;
                                    });
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 6, bottom: 6, left: 10, right: 14),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Opacity(opacity: 0.7, child: Icon(Icons.arrow_drop_down)),
                                        Text(
                                          selectedMethod?.label ?? '---',
                                          textAlign: TextAlign.right,
                                          style: TextStyle(
                                            color: selectedMethod?.color,
                                            fontWeight: FontWeight.w500,
                                            fontSize: 14,
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
                              decoration: InputDecoration(
                                alignLabelWithHint: false,
                                border: InputBorder.none,
                                constraints: BoxConstraints(maxHeight: 36),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: theme.dividerColor, width: 1.5),
                                ),
                                contentPadding: const EdgeInsets.only(left: 8, right: 8),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: theme.colorScheme.primary,
                                    width: 1.5,
                                  ),
                                ),
                                hintText: 'https://example.com',
                                hintStyle: TextStyle(
                                  color: theme.textTheme.bodyMedium!.color!.withValues(alpha: 0.45),
                                  fontSize: 13,
                                ),
                              ),
                              style: TextStyle(
                                fontSize: 13,
                                color: theme.textTheme.bodyMedium!.color!.withValues(alpha: 0.85),
                              ),
                              onSubmitted: (String value) {
                                send();
                                url.text = value;
                                urlFocus.requestFocus();
                              },
                            ),
                          ),
                          TextButton(
                            onPressed: send,
                            style: TextButton.styleFrom(
                              backgroundColor: theme.primaryColor,
                              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            child: Row(
                              spacing: 6,
                              children: [
                                Text('Send', style: TextStyle(color: Colors.white)),
                                Icon(
                                  CupertinoIcons.arrow_right,
                                  color: Colors.white,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                ExtraTabs(controller: widget.controller),
                ResponseBody(controller: widget.controller),
              ],
            ),
          ),
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
  put('PUT', Color(0xFFA267CB)),
  delete('DELETE', Color(0xFFE45656));

  const MethodLabel(this.label, this.color);
  final String label;
  final Color color;

  static final List<MethodEntry> entries = UnmodifiableListView<MethodEntry>(
    values.map<MethodEntry>(
      (MethodLabel color) => MethodEntry(
        value: color,
        height: 35,
        padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
        child: Text(
          color.label,
          style: TextStyle(color: color.color, fontWeight: FontWeight.bold),
        ),
      ),
    ),
  );
}
