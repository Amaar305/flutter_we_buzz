import 'package:flutter/material.dart';

class CustomListTile extends StatelessWidget {
  const CustomListTile({
    super.key,
    this.leading,
    this.title,
    this.trailing,
    this.onTap,
  });
  final Widget? leading;
  final Widget? title;
  final Widget? trailing;

  final void Function()? onTap;
  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: InkWell(
        onTap: onTap,
        child: ListTile(
          leading: leading,
          title: title,
          trailing: trailing,
        ),
      ),
    );
  }
}
