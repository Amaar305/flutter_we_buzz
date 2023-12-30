import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../widgets/home/explore.dart';
import '../../widgets/home/feeds.dart';
import '../dashboard/my_app_controller.dart';
import '../search/search_page.dart';
import '../users/users._list_page.dart';
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
        if (FirebaseAuth.instance.currentUser != null)
          // if current user is not null

          if (AppController.instance.weBuzzUsers
              .firstWhere((user) =>
                  user.userId == FirebaseAuth.instance.currentUser!.uid)
              .isStaff)
            // if current user is a staff, show this icon
            IconButton(
              onPressed: () {
                Get.toNamed(UsersPageList.routeName);
              },
              icon: const Icon(
                Icons.person,
              ),
            ),
        IconButton(
          icon: const Icon(Icons.notifications),
          onPressed: () {
            // Add your notification button logic here
          },
        ),
        IconButton(
          onPressed: () {
            Get.toNamed(SearcUserhPage.routeName);
          },
          icon: const Icon(
            Icons.search,
          ),
        ),
      ],
    );
  }
}
