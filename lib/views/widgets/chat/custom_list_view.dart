// packages
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:hi_tweet/services/firebase_constants.dart';
import 'package:hi_tweet/services/firebase_service.dart';
import 'package:hi_tweet/views/utils/my_date_utils.dart';

// models
import '../../../model/chat_model.dart';
import '../../../model/message_enum_type.dart';
import '../../../model/message_model.dart';

// Widgets

import '../../../model/we_buzz_user_model.dart';
import '../rounded_image_network.dart';

class CustomListViewTile extends StatelessWidget {
  const CustomListViewTile({
    super.key,
    required this.height,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.isOnline,
    required this.isSelected,
    this.onTap,
    required this.onlineStatus,
    this.onLongPress,
  });
  final double height;
  final String title;
  final String subtitle;
  final String imageUrl;
  final bool isOnline;
  final bool isSelected;
  final bool onlineStatus;

  final void Function()? onTap;
  final void Function()? onLongPress;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      onLongPress: onLongPress ?? () {},
      minVerticalPadding: height * 0.20,
      leading: RoundedImageNetworkWithStatusIndicator(
        key: UniqueKey(),
        size: height / 2,
        imageUrl: imageUrl,
        isOnline: isOnline,
        onlineStatus: onlineStatus,
      ),
      trailing: isSelected ? const Icon(Icons.check) : null,
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w200,
        ),
      ),
    );
  }
}

class CustomListViewTileWithActivity extends StatelessWidget {
  const CustomListViewTileWithActivity({
    super.key,
    required this.height,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.isOnline,
    required this.isActivity,
    required this.onTap,
    required this.onlineStatus,
    this.isStaff = false,
    this.isChatPage = true,
    this.onLongPress,
    required this.sentime,
    this.messageDoc,
    this.isClassRep = false,
  });

  final double height;
  final String title;
  final String subtitle;
  final String imageUrl;
  final bool isOnline;
  final bool isActivity;
  final bool onlineStatus;
  final bool isStaff;
  final bool isClassRep;
  final bool isChatPage;
  final String sentime;
  final String? messageDoc;

  final Function onTap;
  final void Function()? onLongPress;

  @override
  Widget build(BuildContext context) {
    return ListTile(
        onTap: () => onTap(),
        onLongPress: onLongPress,
        minVerticalPadding: height * 0.20,
        leading: RoundedImageNetworkWithStatusIndicator(
          onlineStatus: onlineStatus,
          key: UniqueKey(),
          size: height / 2,
          imageUrl: imageUrl,
          isOnline: isOnline,
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: isActivity
            ? Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SpinKitThreeBounce(
                    color: Colors.white,
                    size: height * 0.10,
                  ),
                ],
              )
            : Text(
                subtitle,
                style: const TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 12,
                ),
              ),
        trailing: !isChatPage
            ? (isStaff
                ? Icon(
                    isClassRep ? Icons.done_outline : Icons.verified_outlined,
                    size: 20,
                  )
                : null)
            : null
        // : messageDoc == null
        //     ? const Text('data')
        //     : tileTrailingInfo(),
        );
  }

  Widget tileTrailingInfo() {
    return StreamBuilder(
      stream: stream(sentime, messageDoc!),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.waiting:
            return const SizedBox();

          case ConnectionState.done:
          case ConnectionState.active:
            if (!snapshot.hasData) {
              return const SizedBox();
            }

            final message = snapshot.data;

            if (message!.status == MessageStatus.notView &&
                message.senderID != FirebaseAuth.instance.currentUser!.uid) {
              return Container(
                height: 15,
                width: 15,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
              );
            } else {
              return Text(
                MyDateUtil.getMessageTime(time: message.read, context: context),
                style: Theme.of(context).textTheme.bodyMedium,
              );
            }
        }
      },
    );
  }
}

Stream<MessageModel> stream(String chatDoc, String messageDoc) {
  return FirebaseService.firebaseFirestore
      .collection(firebaseChatCollection)
      .doc(chatDoc)
      .collection(firebaseMessageCollection)
      .doc(messageDoc)
      .snapshots()
      .map((doc) => MessageModel.fromDocumentSnapshot(doc));
}

class CustomChatTileWithActivity extends StatelessWidget {
  const CustomChatTileWithActivity({
    super.key,
    required this.user,
    required this.chat,
    this.onTap,
    required this.title,
    required this.height,
    required this.isActivity,
    required this.lastMessage,
    required this.imageUrl,
    this.trailing,
    required this.isOnline,
  });

  final WeBuzzUser user;
  final Conversation chat;
  final void Function()? onTap;
  final double height;
  final bool isActivity;
  final bool isOnline;
  final String title;
  final String imageUrl;
  final String lastMessage;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      minVerticalPadding: height * 0.20,
      leading: RoundedImageNetworkWithStatusIndicator(
        onlineStatus: isOnline,
        key: UniqueKey(),
        size: height / 2,
        imageUrl: imageUrl,
        isOnline: user.isOnline,
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: isActivity
          ? Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SpinKitThreeBounce(
                  color: Colors.white,
                  size: height * 0.10,
                ),
              ],
            )
          : Text(
              lastMessage,
              maxLines: 1,
              style: const TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 12,
              ),
            ),
      trailing: trailing,
    );
  }
}
