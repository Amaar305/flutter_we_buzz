import 'package:flutter/material.dart';

class MyIconButton extends StatelessWidget {
  const MyIconButton({
    super.key,
    this.backgroundColor,
    this.color,
    this.onPressed,
    required this.icon,
  });
  final IconData icon;
  final Color? backgroundColor;
  final Color? color;
  final void Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: IconButton(
        onPressed: onPressed,
        style: IconButton.styleFrom(
          backgroundColor: backgroundColor,
          padding: const EdgeInsets.all(10),
        ),
        icon: Icon(
          icon,
          color: color,
          size: 30,
        ),
      ),
    );
  }
}
