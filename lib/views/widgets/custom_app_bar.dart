import 'package:flutter/material.dart';

// ignore: must_be_immutable
class CustomAppBar extends StatelessWidget {
  CustomAppBar(
    this._barTitle, {
    super.key,
    this.fontSize = 35,
    this.primaryAction,
    this.secondaryAction,
  });

  final String _barTitle;
  final double? fontSize;
  final Widget? primaryAction;
  final Widget? secondaryAction;

  late double _deviceHeight;
  late double _deviceWidth;

  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;
    return _buildUI();
  }

  Widget _buildUI() {
    return SizedBox(
      width: _deviceWidth,
      height: _deviceHeight * 0.10,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: secondaryAction != null && primaryAction == null
            ? MainAxisAlignment.start
            : MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (secondaryAction != null) secondaryAction!,
          _titleBar(),
          if (primaryAction != null) primaryAction!,
        ],
      ),
    );
  }

  Widget _titleBar() {
    return FittedBox(
      child: Text(
        _barTitle,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
