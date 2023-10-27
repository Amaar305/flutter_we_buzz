import 'package:flutter/material.dart';

class RecentChats extends StatelessWidget {
  const RecentChats({
    super.key,
    required this.username,
    required this.subtitle,
    required this.date,
    required this.isOnline,
  });

  final String username;
  final String subtitle;
  final String date;
  final bool isOnline;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Stack(
        clipBehavior: Clip.none,
        children: [
          const CircleAvatar(
            radius: 23,
            backgroundImage: AssetImage('assets/images/tay.jpg'),
          ),
          if (isOnline)
            Positioned(
              top: 35,
              left: 30,
              right: 0,
              child: Icon(
                Icons.circle,
                size: 12,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
        ],
      ),
      title: Text(
        username,
        style: Theme.of(context).textTheme.displayMedium!.copyWith(
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
      ),
      subtitle: Text(
        subtitle,
        maxLines: 1,
        style: Theme.of(context).textTheme.bodySmall,
      ),
      trailing: Text(
        date,
        style: Theme.of(context).textTheme.bodyMedium,
      ),
      horizontalTitleGap: 10,
    );
  }
}
