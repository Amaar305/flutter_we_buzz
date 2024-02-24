import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../model/we_buzz_model.dart';
import '../../../services/firebase_constants.dart';
import '../../../services/firebase_service.dart';
import '../../utils/constants.dart';
import '../../utils/custom_full_screen_dialog.dart';
import '../../widgets/chat/custom_list_view.dart';
import '../../widgets/home/my_textfield.dart';
import '../chat/add_users_page/components/user_online_condition.dart';
import '../home/reply/reply_page.dart';
import '../view_profile/view_profile_page.dart';
import 'search_controller.dart';

class SearcUserhPage extends GetView<SearchUsersController> {
  const SearcUserhPage({super.key});
  static const String routeName = '/search-user-page';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: kPadding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MyInputField(
              onChanged: (value) {
                controller.searchUser(value);
              },
              // : 'Search...',
              controller: controller.searchEditingController,
              iconData: Icons.search, hintext: 'Search...', label: '',
            ),
            Expanded(
              child: Obx(
                () {
                  if (controller.isSearch.isTrue) {
                    return SearchUserWidget(controller: controller);
                  }
                  return MasonryGridView.builder(
                    itemCount: controller.sponsorImages().length,
                    gridDelegate:
                        const SliverSimpleGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2),
                    itemBuilder: (context, index) {
                      final image = controller.sponsorImages()[index];
                      return AdWidget(image: image);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      // body: SearchUserWidget(controller: controller),
    );
  }
}

class AdWidget extends StatelessWidget {
  const AdWidget({
    super.key,
    required this.image,
  });

  final SponsorItem image;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: GestureDetector(
        onTap: () async {
          CustomFullScreenDialog.showDialog();
          try {
            final doc = await FirebaseService.firebaseFirestore
                .collection(firebaseWeBuzzCollection)
                .doc(image.docId)
                .get()
                .whenComplete(() => CustomFullScreenDialog.cancleDialog());

            WeBuzz buzz = WeBuzz.fromDocumentSnapshot(doc);

            Get.toNamed(RepliesPage.routeName, arguments: buzz);
          } catch (e) {
            CustomFullScreenDialog.cancleDialog();

            log('Error trying to navigate to replies page');
            log(e);
          }
        },
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image(
                image: CachedNetworkImageProvider(image.image),
                fit: BoxFit.cover,
              ),
            ),
            if (image.created.toDate().isToday)
              Container(
                height: MediaQuery.sizeOf(context).height * 0.02,
                width: MediaQuery.sizeOf(context).width * 0.15,
                decoration: const BoxDecoration(
                  color: kPrimary,
                  borderRadius: BorderRadius.only(
                    // bottomLeft: Radius.circular(10),
                    bottomRight: Radius.circular(10),
                    // topLeft: Radius.circular(10),
                    // topRight: Radius.circular(10),
                  ),
                ),
                child: const FittedBox(
                    child: Text(
                  'New',
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold, color: kblack),
                )),
              )
          ],
        ),
      ),
    );
  }
}

class SearchUserWidget extends StatelessWidget {
  const SearchUserWidget({
    super.key,
    required this.controller,
  });

  final SearchUsersController controller;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Obx(() {
        if (controller.users.isNotEmpty) {
          return ListView.builder(
            itemCount: controller.users.length,
            itemBuilder: (context, index) {
              var user = controller.users[index];
              return CustomListViewTileWithActivity(
                onlineStatus: shouldDisplayOnlineStatus(user),
                height: controller.deviceHeight * 0.10,
                title: user.name,
                subtitle: user.username,
                imageUrl: user.imageUrl != null
                    ? user.imageUrl!
                    : defaultProfileImage,
                isOnline: user.isOnline,
                onTap: () => Get.off(() => ViewProfilePage(weBuzzUser: user)),
                isActivity: false,
                sentime: '',
              );
            },
          );
        } else {
          return const SizedBox();
        }
      }),
    );
  }
}
