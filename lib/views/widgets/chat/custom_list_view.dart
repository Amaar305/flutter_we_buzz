// packages
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:hi_tweet/model/message_enum_type.dart';
import 'package:hi_tweet/views/utils/constants.dart';

// models
import '../../../model/chat_message.dart';
import '../../../model/we_buzz_user_model.dart';

// Widgets
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
  });
  final double height;
  final String title;
  final String subtitle;
  final String imageUrl;
  final bool isOnline;
  final bool isSelected;
  final bool onlineStatus;

  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
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
  });

  final double height;
  final String title;
  final String subtitle;
  final String imageUrl;
  final bool isOnline;
  final bool isActivity;
  final bool onlineStatus;

  final Function onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () => onTap(),
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
    );
  }
}

class CustomChatListViewTile extends StatelessWidget {
  const CustomChatListViewTile({
    super.key,
    required this.width,
    required this.deviceHeight,
    required this.isOwnMessage,
    required this.message,
    required this.sender,
  });
  final double width;
  final double deviceHeight;
  final bool isOwnMessage;
  final ChatMessage message;
  final WeBuzzUser sender;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment:
            isOwnMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isOwnMessage)
            RoundedImageNetwork(
              size: width * 0.04,
              imageUrl: sender.imageUrl != null
                  ? sender.imageUrl!
                  : defaultProfileImage,
              key: UniqueKey(),
            )
          else
            Container(),
          SizedBox(width: width * 0.05),
          if (message.type == MessageType.text)
            MessageTile(message: message)
          else
            Text(message.content),
        ],
      ),
    );
  }
}

class MessageTile extends StatelessWidget {
  const MessageTile({
    super.key,
    required this.message,
  });

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Padding(
      padding: EdgeInsets.only(left: size.width * .08),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            padding: EdgeInsets.all(
              message.type == MessageType.image
                  ? size.width * .01
                  : size.width * .04,
            ),
            margin: EdgeInsets.symmetric(
              horizontal: size.width * .04,
              vertical: size.height * .01,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
                bottomLeft: Radius.circular(15),
                bottomRight: Radius.circular(2),
              ),
            ),
            child: Text(
              message.content,
              style: const TextStyle(fontSize: 15, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}
