import 'package:flutter/material.dart';

class CustomSettingTitle extends StatelessWidget {
  const CustomSettingTitle({
    super.key,
    required this.title,
    this.fontSize = 20.0,
  });

  final String title;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(fontSize: fontSize),
    );
  }
}
