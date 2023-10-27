
import 'package:flutter/material.dart';

class BasicInfoWidget extends StatelessWidget {
  const BasicInfoWidget({
    super.key,
    required this.iconData,
    required this.title,
    required this.subtitle,
    this.trailing,
  });
  final IconData iconData;
  final String title;
  final String subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return 
    Container(
      padding: const EdgeInsets.only(bottom: 35),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 23,
                backgroundColor:
                    Theme.of(context).colorScheme.primary.withOpacity(0.5),
                child: Icon(iconData),
              ),
              const SizedBox(width: 10),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(color: Colors.grey.shade400, fontSize: 17),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ],
              ),
            ],
          ),
          if (trailing != null) trailing!
        ],
      ),
    );
  }
}
