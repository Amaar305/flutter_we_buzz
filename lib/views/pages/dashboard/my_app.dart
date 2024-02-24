import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../services/firebase_service.dart';
import '../../widgets/home/custom_animated_bottom_bar.dart';
import '../chat/recent_chat_page.dart';
import '../documents/programs_page.dart';
import '../home/home_page.dart';
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
                    NewRecentChat(),
                    ProgramsPage(),
                    ProfilePage(),
                  ],
                ),
                CustomAnimatedBottomBar(controller: controller),
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
}
