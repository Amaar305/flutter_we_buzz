import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../pages/home/home_controller.dart';
import '../../utils/constants.dart';

class MyAppBar extends StatelessWidget {
  const MyAppBar({
    super.key,
    required this.controller,
  });

  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text(kAppName),
      centerTitle: false,
      actions: [
        IconButton(
          onPressed: () => controller.search(),
          icon:
              Icon(controller.isSearched.isFalse ? Icons.search : Icons.cancel),
        ),
      ],
    );
  }
}
