import 'dart:io';

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
import '../../../utils/method_utils.dart';
import '../../create/hashtag_sytem.dart';
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
      final hashtags = hashTagSystem(textEditingController.text);
      final urls = extractUrls(textEditingController.text);

      String replyText = textEditingController.text.trim(); //extract the text

      textEditingController.clear(); // clear the textEditingController

      final currentUserId = FirebaseAuth.instance.currentUser!.uid;

      WeBuzz replyBuzz = WeBuzz(
        id: MethodUtils.generatedId,
        docId: '',
        authorId: currentUserId,
        content: replyText,
        createdAt: Timestamp.now(),
        reBuzzsCount: 0,
        buzzType: BuzzType.reply.name,
        hashtags: hashtags,
        location: AppController.instance.city,
        source: Platform.isAndroid ? 'Android' : 'IOS',
        imageUrl: null,
        originalId: '',
        likesCount: 0,
        repliesCount: 0,
        isRebuzz: false,
        isCampusBuzz: false,
        links: urls,
      );
      try {
        // Getting target user info, post owner
        final targetUser = await FirebaseService.userByID(weBuzz.authorId);

        if (targetUser == null || weBuzz.refrence == null) return;

        await weBuzz.refrence!
            .collection(firebaseRepliesCollection)
            .add(replyBuzz.toJson())
            .then((_) async {
          await FirebaseService.firebaseFirestore
              .collection(firebaseWeBuzzCollection)
              .doc(weBuzz.docId)
              .update({
            'repliesCount': FieldValue.increment(1),
          });
        });
        // If current user is not equal to the post author, send the notification
        if (weBuzz.authorId != currentUserId) {
          NotificationServices.sendNotification(
            notificationType: NotificationType.postComment,
            targetUser: targetUser,
            notifiactionRef: weBuzz.docId,
          );
        }
      } catch (e) {
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
