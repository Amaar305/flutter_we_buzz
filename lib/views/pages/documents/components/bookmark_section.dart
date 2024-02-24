import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hi_tweet/views/pages/dashboard/my_app_controller.dart';
import 'package:hi_tweet/views/pages/documents/components/continue.dart';
import 'package:hi_tweet/views/pages/documents/programs_controller.dart';
import 'package:nb_utils/nb_utils.dart';

class BookmarkSection extends StatelessWidget {
  const BookmarkSection({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      child: GetBuilder<AppController>(
        builder: (controller) {
          if (controller.currentUser == null) return const SizedBox();
          if (FirebaseAuth.instance.currentUser == null) {
            return const SizedBox();
          }

          if (controller.currentUser!.bookmarks.isNotEmpty) {
            final savedBooksId = controller.currentUser!.bookmarks;
            return ListView.builder(
              itemCount: savedBooksId.length,
              itemBuilder: (context, index) {
                final bookId = savedBooksId[index];

                try {
                  final lectureNote = ProgramsController.instance.lectureNotes
                      .firstWhere((note) => note.id == bookId);
                  return ContinueReadingWidget(lectureNoteModel: lectureNote);
                } catch (e) {
                  log('Error trying to filter bookmarked for user');
                  log(e);
                  return const SizedBox();
                }
              },
            );
          } else {
            return const Text('Haven\'t bookmarked any book yet!').center();
          }
        },
      ),
    );
  }
}
