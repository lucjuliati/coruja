import 'package:flutter/material.dart';

import '../../controllers/request.dart';
import 'request_interface.dart';
import 'sidemenu.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late RequestController controller;

  @override
  void initState() {
    super.initState();
    controller = RequestController(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListenableBuilder(
        listenable: controller,
        builder: (context, child) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SideMenu(controller: controller),
              RequestInterface(controller: controller),
            ],
          );
        },
      ),
    );
  }
}
