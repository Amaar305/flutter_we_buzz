import 'package:flutter/material.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});
  static const routeName = '/notification';
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Notifications'),
      ),
    );
  }
}
