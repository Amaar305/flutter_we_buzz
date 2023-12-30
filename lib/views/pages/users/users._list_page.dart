import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:hi_tweet/views/utils/method_utils.dart';

import '../../utils/constants.dart';
import '../../widgets/chat/custom_list_view.dart';
import '../view_profile/view_profile_page.dart';
import 'users_list_controller.dart';

class UsersPageList extends GetView<UserListController> {
  const UsersPageList({super.key});
  static const String routeName = '/users-lists-pages';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Webuzz Users'),
        actions: [
          _DropdownButton(controller: controller),
        ],
      ),
      body: Obx(
        () {
          return ListView.builder(
            itemCount: controller.allUsers.length,
            itemBuilder: (context, index) {
              var user = controller.allUsers[index];
              return CustomListViewTileWithActivity(
                height: MediaQuery.of(context).size.height * 0.10,
                title: user.name,
                subtitle: user.username,
                imageUrl: user.imageUrl ?? defaultProfileImage,
                isOnline: user.isOnline,
                isActivity: false,
                onTap: () => Get.to(() => ViewProfilePage(weBuzzUser: user)),
                onlineStatus: true,
                isStaff: user.isStaff,
                onLongPress: () {
                  controller.makeMeStaff(user, user.isStaff ? false : true);
                },
                isChatPage: false, sentime: '',
              );
            },
          );
        },
      ),
      floatingActionButton: TextButton.icon(
        onPressed: null,
        icon: const Icon(
          Icons.person,
          size: 30,
        ),
        label: Text(
          MethodUtils.formatNumber(57890),
          style: const TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}

class _DropdownButton extends StatelessWidget {
  const _DropdownButton({
    required this.controller,
  });

  final UserListController controller;

  @override
  Widget build(BuildContext context) {
    return DropdownButton(
      icon: const Icon(Icons.sort),
      underline: Container(),
      items: const [
        DropdownMenuItem(
          value: 'asc',
          child: Row(
            children: [
              // ignore: deprecated_member_use
              Icon(FontAwesomeIcons.sortAlphaUp),
              SizedBox(
                width: 10,
              ),
              Text('Asc')
            ],
          ),
        ),
        DropdownMenuItem(
          value: 'desc',
          child: Row(
            children: [
              // ignore: deprecated_member_use
              Icon(FontAwesomeIcons.sortAlphaDesc),
              SizedBox(
                width: 10,
              ),
              Text('Desc')
            ],
          ),
        ),
      ],
      onChanged: (value) {
        if (value == 'asc') {
          controller.allUsers.sort(
            (a, b) => a.name.compareTo(b.name),
          );
        } else if (value == 'desc') {
          controller.allUsers.sort(
            (a, b) => b.name.compareTo(a.name),
          );
        }
      },
    );
  }
}
