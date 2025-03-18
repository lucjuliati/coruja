import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import '../../../controllers/request.dart';

WebViewEnvironment? webViewEnvironment;

class ResponseBody extends StatefulWidget {
  final RequestController controller;

  const ResponseBody({super.key, required this.controller});

  @override
  State<ResponseBody> createState() => _ResponseBodyState();
}

class _ResponseBodyState extends State<ResponseBody> {
  @override
  void initState() {
    super.initState();

    WebViewEnvironment.create(settings: WebViewEnvironmentSettings()).then((value) {
      webViewEnvironment = value;
    });
  }

  Widget renderResponseItem({String? label, dynamic value, Color? color}) {
    return Row(
      spacing: 4,
      children: [
        Opacity(opacity: 0.85, child: Text(label!, style: TextStyle(fontSize: 13))),
        Text(
          value!,
          style: TextStyle(color: color, fontWeight: FontWeight.w500, fontSize: 13),
        ),
      ],
    );
  }

  Color statusColorLogic(int statusCode) {
    if (statusCode >= 200 && statusCode < 300) {
      return const Color.fromARGB(255, 85, 187, 88);
    } else if (statusCode >= 300 && statusCode < 400) {
      return const Color.fromARGB(255, 226, 121, 50);
    } else {
      return const Color.fromARGB(255, 190, 72, 63);
    }
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    return Builder(
      builder: (context) {
        if (widget.controller.loading) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: SizedBox(
                height: 30,
                width: 30,
                child: CircularProgressIndicator(),
              ),
            ),
          );
        }

        if (widget.controller.responseData != null) {
          return Expanded(
            child: Container(
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: theme.dividerColor)),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 12, bottom: 5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (widget.controller.responseData != null)
                          Row(
                            spacing: 12,
                            children: [
                              renderResponseItem(
                                label: 'Status:',
                                value: widget.controller.responseData!.response.statusCode.toString(),
                                color: statusColorLogic(widget.controller.responseData!.response.statusCode),
                              ),
                              renderResponseItem(
                                label: 'Length:',
                                value: '${widget.controller.responseData!.response.contentLength}',
                              ),
                              renderResponseItem(
                                label: 'Time:',
                                value: '${widget.controller.responseData!.elapsedTime}ms',
                              ),
                            ],
                          ),
                        IconButton(onPressed: () {}, icon: Icon(CupertinoIcons.crop)),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Builder(
                      builder: (context) {
                        String initialData = '<html><body><div id="json-container"></div></body></html>';

                        if (!widget.controller.responseData!.isJson) {
                          initialData = widget.controller.responseData!.body!;
                        }

                        return InAppWebView(
                          webViewEnvironment: webViewEnvironment,
                          onLoadStop: (controller, url) async {
                            if (!widget.controller.responseData!.isJson) return;

                            String string = await File('lib/assets/jsonViewer.js').readAsString();

                            var result = await controller.evaluateJavascript(
                              source: 'let jsonData = ${widget.controller.responseData!.body}; $string',
                            );

                            if (result.runtimeType.toString() != 'Null') {
                              print('OK');
                            }
                          },
                          initialSettings: InAppWebViewSettings(allowsBackForwardNavigationGestures: false, javaScriptEnabled: true),
                          initialData: InAppWebViewInitialData(data: initialData),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return Container();
      },
    );
  }
}
