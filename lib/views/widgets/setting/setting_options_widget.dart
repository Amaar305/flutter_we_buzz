import 'package:flutter/material.dart';

class MySettingOption1 extends StatelessWidget {
  const MySettingOption1({
    super.key,
    required this.iconData,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.onTap,
  });

  final IconData iconData;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.only(bottom: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 23,
                  backgroundColor:
                      Theme.of(context).colorScheme.primary.withOpacity(0.9),
                  child: Icon(iconData),
                ),
                const SizedBox(width: 10),
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (trailing != null) trailing!
          ],
        ),
      ),
    );
  }
}

class MySettingOption2 extends StatelessWidget {
  const MySettingOption2({
    super.key,
    required this.iconData,
    required this.trailing,
    required this.title,
    this.onTap,
  });

  final IconData iconData;
  final String title;
  final Widget trailing;
  final void Function()? onTap;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 23,
                  backgroundColor:
                      Theme.of(context).colorScheme.primary.withOpacity(0.9),
                  child: Icon(iconData),
                ),
                const SizedBox(width: 16),
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    overflow: TextOverflow.ellipsis,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            trailing
          ],
        ),
      ),
    );
  }
}
