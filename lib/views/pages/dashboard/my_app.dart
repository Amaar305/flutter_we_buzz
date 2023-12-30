import 'package:fluentui_icons/fluentui_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../services/firebase_service.dart';
import '../chat/recent_chat_page.dart';
import '../create/create_page.dart';
import '../home/home_page.dart';
import '../notification/notifications_page.dart';
import '../profile/profile_page.dart';
import 'my_app_controller.dart';

class MyBottomNavBar extends StatefulWidget {
  const MyBottomNavBar({super.key});
  static const routeName = '/';

  @override
  State<MyBottomNavBar> createState() => _MyBottomNavBarState();
}

class _MyBottomNavBarState extends State<MyBottomNavBar> {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return onWillPop(context);
      },
      child: GetBuilder<AppController>(
        builder: (controller) {
          return Scaffold(
            body: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                IndexedStack(
                  index: controller.tabIndex,
                  children: const [
                    HomePage(),
                    RecentChatPage(),
                    NotificationsPage(),
                    ProfilePage(),
                  ],
                ),
                _bottomNav(context, controller),
              ],
            ),
          );
        },
      ),
    );
  }

  DateTime currentBackPressTime = DateTime.now();
  Future<bool> onWillPop(BuildContext context) async {
    DateTime now = DateTime.now();
    if (now.difference(currentBackPressTime) > const Duration(seconds: 2)) {
      currentBackPressTime = now;
      toast('Press again to exit');
      return false;
    } else {
      SystemNavigator.pop(animated: true);
      await FirebaseService.updateActiveStatus(false);
      return true;
    }
  }

  Widget newPostIndecator(BuildContext context) {
    return Positioned(
      bottom: MediaQuery.of(context).size.height * .16,
      child: Container(
        height: MediaQuery.of(context).size.height * .057,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(20),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {},
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.arrow_upward),
              SizedBox(width: 5),
              Text(
                'New Buzz',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _bottomNav(BuildContext context, AppController controller) {
    return Positioned(
      bottom: 20,
      child: SizedBox(
        width: MediaQuery.of(context).size.width * .85,
        child: Card(
          color: Theme.of(context).bottomNavigationBarTheme.backgroundColor,

          elevation: 5.0,
          clipBehavior: Clip.antiAlias,
          // margin: const EdgeInsets.symmetric(horizontal: 70),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),

          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 10,
            ),
            child: Row(
              mainAxisSize: MainAxisSize
                  .min, // This will take space as minimum as posible(to center)
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                GetBuilder<AppController>(
                  builder: (_) {
                    return IconButton(
                      icon: Icon(
                        controller.tabIndex == 0
                            ? FluentSystemIcons.ic_fluent_home_filled
                            : FluentSystemIcons.ic_fluent_home_regular,
                        size: 25,
                      ),
                      onPressed: () => controller.changeTabIndex(0),
                    );
                  },
                ),
                GetBuilder<AppController>(
                  builder: (_) {
                    return IconButton(
                      icon: Icon(
                        controller.tabIndex == 1
                            ? FluentSystemIcons.ic_fluent_chat_filled
                            : FluentSystemIcons.ic_fluent_chat_regular,
                        size: 25,
                      ),
                      onPressed: () => controller.changeTabIndex(1),
                    );
                  },
                ),
                GetBuilder<AppController>(
                  builder: (_) {
                    return IconButton(
                      icon: Icon(
                        controller.tabIndex == 2
                            ? Icons.notifications_active
                            : Icons.notifications_outlined,
                        size: 25,
                      ),
                      onPressed: () => controller.changeTabIndex(2),
                    );
                  },
                ),
                GetBuilder<AppController>(
                  builder: (_) {
                    return IconButton(
                      icon: Icon(
                        controller.tabIndex == 3
                            ? Icons.person
                            : Icons.person_outline,
                        size: 25,
                      ),
                      onPressed: () => controller.changeTabIndex(3),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(
                    Icons.add,
                    size: 30,
                  ),
                  onPressed: () => Get.toNamed(CreateBuzzPage.routeName),
                  style: IconButton.styleFrom(
                    padding: const EdgeInsets.all(15),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
