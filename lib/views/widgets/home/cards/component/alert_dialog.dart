import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hi_tweet/services/firebase_constants.dart';
import 'package:hi_tweet/services/firebase_service.dart';
import 'package:hi_tweet/views/widgets/home/my_buttons.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../../../model/we_buzz_model.dart';
import '../../../../../model/we_buzz_user_model.dart';
import '../../../../pages/create/edit/edit_post_page.dart';
import '../../../../pages/home/home_controller.dart';
import '../../../../utils/method_utils.dart';
import '../../../bottom_sheet_option.dart';
import 'bottom_sheet.dart';

void showBAlertDialog({
  required WeBuzzUser buzzOwner,
  required WeBuzzUser currentUser,
  required WeBuzz normalWebuzz,
  required bool isReply,
  required String originalId,
}) {
  Get.dialog(
    AlertDialog(
      contentPadding:
          const EdgeInsets.only(left: 24, right: 24, top: 20, bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: const Row(
        children: [
          Text(
            'Actions',
            style: TextStyle(fontSize: 25),
          ),
        ],
      ),
      content: SizedBox(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (normalWebuzz.authorId == FirebaseAuth.instance.currentUser!.uid)
              OptionItem(
                icon: Icon(
                  Icons.edit,
                  color: Theme.of(Get.context!).colorScheme.primary,
                ),
                name: 'Edit Buzz',
                onTap: () {
                  Get.to(() => EditPostPage(normalWebuzz, isReply, originalId));
                },
              ),
            if (normalWebuzz.authorId == FirebaseAuth.instance.currentUser!.uid)
              OptionItem(
                icon: Icon(
                  Icons.delete_forever,
                  color: Theme.of(Get.context!).colorScheme.primary,
                ),
                name: 'Delete Buzz',
                onTap: () async {
                  Get.back();
                  if (isReply) {
                    try {
                      await FirebaseService.firebaseFirestore
                          .collection(firebaseWeBuzzCollection)
                          .doc(originalId)
                          .collection(firebaseRepliesCollection)
                          .doc(normalWebuzz.docId)
                          .delete()
                          .whenComplete(() async {
                        await FirebaseService.firebaseFirestore
                            .collection(firebaseWeBuzzCollection)
                            .doc(originalId)
                            .update({
                          'repliesCount': FieldValue.increment(-1),
                        });
                      });
                    } catch (e) {
                      log('Error trying to delete a reply buzz');
                      log(e);
                    }
                  } else {
                    showBottomSheetForDeletion(buzzOwner, normalWebuzz);
                  }
                },
              ),
            if (normalWebuzz.authorId != FirebaseAuth.instance.currentUser!.uid)
              if (MethodUtils.shouldDisplayDMButton(buzzOwner))
                OptionItem(
                  icon: Icon(
                    Icons.chat_bubble,
                    color: Theme.of(Get.context!).colorScheme.primary,
                  ),
                  name: 'DM',
                  onTap: () {
                    HomeController.instance.dmTheAuthor(normalWebuzz.authorId);
                  },
                ),
            OptionItem(
              icon: const Icon(
                Icons.report,
                color: Colors.red,
              ),
              name: 'Report Buzz',
              onTap: () async {
                Get.back();

                if (isReply) {
                  try {
                    await FirebaseService.firebaseFirestore
                        .collection(firebaseWeBuzzCollection)
                        .doc(originalId)
                        .collection(firebaseRepliesCollection)
                        .doc(normalWebuzz.docId)
                        .delete();
                  } catch (e) {
                    log('Error trying to delete a reply buzz');
                    log(e);
                  }
                } else {
                  showBottomSheetForReporting(normalWebuzz, isReply);
                }
              },
            ),
          ],
        ),
      ),
      actions: [
        CustomMaterialButton(
          title: 'Cancel',
          onPressed: () => Get.back(),
        ),
      ],
    ),
  );
}
