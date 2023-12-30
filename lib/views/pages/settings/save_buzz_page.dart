import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../model/we_buzz_user_model.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/home/reusable_card.dart';
import '../dashboard/my_app_controller.dart';
import '../home/home_controller.dart';

class SaveBuzzPage extends StatelessWidget {
  const SaveBuzzPage({super.key});
  static const String routeName = '/save-post-page';

  @override
  Widget build(BuildContext context) {
    final deviceHeight = MediaQuery.of(context).size.height;
    final deviceWidth = MediaQuery.of(context).size.height;
    return _buildUI(deviceHeight, deviceWidth);
  }

  Widget _buildUI(double deviceHeight, double deviceWidth) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: deviceWidth * 0.03,
            vertical: deviceHeight * 0.02,
          ),
          // width: deviceWidth * 0.97,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CustomAppBar(
                'Saved buzzes',
                secondaryAction: const BackButton(),
              ),
              _webuzzList()
            ],
          ),
        ),
      ),
    );
  }

  Widget _webuzzList() {
    return Expanded(
      child: GetX<HomeController>(
        builder: (_) {
          WeBuzzUser currentUser =
              AppController.instance.weBuzzUsers.firstWhere(
            (user) => user.userId == FirebaseAuth.instance.currentUser!.uid,
          );
          if (HomeController.instance.weeBuzzItems
              .where(
                (buzz) =>
                    buzz.isPublished &&
                    currentUser.savedBuzz.contains(buzz.docId),
              )
              .isNotEmpty) {
            return ListView.builder(
              itemCount: HomeController.instance.weeBuzzItems
                  .where(
                    (buzz) =>
                        buzz.isPublished &&
                        currentUser.savedBuzz.contains(buzz.docId),
                  )
                  .length,
              itemBuilder: (context, index) {
                return ReusableCard(
                  normalWebuzz: HomeController.instance.weeBuzzItems
                      .where(
                        (buzz) =>
                            buzz.isPublished &&
                            currentUser.savedBuzz.contains(buzz.docId),
                      )
                      .toList()[index],
                );
              },
            );
          } else {
            return const Center(
              child: Text(
                'You haven\'t save any buzz!',
                style: TextStyle(fontSize: 20),
              ),
            );
          }
        },
      ),
    );
  }
}
