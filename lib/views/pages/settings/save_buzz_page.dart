import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../model/we_buzz_model.dart';
import '../../utils/constants.dart';
import '../../widgets/home/cards/reusable_card.dart';
import '../../widgets/setting/custom_setting_title.dart';
import 'controllers/save_page_controller.dart';

class SaveBuzzPage extends GetView<SaveBuzzController> {
  const SaveBuzzPage({super.key});
  static const String routeName = '/save-post-page';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const CustomSettingTitle(title: 'Saved Buzz'),
      ),
      body: Padding(
        padding: kPadding,
        child: _webuzzList(),
      ),
    );
  }

  Widget _webuzzList() {
    return GetBuilder<SaveBuzzController>(
      builder: (_) {
        if (controller.ids.isEmpty) {
          return const CircularProgressIndicator(
            strokeWidth: 0.5,
          ).center();
        } else {
          return ListView.builder(
            itemCount: controller.ids.length,
            itemBuilder: (context, index) => StreamBuilder<WeBuzz>(
              stream: controller.streamBuzz(controller.ids[index]),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const SizedBox();
                if (snapshot.data == null) return const SizedBox();
                return ReusableCard(normalWebuzz: snapshot.data!);
              },
            ),
          );
        }
      },
    );
    // GetX<HomeController>(
    //   builder: (controller) {
    //     WeBuzzUser? currentUser = AppController.instance.currentUser;

    //     if (currentUser == null) return const SizedBox();

    //     final publishedBuzzList = controller.weeBuzzItems
    //         .where((buzz) =>
    //             buzz.isPublished && currentUser.savedBuzz.contains(buzz.docId))
    //         .toList();

    //     if (publishedBuzzList.isNotEmpty) {
    //       return ListView.builder(
    //         itemCount: publishedBuzzList.length,
    //         itemBuilder: (context, index) {
    //           final buzz = publishedBuzzList[index];

    //           if (buzz.validSponsor()) {
    //             return SponsorCard(normalWebuzz: buzz);
    //           }

    //           if (!buzz.isSponsor) {
    //             if (currentUser.blockedUsers.contains(buzz.authorId)) {
    //               return const SizedBox();
    //             } else {
    //               return ReusableCard(
    //                 normalWebuzz: buzz,
    //               );
    //             }
    //           }
    //           return null;
    //         },
    //       );
    //     } else {
    //       return const Center(
    //         child: Text(
    //           'You haven\'t save any buzz!',
    //           style: TextStyle(fontSize: 20),
    //         ),
    //       );
    //     }
    //   },
    // );
  }
}
