import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../../model/documents/lecture_note_model.dart';
import '../../../../model/we_buzz_model.dart';
import '../../../../services/firebase_service.dart';
import '../../../utils/constants.dart';
import '../../advert/advert_page.dart';
import '../../dashboard/my_app_controller.dart';
import '../programs_controller.dart';
import '../view/doc_view.dart';

class BookCard extends StatelessWidget {
  const BookCard({
    super.key,
    required this.lecture,
  });

  final LectureNoteModel lecture;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        try {
          WeBuzz selectedAd = ProgramsController.instance.getRandomAdvert();
          int guess = ProgramsController.instance.nextNumber(20);
          if (guess % 2 == 0) {
            toast('Ad for 15 seconds');
            Get.to(
              () => AdvertPage(
                advert: selectedAd,
                navigaToPage: () => Get.off(
                  () => DocumentView(
                    url: lecture.url,
                    title: lecture.title,
                  ),
                ),
              ),
            );
          } else {
            Get.to(
              () => DocumentView(
                url: lecture.url,
                title: lecture.title,
              ),
            );
          }
          AppController.instance.updateLastBook(lecture.id);
        } catch (e) {
          Get.to(
            () => DocumentView(
              url: lecture.url,
              title: lecture.title,
            ),
          );
          log('Error trying to display an ads');
          log(e);
        }
      },
      child: Container(
        margin: const EdgeInsets.only(right: 20),
        width: MediaQuery.sizeOf(context).height * 0.15,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              alignment: Alignment.topRight,
              children: [
                SizedBox(
                  height: MediaQuery.sizeOf(context).height * 0.2,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: const Image(
                      image: CachedNetworkImageProvider(coverImage),
                      fit: BoxFit.fitHeight,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () async {
                    try {
                      if (AppController.instance.currentUser == null) return;
                      if (FirebaseAuth.instance.currentUser == null) return;

                      final user = AppController.instance.currentUser!;

                      await FirebaseService.updateUserData(
                        {
                          'bookmarks': user.bookmarks.contains(lecture.id)
                              ? FieldValue.arrayRemove([lecture.id])
                              : FieldValue.arrayUnion([lecture.id]),
                        },
                        user.userId,
                      ).then((value) {
                        toast('Saved');
                      });

                      AppController.instance.fetchUserDetails(user.userId);
                    } catch (e) {
                      toast('Something went wrong try again later');
                      log('Error trying to update bookz');
                      log(e);
                    }
                  },
                  icon: AppController.instance.currentUser!.bookmarks
                          .contains(lecture.id)
                      ? const Icon(
                          Icons.favorite_outlined,
                          color: kPrimary,
                        )
                      : const Icon(
                          Icons.favorite_border_outlined,
                          color: kPrimary,
                        ),
                )
              ],
            ),
            const SizedBox(height: 10),
            Text(
              lecture.title,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              textAlign: TextAlign.start,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
            const SizedBox(height: 5),
            Text(
              lecture.programName,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w300),
              textAlign: TextAlign.start,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ],
        ),
      ),
    );
  }
}
