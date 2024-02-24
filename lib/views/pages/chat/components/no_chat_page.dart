import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';



class NoChatPage extends StatelessWidget {
  const NoChatPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset('assets/images/noChats2.png', height: 300),
        32.height,
        Text('No Chats!', style: boldTextStyle(size: 20)),
        16.height,
        Text(
          'No one to chat with?!, chat with buzzbot🐝 AI',
          style: secondaryTextStyle(),
          textAlign: TextAlign.center,
        ).paddingSymmetric(vertical: 8, horizontal: 60),
        50.height,
        // AppButton(
        //   shapeBorder: RoundedRectangleBorder(
        //     borderRadius: BorderRadius.circular(30),
        //   ),
        //   color: kPrimary,
        //   elevation: 10,
        //   onTap: () {
        //     final bot = AppController.instance.weBuzzUsers
        //         .firstWhere((user) => user.bot);
        //     HomeController.instance.dmTheAuthor(bot.userId);
        //   },
        //   child: Text(
        //     'Start Chat',
        //     style: boldTextStyle(color: kDefaultGrey),
        //   ),
        // ).paddingSymmetric(horizontal: 32),
      ],
    );
  }
}
