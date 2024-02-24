import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import '../../../utils/constants.dart';
import '../../../widgets/home/custom_tab_bar.dart';
import '../../../widgets/home/my_buttons.dart';
import '../../dashboard/my_app_controller.dart';
import '../../home/home_controller.dart';
import 'add_users_controller.dart';
import 'components/current_user_relation.dart';

class AddUsersPage extends GetView<AddUsersController> {
  const AddUsersPage({super.key});
  static const String routeName = '/add-users';
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return _buldUI(size);
  }

  Widget _buldUI(Size size) {
    return DefaultTabController(
      length: controller.tabTitles.length,
      initialIndex: controller.index,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Friends',
            style: TextStyle(fontSize: 18),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: _DropdownSortOption(controller: controller),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
              onPressed: () {
                try {
                  final bot = AppController.instance.weBuzzUsers
                      .firstWhere((user) => user.bot);

                  HomeController.instance.dmTheAuthor(bot.userId);
                } catch (e) {
                  log(e.toString());
                }
              },
              child: const Icon(
                FontAwesomeIcons.bots,
                size: 35,
              ),
            ),
        
        
        // Column(
        //   mainAxisAlignment: MainAxisAlignment.start,
        //   crossAxisAlignment: CrossAxisAlignment.start,
        //   mainAxisSize: MainAxisSize.min,
        //   children: [
        //     GetBuilder<AddUsersController>(
        //       builder: (_) {
        //         return TextButton.icon(
        //           onPressed: null,
        //           icon: const Icon(
        //             Icons.person,
        //             size: 30,
        //           ),
        //           label: Text(
        //             MethodUtils.formatNumber(controller.index),
        //             style: const TextStyle(fontSize: 20),
        //           ),
        //         );
        //       },
        //     ),
            
        //   ],
        // ),
        body: Container(
          padding: kPadding,
          height: size.height * 0.98,
          width: size.width * 0.97,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CustomTabBar(
                list: controller.tabTitles,
                onTap: controller.updateIndex,
              ),
              CustomTabBarView(
                children: [
                  CurrentUserRelations(
                    controller: controller,
                    currentUserFriends: CurrentUserFriends.mutual,
                  ),
                  CurrentUserRelations(
                    controller: controller,
                    currentUserFriends: CurrentUserFriends.following,
                  ),
                  CurrentUserRelations(
                    controller: controller,
                    currentUserFriends: CurrentUserFriends.followers,
                  ),
                ],
              ),
              _createChatButton,
            ],
          ),
        ),
      ),
    );
  }

  Widget get _createChatButton {
    return GetBuilder<AddUsersController>(
      builder: (_) {
        if (controller.selectedUser.isNotEmpty) {
          return MyRegistrationButton(
            toUpperCase: false,
            secondaryColor: Colors.white,
            title: controller.selectedUser.length > 1
                ? "Create Group Chat"
                : "Chat With ${controller.selectedUser.first.username}",
            onPressed: () {
              controller.createChat();
            },
          );
        } else {
          return const SizedBox();
        }
      },
    );
  }
}

class _DropdownSortOption extends StatelessWidget {
  const _DropdownSortOption({
    required this.controller,
  });

  final AddUsersController controller;

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
          controller.WeBuzzUsers.sort(
            (a, b) => a.name.compareTo(b.name),
          );
        } else if (value == 'desc') {
          controller.WeBuzzUsers.sort(
            (a, b) => b.name.compareTo(a.name),
          );
        }
      },
    );
  }
}
