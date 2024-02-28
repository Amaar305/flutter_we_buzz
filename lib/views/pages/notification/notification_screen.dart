import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:hi_tweet/model/notification_model.dart';
import 'package:hi_tweet/services/firebase_service.dart';
import 'package:hi_tweet/views/pages/dashboard/my_app_controller.dart';
import 'package:hi_tweet/views/pages/view_profile/view_profile_page.dart';
import 'package:lottie/lottie.dart';
import 'package:nb_utils/nb_utils.dart';

import '../chat/messages/messages_page.dart';
import '../home/reply/reply_page.dart';
import 'notification_controller.dart';

class NotificationsScreen extends GetView<NotificationController> {
  const NotificationsScreen({super.key});
  static const String routeName = '/notification-screens';

  @override
  Widget build(BuildContext context) {
    // final message = ModalRoute.of(context)!.settings.arguments as RemoteMessage;
    // controller.notifications.sort((a, b) => a.timestamp.compareTo(b.timestamp));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButton(
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
                  value: 'clear',
                  child: Row(
                    children: [
                      // ignore: deprecated_member_use
                      Icon(Icons.clear_all),
                      SizedBox(
                        width: 10,
                      ),
                      Text('Clear')
                    ],
                  ),
                )
              ],
              onChanged: (value) {
                if (value == 'asc') {
                  controller.notifications.sort(
                    (a, b) => a.timestamp.compareTo(b.timestamp),
                  );
                } else if (value == 'desc') {
                  controller.notifications.sort(
                    (a, b) => b.timestamp.compareTo(a.timestamp),
                  );
                } else if (value == 'clear') {
                  controller.clearAll();
                  // Clear all the notifiaction
                }
              },
            ),
          )
        ],
      ),
      body: Obx(
        () {
          if (controller.notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Lottie.asset('assets/lottie/2.json'),
                  const Text(
                    'No notification',
                    style: TextStyle(fontSize: 17),
                  ),
                ],
              ),
            );
          }
          return Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListView.builder(
                itemCount: controller.notifications.length,
                itemBuilder: (context, index) {
                  final notification = controller.notifications[index];

                  // Display notification item
                  return NotificationTile(notification: notification);
                },
              )
              /*
            ListView.separated(
              separatorBuilder: (context, index) {
                if (controller.notifications.isEmpty) {
                  return const Center(
                    child: Text('No notification'),
                  );
                }
                final notification = controller.notifications[index];

                if (index == 0 ||
                    controller.isDifferentDay(
                      controller.notifications[index - 1],
                      notification,
                    )) {
                  return buildDateSeparator(
                      notification.timestamp, notification.isRead);
                } else {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Lottie.asset('assets/lottie/2.json'),
                      const Text('data')
                    ],
                  );
                }
              },
              itemCount: controller.notifications.length,
              itemBuilder: (context, index) {
                final notification = controller.notifications[index];
                if (index == 0 ||
                    controller.isDifferentDay(
                      controller.notifications[index - 1],
                      notification,
                    )) {
                  return buildDateSeparator(
                      notification.timestamp, notification.isRead);
                }

                if (index == 0) {
                  return buildDateSeparator(notification.timestamp, false);
                } else if (controller.isDifferentDay(
                    controller.notifications[index - 1], notification)) {
                  return buildDateSeparator(
                      notification.timestamp, notification.isRead);
                }

                // Display notification item
                return NotificationTile(notification: notification);
                // return const SizedBox();
              },
            ),
          */
              );
        },
      ),
    );
  }

  Widget buildDateSeparator(DateTime notificationDate, bool isNew) {
    DateTime today = DateTime.now();
    DateTime yesterday = today.subtract(const Duration(days: 1));
    DateTime last30Days = today.subtract(const Duration(days: 30));

    if (controller.isSameDay(notificationDate, today)) {
      // if (isNew == false) {
      //   return buildSeparator('NEW');
      // } else {
      return buildSeparator('TODAY');
      // }
    } else if (controller.isSameDay(notificationDate, yesterday)) {
      return buildSeparator('YESTERDAY');
    } else if (notificationDate.isAfter(last30Days)) {
      return buildSeparator('Last 30 Days');
    } else {
      return buildSeparator('OLDER');
    }
  }

  Widget buildSeparator(String label) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }
}

class NotificationTile extends StatelessWidget {
  const NotificationTile({
    super.key,
    required this.notification,
  });

  final NotificationModel notification;

  @override
  Widget build(BuildContext context) {
    Widget buildIcon(NotificationType type) {
      Icon icon;
      switch (type) {
        case NotificationType.postCreation:
          icon = const Icon(Icons.post_add);
          break;
        case NotificationType.postLiking:
          icon = const Icon(Icons.favorite);
          break;
        case NotificationType.postComment:
          icon = const Icon(Icons.comment);
          break;
        case NotificationType.postSaved:
          icon = const Icon(Icons.bookmark);
          break;
        case NotificationType.userFollows:
          icon = const Icon(Icons.person);
          break;
        case NotificationType.groupChat:
          icon = const Icon(Icons.group_add);
          break;
        case NotificationType.chat:
          icon = const Icon(Icons.chat);

          break;
        case NotificationType.staff:
          icon = const Icon(Icons.verified);

          break;
        case NotificationType.classRep:
          icon = const Icon(Icons.verified_outlined);

          break;
        case NotificationType.isVerified:
          icon = const Icon(Icons.verified_outlined);

          break;
        case NotificationType.unknown:
          icon = const Icon(Icons.chat);

          break;
      }
      return icon;
    }

    // ignore: no_leading_underscores_for_local_identifiers
    String _message(NotificationType type) {
      String message;
      switch (type) {
        case NotificationType.postCreation:
          message = 'Create a new buzz';
          break;
        case NotificationType.postLiking:
          message = 'Like your buzz';
          break;
        case NotificationType.postComment:
          message = 'Comment on your buzz';
          break;
        case NotificationType.postSaved:
          message = 'Saved your buzz';
          break;
        case NotificationType.userFollows:
          message = 'Follows you';
          break;
        case NotificationType.groupChat:
          message = 'Create a group chat with you';
          break;
        case NotificationType.chat:
          message = 'Text you';

          break;
        case NotificationType.staff:
          message = 'Congratulation 🎉';

          break;
        case NotificationType.classRep:
          message = 'Class Monitor 🎉';

          break;
        case NotificationType.isVerified:
          message = 'Verified User 🎉';

          break;
        case NotificationType.unknown:
          message = 'Create a new buzz';

          break;
      }
      return message;
    }

    var targetUser = AppController.instance.weBuzzUsers
        .firstWhere((user) => user.userId == notification.senderId);

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: InkWell(
        onTap: () async {
          switch (notification.type) {
            case NotificationType.postCreation:
              // Navigate to the new post
              final buzz = await FirebaseService()
                  .getBuzz(notification.postOrUserReference);
              log(buzz.toString());

              if (buzz == null) break;

              Get.toNamed(RepliesPage.routeName, arguments: buzz);
              break;
            case NotificationType.postLiking:
              // Navigate to the liked post

              final buzz = await FirebaseService()
                  .getBuzz(notification.postOrUserReference);
              if (buzz == null) break;

              Get.toNamed(RepliesPage.routeName, arguments: buzz);

              break;
            case NotificationType.postComment:
              // Navigate to the commented post
              final buzz = await FirebaseService()
                  .getBuzz(notification.postOrUserReference);
              if (buzz == null) break;

              Get.toNamed(RepliesPage.routeName, arguments: buzz);

              break;
            case NotificationType.postSaved:
              // Navigate to the saved post

              final buzz = await FirebaseService()
                  .getBuzz(notification.postOrUserReference);
              if (buzz == null) break;

              Get.toNamed(RepliesPage.routeName, arguments: buzz);
              break;
            case NotificationType.userFollows:
              // Navigate to the followers list page

              Get.to(() => ViewProfilePage(weBuzzUser: targetUser));

              break;
            case NotificationType.groupChat:
              // Navigate to the the groupchat page
              final chatConversation = await FirebaseService()
                  .retreiveChatConversation(notification.postOrUserReference);

              log(chatConversation.toString());

              if (chatConversation == null) break;
              Get.to(() => MessagesPage(chat: chatConversation));
              break;

            case NotificationType.chat:
              // Navigate to the the chat page
              final chatConversation = await FirebaseService()
                  .retreiveChatConversation(notification.postOrUserReference);
              log(chatConversation.toString());
              if (chatConversation == null) break;

              Get.to(() => MessagesPage(chat: chatConversation));
              break;
            case NotificationType.staff:
              // Navigate to the the congratulation you're staff now page
              break;

            case NotificationType.classRep:
              // Navigate to the the congratulation you're class rep now page
              break;

            case NotificationType.isVerified:
              // Navigate to the the congratulation you're verified now page
              break;
            case NotificationType.unknown:
              // Do nothing
              break;
          }
          NotificationController.instance
              .updateNotificationRead(notification.id);
        },
        borderRadius: BorderRadius.circular(10),
        child: Stack(
          alignment: Alignment.topLeft,
          children: [
            if (!notification.isRead)
              Icon(
                Icons.circle,
                color: Theme.of(context).colorScheme.primary,
                size: 10,
              ),
            ListTile(
              leading: buildIcon(notification.type),
              title: FittedBox(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      targetUser.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 5),
                    Text(_message(notification.type)),
                  ],
                ),
              ),
              // trailing: notification.type == NotificationType.userFollows
              //     ? (targetUser.followers.contains(notification.recipientId)
              //         ? null
              //         : TextButton(
              //             onPressed: () {
              //               FirebaseService.updateUserData({
              //                 'following':
              //                     FieldValue.arrayUnion([targetUser.userId])
              //               }, notification.recipientId);
              //             },
              //             child: const Text('Follow back'),
              //           ))
              //     : null,
            ),
          ],
        ),
      ),
    );
  }
}
