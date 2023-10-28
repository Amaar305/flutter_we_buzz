import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../chat/recent_chat_page.dart';
import '../home/home_page.dart';
import '../notification/notifications_page.dart';
import '../profile/profile_page.dart';
import 'dashboard_controller.dart';

class MyBottomNavBar extends StatefulWidget {
  const MyBottomNavBar({super.key});
  static const routeName = '/';

  @override
  State<MyBottomNavBar> createState() => _MyBottomNavBarState();
}

class _MyBottomNavBarState extends State<MyBottomNavBar> {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<AppController>(
      builder: (controller) {
        return Scaffold(
          body: SafeArea(
            child: IndexedStack(
              index: controller.tabIndex,
              children: const [
                HomePage(),
                RecentChatPage(),
                NotificationsPage(),
                ProfilePage(),
              ],
            ),
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: controller.tabIndex,
            showUnselectedLabels: false,
            showSelectedLabels: true,
            onTap: (index) => controller.changeTabIndex(index),
            type: BottomNavigationBarType.fixed,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Home',
                tooltip: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.chat),
                label: 'Chat',
                tooltip: 'Chat',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.notifications),
                label: 'Notification',
                tooltip: 'Notification',
              ),
              BottomNavigationBarItem(
                icon: CircleAvatar(
                  radius: 15,
                  backgroundImage: AssetImage('assets/images/tay.jpg'),
                ),
                label: '',
                tooltip: 'Profile',
              ),
            ],
          ),
        );
      },
    );
  }
}
