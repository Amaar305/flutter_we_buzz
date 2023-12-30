import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

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
      length: 3,
      initialIndex: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Friends',
            style: TextStyle(fontSize: 32),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: _DropdownSortOption(controller: controller),
            ),
          ],
        ),
        body: Container(
          padding: EdgeInsetsDirectional.symmetric(
            horizontal: size.width * 0.03,
            vertical: size.height * 0.02,
          ),
          height: size.height * 0.98,
          width: size.width * 0.97,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                height: 45,
                decoration: BoxDecoration(
                  color: Theme.of(Get.context!)
                      .colorScheme
                      .primary
                      .withOpacity(0.5),
                  borderRadius: BorderRadius.circular(25.0),
                ),
                child: TabBar(
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.black,
                  labelStyle: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                  tabs: controller.titles.map((e) => Tab(text: e)).toList(),
                ),
              ),
              Expanded(
                child: TabBarView(
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
              ),
              _createChatButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _createChatButton() {
    return GetBuilder<AddUsersController>(
      builder: (_) {
        if (controller.selectedUser.isNotEmpty) {
          return TextButton(
            onPressed: () {
              controller.createChat();
            },
            child: Text(
              controller.selectedUser.length > 1
                  ? "Create Group Chat"
                  : "Chat With ${controller.selectedUser.first.username}",
            ),
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
