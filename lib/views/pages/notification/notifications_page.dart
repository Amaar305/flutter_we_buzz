import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../shimmer/home_page_shimmer.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/home/reusable_card.dart';
import '../create/create_page.dart';
import '../dashboard/my_app_controller.dart';
import '../documents/programs.dart';
import '../home/home_controller.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});
  static const routeName = '/notification';
  @override
  Widget build(BuildContext context) {
    final double deviceHeight = MediaQuery.of(context).size.height;
    final double deviceWidth = MediaQuery.of(context).size.width;

    return _buildUI(deviceHeight, deviceWidth);
  }

  Widget _buildUI(double deviceHeight, double deviceWidth) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: deviceWidth * 0.03,
        vertical: deviceHeight * 0.02,
      ),
      height: deviceHeight * 0.90,
      width: deviceWidth * 0.97,
      child: Column(
        children: [
          CustomAppBar(
            'In Campus',
            primaryAction: Row(
              children: [
                GetX<AppController>(
                  builder: (controller) {
                    final currentLoggedInUser = controller.weBuzzUsers
                        .firstWhere((user) =>
                            user.userId ==
                            FirebaseAuth.instance.currentUser!.uid);
                    if (FirebaseAuth.instance.currentUser != null &&
                        currentLoggedInUser.isStaff) {
                      return IconButton(
                        tooltip: 'Create buzz',
                        onPressed: () {
                          Get.to(
                            () => const CreateBuzzPage(isStaff: true),
                          );
                        },
                        icon: const Icon(Icons.add),
                      );
                    } else {
                      return const SizedBox();
                    }
                  },
                ),
                IconButton(
                    onPressed: () => Get.toNamed(ProgramsPage.routeName),
                    icon: const Icon(Icons.view_column_sharp)),
              ],
            ),
          ),
          _notificationListView(),
        ],
      ),
    );
  }

  Widget _notificationListView() {
    return Expanded(
      child: GetX<HomeController>(
        builder: (controller) {
          if (controller.weeBuzzItems.isNotEmpty) {
            final publishedBuzzList = controller.weeBuzzItems
                .where((buzz) => buzz.isPublished && buzz.isCampusBuzz)
                .toList();

            return ListView.builder(
              itemCount: publishedBuzzList.length,
              itemBuilder: (context, index) {
                return ReusableCard(
                  normalWebuzz: publishedBuzzList[index],
                );
              },
            );
          } else {
            return const HomePageShimmer();
          }
        },
      ),
    );
  }
}

class NotificationTile extends StatelessWidget {
  const NotificationTile({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
      ),
      child: const ListTile(
        leading: Icon(Icons.favorite),
        title: FittedBox(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Amarr',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(width: 5),
              Text('& others likes your buzz'),
            ],
          ),
        ),
        trailing: CircleAvatar(),
      ),
    );
  }
}
