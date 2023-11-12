import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:hi_tweet/services/current_user.dart';
import 'package:hi_tweet/views/pages/chat/chat_controller_old.dart';
import 'package:hi_tweet/views/pages/chat/chat_page_old.dart';
import 'package:hi_tweet/views/utils/custom_snackbar.dart';

import '../../../model/we_buzz_user_model.dart';
import '../../utils/constants.dart';
import '../../widgets/chat/active_user_widget.dart';
import '../../widgets/chat/custom_text_form_field.dart';
import '../../widgets/chat/recent_chat_widget.dart';

class RecentChatPage extends GetView<ChatControllerOld> {
  const RecentChatPage({super.key});
  static const routeName = '/recent-chat-page';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Direct Message'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButton(
              icon: const Icon(
                Icons.filter_list,
              ),
              underline: Container(),
              items: const [
                DropdownMenuItem(
                  value: 'name',
                  child: Row(
                    children: [
                      // ignore: deprecated_member_use
                      Icon(FontAwesomeIcons.sortAlphaUp),
                      SizedBox(
                        width: 10,
                      ),
                      Text('Name')
                    ],
                  ),
                ),
                DropdownMenuItem(
                  value: 'followers',
                  child: Row(
                    children: [
                      Icon(Icons.person_add),
                      SizedBox(
                        width: 10,
                      ),
                      Text('Followers')
                    ],
                  ),
                ),
                DropdownMenuItem(
                  value: 'following',
                  child: Row(
                    children: [
                      Icon(Icons.person_add_alt),
                      SizedBox(
                        width: 10,
                      ),
                      Text('Following')
                    ],
                  ),
                ),
                DropdownMenuItem(
                  value: 'all',
                  child: Row(
                    children: [
                      Icon(Icons.filter_alt_off),
                      SizedBox(
                        width: 10,
                      ),
                      Text('Clear')
                    ],
                  ),
                ),
              ],
              onChanged: (value) {
                if (value == 'name') {
                  controller.weBuzzLists.sort(
                    (a, b) => a.name.compareTo(b.name),
                  );
                } else if (value == 'Followers') {
                  controller.weBuzzLists.where((user) => user.followers
                      .contains(CurrentLoggeedInUser.currenoggedIntUser!.uid));
                }
              },
            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showUserSearchDialog();
        },
        heroTag: const ValueKey(routeName),
        child: const Icon(Icons.message),
      ),
      body: Column(
        children: [
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 50),
                  _builtSearchUserField(context),
                  const SizedBox(height: 20),
                  Text(
                    'Active Users',
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge!
                        .copyWith(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.start,
                  ),
                  const SizedBox(height: 10),
                  _builtActiveUsersSection()
                ],
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder(
              stream: controller.streamCurrentUserFriendsID(),

              // get id of only known users
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  // if data is loading
                  case ConnectionState.waiting:
                  case ConnectionState.none:
                    return const Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    );

                  // if some or all data is loaded, then show it
                  case ConnectionState.done:
                  case ConnectionState.active:
                    if (!snapshot.hasData) {
                      return const Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      );
                    }
                    final userIds = snapshot.data ?? [];
                    if (userIds.isEmpty) {
                      return const SizedBox();
                    }

                    return StreamBuilder<List<WeBuzzUser>>(
                      stream: controller.streamCurrentUserFriends(userIds),
                      builder: (context, snapshot) {
                        switch (snapshot.connectionState) {
                          // if data is loading
                          case ConnectionState.waiting:
                          case ConnectionState.none:
                            return const Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            );

                          // if some or all data is loaded, then show it
                          case ConnectionState.done:
                          case ConnectionState.active:
                            if (!snapshot.hasData) {
                              return const Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              );
                            }
                            final data = snapshot.data;
                            if (data == null) {
                              return const SizedBox();
                            }

                            return Obx(
                              () {
                                return ListView.separated(
                                  itemCount: controller.isTyping.isTrue
                                      ? controller.searchUsers.length
                                      : data.length,
                                  itemBuilder: (context, index) {
                                    final user = controller.isTyping.isTrue
                                        ? controller.searchUsers[index]
                                        : data[index];
                                    return RecentChats(
                                      weBuzzUser: user,
                                      onTap: () {
                                        FocusScope.of(context).unfocus();
                                        Get.to(
                                          () => ChatPageOld(user: user),
                                        );
                                      },
                                    );
                                  },
                                  separatorBuilder: (context, index) =>
                                      const Divider(
                                    indent: 20,
                                    thickness: 0.02,
                                    endIndent: 20,
                                  ),
                                );
                              },
                            );
                        }
                      },
                    );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _builtActiveUsersSection() {
    return Obx(() {
      if (controller.weBuzzLists.where((user) => user.isOnline).isEmpty) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: controller.weBuzzLists
                .where((user) => !user.isOnline)
                .map(
                  (activeUser) => ActiveUser(
                    weBuzzUser: activeUser,
                  ),
                )
                .toList(),
          ),
        );
      } else {
        return const Center(
          child: Text(
            'No users online',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20),
          ),
        );
      }
    });
  }

  Widget _builtSearchUserField(BuildContext context) {
    return CustomTextFormField(
      controller: controller.searchUserEditingController,
      hintText: "Search direct message...",
      onChanged: (val) => controller.searchUsers,
      onFieldSubmitted: (p0) => controller.search(),
    );
  }

// for adding new user
  void _showUserSearchDialog() {
    String username = '';
    Get.dialog(
      WillPopScope(
        child: AlertDialog(
          contentPadding:
              const EdgeInsets.only(left: 24, right: 24, top: 20, bottom: 10),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Icon(
                Icons.message,
                color: Theme.of(Get.context!).colorScheme.primary,
              ),
              const Text('Add User'),
            ],
          ),
          content: TextFormField(
            maxLines: null,
            onChanged: (value) => username = value,
            decoration: InputDecoration(
              hintText: 'Username',
              prefixIcon: Icon(
                Icons.email,
                color: Theme.of(Get.context!).colorScheme.primary,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          ),
          actions: [
            MaterialButton(
              onPressed: () {
                Get.back();
              },
              child: Text(
                'Cancle',
                style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(Get.context!).colorScheme.primary),
              ),
            ),
            MaterialButton(
              onPressed: () async {
                Get.back();
                if (username.isNotEmpty) {
                  await ChatControllerOld.instance
                      .addChatUser(username)
                      .then((value) {
                    if (!value) {
                      CustomSnackBar.showSnackbar('User does not exit!');
                    }
                  });
                }
              },
              child: Text(
                'Add',
                style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(Get.context!).colorScheme.primary),
              ),
            ),
          ],
        ),
        onWillPop: () => Future.value(false),
      ),
      barrierDismissible: false,
      barrierColor: kPrimary.withOpacity(0.03),
      useSafeArea: true,
    );
  }
}
