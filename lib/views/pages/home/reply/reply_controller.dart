import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hi_tweet/services/firebase_service.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../../model/buzz_enum.dart';
import '../../../../model/notification_model.dart';
import '../../../../model/we_buzz_model.dart';
import '../../../../services/firebase_constants.dart';
import '../../../../services/notification_services.dart';
import '../../../utils/custom_full_screen_dialog.dart';
import '../../../utils/method_utils.dart';
import '../../dashboard/my_app_controller.dart';

class ReplyController extends GetxController {
  late TextEditingController textEditingController;

  @override
  void onInit() {
    super.onInit();
    textEditingController = TextEditingController();
  }

  Future<void> reply(WeBuzz weBuzz) async {
    if (textEditingController.text.isNotEmpty &&
        weBuzz.refrence != null &&
        FirebaseAuth.instance.currentUser != null) {
      CustomFullScreenDialog.showDialog();
      WeBuzz replyBuzz = WeBuzz(
        id: MethodUtils.generatedId,
        docId: '',
        authorId: FirebaseAuth.instance.currentUser!.uid,
        content: textEditingController.text.trim(),
        createdAt: Timestamp.now(),
        reBuzzsCount: 0,
        buzzType: BuzzType.reply.name,
        hashtags: [],
        location: AppController.instance.city,
        source: 'Samsumng',
        imageUrl: null,
        likes: [],
        replies: [],
        rebuzzs: [],
        originalId: '',
        likesCount: 0,
        repliesCount: 0,
        isRebuzz: false,
        views: [], isCampusBuzz: false,
      );
      try {
        // Getting target user info, post owner
        final targetUser = AppController.instance.weBuzzUsers
            .firstWhere((user) => user.userId == weBuzz.authorId);

        await weBuzz.refrence!
            .collection(firebaseRepliesCollection)
            .add(replyBuzz.toJson())
            .then((_) async {
          textEditingController.clear();
          CustomFullScreenDialog.cancleDialog();
          await FirebaseService.firebaseFirestore
              .collection(firebaseWeBuzzCollection)
              .doc(weBuzz.docId)
              .update({
            'repliesCount': FieldValue.increment(1),
          });
          // If current user is not equal to the post author, send the notification
          if (weBuzz.authorId != FirebaseAuth.instance.currentUser!.uid) {
            NotificationServices.sendNotification(
              notificationType: NotificationType.postComment,
              targetUser: targetUser,
            );
          }
        });
      } catch (e) {
        CustomFullScreenDialog.cancleDialog();
        log(e);
      }
    }
  }

  @override
  void onClose() {
    super.onClose();
    textEditingController.dispose();
  }
}
