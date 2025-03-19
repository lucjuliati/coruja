import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../components/dialog_manager.dart';
import '../../../controllers/request.dart';
import '../../../models/request_data.dart';

class ResponseBody extends StatefulWidget {
  final RequestController controller;

  const ResponseBody({super.key, required this.controller});

  @override
  State<ResponseBody> createState() => _ResponseBodyState();
}

class _ResponseBodyState extends State<ResponseBody> {
  Widget renderResponseItem({String? label, dynamic value, Color? color}) {
    return Row(
      spacing: 4,
      children: [
        Opacity(
          opacity: 0.85,
          child: Text(label!, style: TextStyle(fontSize: 13)),
        ),
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
    ResponseData? response = widget.controller.responseData;

    return Builder(
      builder: (context) {
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
                        if (response != null)
                          Row(
                            spacing: 12,
                            children: [
                              renderResponseItem(
                                label: 'Status:',
                                value: response.response.statusCode.toString(),
                                color: statusColorLogic(response.response.statusCode),
                              ),
                              renderResponseItem(
                                label: 'Time:',
                                value: '${response.elapsedTime}ms',
                              ),
                            ],
                          ),
                        Opacity(
                          opacity: 0.85,
                          child: IconButton(
                            onPressed: () {
                              Clipboard.setData(ClipboardData(text: response!.body!)).then((_) {
                                if (!context.mounted) return;

                                DialogManager(context).showSnackBar(title: 'Copied to clipboard!');
                              });
                            },
                            icon: Icon(CupertinoIcons.crop, size: 20),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (response != null) Expanded(child: response.widget ?? Container()),
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
