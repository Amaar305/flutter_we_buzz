import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hi_tweet/views/pages/settings/dashboard/issues/bug_view_page.dart';

import '../../../../../model/campus_announcement.dart';
import '../../../../../model/report/bug_report_model.dart';
import '../../../../../services/firebase_constants.dart';
import '../../../../../services/firebase_service.dart';
import '../../../../utils/constants.dart';
import '../../../../widgets/home/animated_annoucement.dart';

class BugReportIssuesPage extends StatelessWidget {
  const BugReportIssuesPage({super.key});

  static const String routeName = '/bug-report-issues-page';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bug report issues')),
      body: Padding(
        padding: kPadding,
        child: FirestoreListView(
          query: FirebaseService.firebaseFirestore
              .collection(firebaseReportBugsCollection)
              .orderBy('createdAt', descending: true)
              .withConverter<ReportBug>(
                fromFirestore: (snapshot, _) =>
                    ReportBug.fromDocumentSnapshot(snapshot),
                toFirestore: (report, _) => report.toMap(),
              ),
          itemBuilder: (context, doc) {
            if (doc.exists == false) return const SizedBox();
            final report = doc.data();
            final annouce = CampusAnnouncement(
                id: report.id,
                content: report.description,
                timestamp: report.createdAt,
                updatedAt: report.createdAt,
                durationInHours: 2,
                createdBy: report.user,
                image: report.imageUrl);

            if (report.imageUrl != null) {
              return BannerAnnouncementWidget(
                announcement: annouce,
                isBug: true,
                onTap: () => Get.to(() => BugViewPage(id: report.id)),
              );
            } else {
              return AnimatedAnnouncementWidget(
                announcement: annouce,
                isBug: true,
                onTap: () => Get.to(() => BugViewPage(id: report.id)),
              );
            }
          },
        ),
      ),
    );
  }
}
