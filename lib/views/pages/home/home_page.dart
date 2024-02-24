import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hi_tweet/services/firebase_constants.dart';
import 'package:hi_tweet/services/firebase_service.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../registration/login_page.dart';
import '../../widgets/home/explore.dart';
import '../../widgets/home/feeds.dart';
import '../announcement/announcement_page.dart';
import '../notification/notification_screen.dart';
import '../search/search_page.dart';
import 'home_controller.dart';

class HomePage extends GetView<HomeController> {
  const HomePage({super.key});
  static const routeName = '/home-page';

  @override
  Widget build(BuildContext context) {
    final deviceHeight = MediaQuery.of(context).size.height;
    final deviceWidth = MediaQuery.of(context).size.width;
    return _buildUI(deviceWidth, deviceHeight);
  }

  Widget _buildUI(double deviceWidth, double deviceHeight) {
    if (FirebaseAuth.instance.currentUser == null) {
      Get.offAllNamed(MyLoginPage.routeName);
    }
    return Scaffold(
      appBar: _buildAppBar(),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: deviceWidth * 0.03),
        child: PageView(
          scrollDirection: Axis.horizontal,
          children: [
            ExploreBuzz(controller: controller),
            Feeds(controller: controller),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: Text(
        'Webuzz',
        style: GoogleFonts.pacifico(
          textStyle: const TextStyle(
            fontSize: 24.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      actions: [
        // if current user is not null
        if (FirebaseAuth.instance.currentUser != null) ...[
          if (controller.currentUser().isStaff)
            // if current user is a staff, show this icon

            GestureDetector(
              onTap: () {
                Get.toNamed(CampusAnnouncementPage.routeName);
              },
              child: const Icon(
                Icons.add_outlined,
              ),
            ),
          10.width,
        ],

        GestureDetector(
          onTap: () => Get.toNamed(NotificationsScreen.routeName),
          child: Stack(
            alignment: Alignment.topRight,
            children: [
              // IconButton(
              //   icon: const Icon(Icons.notifications),
              //   onPressed: () {
              //     Get.toNamed(NotificationsScreen.routeName);
              //   },
              // ),
              const Icon(Icons.notifications_outlined),
              Positioned(
                // top: 10,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  width: 15,
                  height: 15,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.red,
                  ),
                  child: StreamBuilder(
                    stream: FirebaseService.firebaseFirestore
                        .collection(firebaseNotificationCollection)
                        .where('recipientId',
                            isEqualTo: FirebaseAuth.instance.currentUser!.uid)
                        .where('isRead', isEqualTo: false)
                        .snapshots(),
                    builder: (context, snapshot) {
                      switch (snapshot.connectionState) {
                        case ConnectionState.none:
                        case ConnectionState.waiting:
                          return const FittedBox(
                            child: Text(
                              '0',
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                              ),
                            ),
                          );

                        case ConnectionState.done:
                        case ConnectionState.active:
                          if (!snapshot.hasData || snapshot.hasError) {
                            return const FittedBox(
                              child: Text(
                                '0',
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                ),
                              ),
                            );
                          }
                          final data = snapshot.data!.docs.length;
                          return FittedBox(
                            child: Text(
                              '$data',
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                              ),
                            ),
                          );
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () {
            Get.toNamed(SearcUserhPage.routeName);
          },
          icon: const Icon(
            Icons.search_outlined,
          ),
        ),
      ],
    );
  }
}

Map<String, dynamic> toNamed = {
  'String': 20,
  ...toSecond,
  'b': 60,
};
Map<String, dynamic> toSecond = {
  'c': 20,
};
