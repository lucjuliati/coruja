import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_json_view/flutter_json_view.dart';

import '../../components/label.dart';
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
  FocusNode urlFocus = FocusNode();
  FocusNode keyboardFocus = FocusNode();
  MethodLabel? selectedMethod = MethodLabel.get;
  bool hasChanged = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(requestListener);
    keyboardFocus.requestFocus();
  }

  void requestListener() {
    name.text = widget.controller.selectedRequest?.name ?? '';
    url.text = widget.controller.selectedRequest?.url ?? '';

    var method = MethodLabel.values.firstWhere(
      (element) => element.label == widget.controller.selectedRequest?.method,
      orElse: () {
        return MethodLabel.get;
      },
    );

    setState(() {
      selectedMethod = method;
    });
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
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: MediaQuery.of(context).size.width,
            margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 15),
            decoration: BoxDecoration(color: theme.cardColor, borderRadius: BorderRadius.circular(12)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 16,
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
                                Label(text: 'Name'),
                                Container(
                                  width: MediaQuery.of(context).size.width,
                                  child: TextField(
                                    controller: name,
                                    cursorRadius: Radius.circular(12),
                                    decoration: InputDecoration(
                                      alignLabelWithHint: false,
                                      constraints: BoxConstraints(maxHeight: 45),
                                      // contentPadding: const EdgeInsets.symmetric(vertical: 30)
                                      // border: OutlineInputBorder(borderSide: BorderSide(color: Colors.transparent)),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                          FilledButton(
                            onPressed: save,
                            style: FilledButton.styleFrom(
                              backgroundColor: const Color(0xFF2760C2),
                              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 32),
                            ),
                            child: Text(
                              'Save',
                              style: TextStyle(color: Colors.white),
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
                                          selectedMethod?.label ?? '---',
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
                                hintText: 'https://example.com',
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
                            child: Row(spacing: 6, children: [Text('Send'), Icon(Icons.subdirectory_arrow_right_rounded)]),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 120),
                if (widget.controller.response != null)
                  Expanded(
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 22, 22, 26),
                        border: Border(top: BorderSide(color: theme.dividerColor)),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(12),
                          bottomRight: Radius.circular(12),
                        ),
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            SizedBox(
                              width: MediaQuery.of(context).size.width,
                              child: Material(
                                child: InkWell(
                                  onTap: widget.controller.clearResponse,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 4),
                                    child: Icon(Icons.arrow_drop_down),
                                  ),
                                ),
                              ),
                            ),
                            JsonView.string(
                              widget.controller.response,
                              theme: JsonViewTheme(
                                defaultTextStyle: TextStyle(fontSize: 14),
                                backgroundColor: Colors.transparent,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
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
