import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../utils/constants.dart';
import '../../widgets/chat/custom_list_view.dart';
import '../../widgets/chat/custom_text_form_field.dart';
import '../chat/add_users_page/components/user_online_condition.dart';
import '../view_profile/view_profile_page.dart';
import 'search_controller.dart';

class SearcUserhPage extends GetView<SearchUsersController> {
  const SearcUserhPage({super.key});
  static const String routeName = '/search-user-page';

  @override
  Widget build(BuildContext context) {
    final deviceHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Find a friend'),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(deviceHeight * .09),
          child: CustomTextField(
            onChanged: (value) {
              controller.searchUser(value);
            },
            hintText: 'Search...',
            obscureText: false,
            controller: controller.searchEditingController,
            iconData: Icons.search,
          ),
        ),
      ),
      body: SearchUserWidget(controller: controller),
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
    return Obx(() {
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
              imageUrl:
                  user.imageUrl != null ? user.imageUrl! : defaultProfileImage,
              isOnline: user.isOnline,
              onTap: () => Get.off(() => ViewProfilePage(weBuzzUser: user)),
              isActivity: false, sentime: '',
            );
          },
        );
      } else {
        return const SizedBox();
      }
    });
  }
}
