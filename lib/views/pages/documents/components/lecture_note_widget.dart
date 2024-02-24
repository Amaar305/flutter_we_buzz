import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:nb_utils/nb_utils.dart';

import '../courses/courses_controller.dart';
import '../programs_controller.dart';
import 'book_card_widget.dart';

class LectureNotesWidget extends StatelessWidget {
  const LectureNotesWidget({
    super.key,
    required this.controller,
    required this.programId,
    required this.level,
  });

  final CoursesController controller;
  final String programId;
  final String level;

  @override
  Widget build(BuildContext context) {
    return FirestoreQueryBuilder(
      query: controller.queryCourse(programId, level),
      builder: (context, snapshot, _) {
        if (snapshot.isFetching) {
          return const CircularProgressIndicator().center();
        } else if (snapshot.hasError) {
          return Text('Something went wrong! ${snapshot.error}');
        } else {
          return MasonryGridView.builder(
            itemCount: snapshot.docs.length,
            gridDelegate: const SliverSimpleGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
            ),
            itemBuilder: (context, index) {
              final hasEnd = snapshot.hasMore &&
                  index == snapshot.docs.length &&
                  !snapshot.isFetchingMore;

              if (hasEnd) snapshot.fetchMore();
              if (snapshot.docs[index].exists == false) return const SizedBox();

              final course = snapshot.docs[index].data();

              if (course.pastQ) return const SizedBox();

              try {
                final lecture = ProgramsController.instance.lectureNotes
                    .firstWhere(
                        (element) => element.id == course.lectureRefrence);
                return Container(
                  margin: const EdgeInsets.only(top: 10),
                  child: BookCard(lecture: lecture),
                );
              } catch (e) {
                log('Error trying get the lecture note by id and reference');
                log(e);
                return const SizedBox();
              }
            },
          );
        }
      },
    );
  }
}



/*


FirestoreListView(
      query: controller.queryCourse(programId, level),
      itemBuilder: (context, doc) {
        if (doc.exists == false) return const SizedBox();
        final course = doc.data();

        if (course.pastQ) return const SizedBox();

        final lectureUrl = ProgramsController.instance.lectureNotes
            .firstWhere((element) => element.id == course.lectureRefrence)
            .url;

        return CoursesTile(
          title: course.courseName,
          url: lectureUrl,
          onTap: () {
            final lectureNote = ProgramsController.instance.lectureNotes
                .firstWhere((element) => element.id == course.lectureRefrence);
            Get.to(
              () => DocumentView(
                url: lectureNote.url,
                title: course.courseName,
              ),
            );

            AppController.instance.updateLastBook(lectureNote.id);
          },
          onLongPress: () => controller.alert(course),
        );
      },
    )

*/ 


// MasonryGridView.builder(
//               itemCount: bookzs.length,
//               gridDelegate:
//                   const SliverSimpleGridDelegateWithFixedCrossAxisCount(
//                 crossAxisCount: 2,
//               ),
//               itemBuilder: (context, index) {
//                 return Container(
//                   margin: const EdgeInsets.only(bottom: 10),
//                   child: BookCard(
                    
//                     bookz: bookzs[index],
//                   ),
//                 );
//               },
            