import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomBackButton extends StatelessWidget {
  const CustomBackButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.back(),
      child: const CustomeThingForWidget(
        child: Icon(
          Icons.arrow_back_ios,
          size: 20,
        ),
      ),
    );
  }
}

class CustomeThingForWidget extends StatelessWidget {
  const CustomeThingForWidget({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: child,
    );
  }
}
