import 'package:flutter/material.dart';

class ShimmerSkeleton extends StatelessWidget {
  const ShimmerSkeleton({super.key, this.height, this.width, this.child});
  final double? height, width;
  final Widget? child;
  @override
  Widget build(BuildContext context) {
    return Container(
      height: child != null ? null : height,
      width: width,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Theme.of(context).colorScheme.primary.withOpacity(0.15),
      ),
      child: child,
    );
  }
}
