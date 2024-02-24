import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:full_screen_image/full_screen_image.dart';

import 'package:nb_utils/nb_utils.dart';

import '../../../../../model/report/bug_report_model.dart';
import '../../../../../model/we_buzz_user_model.dart';
import '../../../../../services/firebase_constants.dart';
import '../../../../../services/firebase_service.dart';
import '../../../../utils/constants.dart';
import '../../../../utils/method_utils.dart';

class BugViewPage extends StatelessWidget {
  const BugViewPage({super.key, required this.id});
  final String id;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bug view page')),

      // Action button for marking bug review as completed
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Implement onPress for marking bug review as complete
        },
        child: const Icon(Icons.done_all_outlined),
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding: kPadding,
          child: StreamBuilder<ReportBug>(
            stream: FirebaseService.firebaseFirestore
                .collection(firebaseReportBugsCollection)
                .doc(id)
                .snapshots()
                .map((event) => ReportBug.fromDocumentSnapshot(event)),
            builder: (context, snapshot) {
              if (!snapshot.hasData || snapshot.hasError) {
                return const Center(child: CircularProgressIndicator());
              }

              final report = snapshot.data;
              if (report == null) return const SizedBox();
              return Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (report.imageUrl != null)
                    // Bug image if not null show
                    SizedBox(
                      width: double.infinity,
                      height: MediaQuery.sizeOf(context).height * 0.25,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: FullScreenWidget(
                          disposeLevel: DisposeLevel.Medium,
                          child: Image(
                            image: CachedNetworkImageProvider(report.imageUrl!),
                            fit: BoxFit.fitWidth,
                          ),
                        ),
                      ),
                    ),
                  20.height,
                  const Text(
                    'Bug issues',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    report.description,
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  20.height,
                  const Text(
                    'Reporter',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  FutureBuilder<WeBuzzUser?>(
                    future: FirebaseService.userByID(report.user),
                    builder: (context, snapshot) {
                      if (snapshot.hasError ||
                          !snapshot.hasData ||
                          snapshot.data == null) {
                        return const Text(
                          'loading..',
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        );
                      }
                      return Text(
                        snapshot.data!.name,
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                      );
                    },
                  ),
                  20.height,
                  const Text(
                    'Reported At',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    MethodUtils.formatDateWithMonthAndDay(report.createdAt),
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  )
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
