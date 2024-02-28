import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:hi_tweet/views/widgets/home/custom_tab_bar.dart';

import '../../utils/constants.dart';
import '../../utils/method_utils.dart';
import '../../widgets/chat/custom_list_view.dart';
import '../view_profile/view_profile_page.dart';
import 'users_list_controller.dart';

class UsersPageList extends GetView<UserListController> {
  const UsersPageList({super.key});
  static const String routeName = '/users-lists-pages';

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: controller.tabLists.length,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Webuzz users'),
          actions: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: _DropdownButton(controller: controller),
            ),
          ],
        ),
        body: Padding(
          padding: kPadding,
          child: Column(
            children: [
              CustomTabBar(list: controller.tabLists),
              CustomTabBarView(
                children: [
                  AllUsersWidget(controller: controller),
                  AllUsersWidget(controller: controller, isClassReps: true)
                ],
              ),
            ],
          ),
        ),
        floatingActionButton: TextButton.icon(
          onPressed: null,
          icon: const Icon(
            Icons.person,
            size: 30,
          ),
          label: Obx(
            () {
              final users = controller.allUsers
                  .where((user) => !user.bot || user.isSuspended)
                  .toList()
                  .length;
              return Text(
                MethodUtils.formatNumber(users),
                style: const TextStyle(fontSize: 20),
              );
            },
          ),
        ),
      ),
    );
  }
}

class AllUsersWidget extends StatelessWidget {
  const AllUsersWidget({
    super.key,
    required this.controller,
    this.isClassReps = false,
  });

  final UserListController controller;
  final bool isClassReps;
  @override
  Widget build(BuildContext context) {
    return Obx(
      () {
        return ListView.builder(
          itemCount: controller.allUsers.length,
          itemBuilder: (context, index) {
            var user = controller.allUsers[index];
            if (user.bot || user.isSuspended) {
              return const SizedBox();
            }
            if (user.userId == UserListController.currentUserId) {
              return const SizedBox();
            }

            if (isClassReps) {
              if (user.isClassRep == false) return const SizedBox();
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
                isChatPage: false,
                sentime: '',
              );
            } else {
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
                isChatPage: false,
                sentime: '',
              );
            }
          },
        );
      },
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
        DropdownMenuItem(
          value: 'time',
          child: Row(
            children: [
              // ignore: deprecated_member_use
              Icon(FontAwesomeIcons.sortAlphaDesc),
              SizedBox(
                width: 10,
              ),
              Text('Date')
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
        } else if (value == 'time') {
          controller.allUsers.sort(
            (a, b) => b.createdAt.compareTo(a.createdAt),
          );
        }
      },
    );
  }
}
