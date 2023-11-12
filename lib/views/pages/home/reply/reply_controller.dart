import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hi_tweet/services/firebase_service.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../../model/buzz_enum.dart';
import '../../../../model/we_buzz_model.dart';
import '../../../../services/firebase_constants.dart';
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
    if (textEditingController.text.isNotEmpty && weBuzz.refrence != null) {
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
      );
      try {
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
    // TODO do this to all of the controllers
  }
}
