import 'package:flutter/material.dart';

import '../../utils/constants.dart';

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.text,
    required this.press,
    this.color = kPrimary,
    required this.padding,
  });
  final String text;
  final VoidCallback press;
  final Color color;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(40),
      ),
      onPressed: press,
      padding: padding,
      color: color,
      minWidth: double.infinity,
      child: Text(
        text,
        style: const TextStyle(color: Colors.white),
      ),
    );
  }
}
