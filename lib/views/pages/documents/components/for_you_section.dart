import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../../model/documents/course_model.dart';
import '../../../../model/documents/lecture_note_model.dart';
import '../../../../services/firebase_constants.dart';
import '../../../../services/firebase_service.dart';
import '../../dashboard/my_app_controller.dart';
import '../programs_controller.dart';
import 'book_card_widget.dart';
import 'continue.dart';

class ForYouSection extends StatelessWidget {
  const ForYouSection({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Continues section
          PreviousUserBook(),

          // User programmes section
          CurrentUsersProgrammesBooks(),

          // Free book section
          FreeBooksWidget()
        ],
      ),
    );
  }
}

class PreviousUserBook extends StatelessWidget {
  const PreviousUserBook({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AppController>(
      builder: (controller) {
        if (controller.currentUser!.lastBook == null ||
            controller.currentUser == null ||
            FirebaseAuth.instance.currentUser == null) {
          return const SizedBox();
        } else {
          try {
            return StreamBuilder<LectureNoteModel>(
              stream: FirebaseService.firebaseFirestore
                  .collection(firebaseLectureNotesCollection)
                  .doc(controller.currentUser!.lastBook!)
                  .snapshots()
                  .map((event) => LectureNoteModel.fromDocument(event)),
              builder: (context, snapshot) {
                if (!snapshot.hasData ||
                    snapshot.hasError ||
                    snapshot.data == null) {
                  return const SizedBox();
                }
                final note = snapshot.data;
                if (note == null) return const SizedBox();
                return Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    10.height,
                    const Text(
                      'Continue reading',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    10.height,
                    ContinueReadingWidget(
                      showButton: true,
                      lectureNoteModel: note,
                    ),
                  ],
                );
              },
            );
          } catch (e) {
            log('Error trying to get the previous book of the user');
            log(e);
            return const SizedBox();
          }
        }
      },
    );
  }
}

class CurrentUsersProgrammesBooks extends StatelessWidget {
  const CurrentUsersProgrammesBooks({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AppController>(
      builder: (controller) {
        if (controller.currentUser == null ||
            FirebaseAuth.instance.currentUser == null) {
          return const SizedBox();
        } else if (controller.currentUser!.program == null) {
          return const SizedBox();
        } else {
          return Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              30.height,
              Text(
                controller.currentUser!.program!,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
              10.height,
              SizedBox(
                height: MediaQuery.sizeOf(context).height * 0.4,
                child: Obx(
                  () {
                    final lectures = ProgramsController.instance.lectureNotes
                        .where((note) =>
                            note.programName ==
                                controller.currentUser!.program! &&
                            note.level == controller.currentUser!.level)
                        .toList();

                    final notes = lectures.length > 4
                        ? lectures.take(4).toList()
                        : lectures;
                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: notes.length,
                      itemBuilder: (context, index) {
                        final lecture = notes[index];

                        return BookCard(lecture: lecture);
                      },
                    );
                  },
                ),
              ),
            ],
          );
        }
      },
    );
  }
}

class FreeBooksWidget extends StatelessWidget {
  const FreeBooksWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AppController>(
      builder: (controller) {
        if (controller.currentUser == null ||
            FirebaseAuth.instance.currentUser == null) {
          return const SizedBox();
        } else {
          return Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              30.height,
              const Text(
                'Free Books',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
              10.height,
              SizedBox(
                height: MediaQuery.sizeOf(context).height * 0.4,
                child: FirestoreListView(
                  scrollDirection: Axis.horizontal,
                  query: FirebaseService.firebaseFirestore
                      .collection(firebaseCoursesCollection)
                      .where('isFreeBook', isEqualTo: true)
                      .where('level', isEqualTo: controller.currentUser!.level)
                      .limit(4)
                      .withConverter(
                        fromFirestore: (snapshot, options) =>
                            CourseModel.fromDocument(snapshot),
                        toFirestore: (value, options) => value.toJson(),
                      ),
                  itemBuilder: (context, doc) {
                    if (doc.exists == false) return const SizedBox();

                    final course = doc.data();

                    // Filter the lecture notes by the lectureRefrence of the course and the id of the lecture note
                    final lectureNote = ProgramsController.instance.lectureNotes
                        .firstWhere(
                            (note) => note.id == course.lectureRefrence);

                    return BookCard(lecture: lectureNote);
                  },
                ),
              ),
            ],
          );
        }
      },
    );
  }
}
