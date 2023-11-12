import 'package:flutter/material.dart';

class OptionItem extends StatelessWidget {
  final Icon icon;
  final String name;
  final VoidCallback onTap;
  const OptionItem({
    super.key,
    required this.icon,
    required this.name,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return InkWell(
      onTap: () => onTap(),
      child: Padding(
        padding: EdgeInsets.only(
          left: size.width * .05,
          top: size.height * .015,
          bottom: size.height * .015,
        ),
        child: Row(
          children: [
            icon,
            Flexible(
              child: Text(
                '  $name',
                style: const TextStyle(fontSize: 15, letterSpacing: 0.5),
              ),
            )
          ],
        ),
      ),
    );
  }
}
