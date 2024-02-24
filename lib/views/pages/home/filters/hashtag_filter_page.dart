import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../utils/constants.dart';
import '../../../widgets/home/cards/reusable_card.dart';
import '../../../widgets/home/cards/sponsor_card_widget.dart';
import 'hashtag_filter_controller.dart';

class HashTagFilterPage extends GetView<HashTagFilterController> {
  final String hashtag;
  const HashTagFilterPage({super.key, required this.hashtag});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          hashtag,
          style: const TextStyle(fontSize: 25),
        ),
      ),
      body: Padding(
        padding: kPadding,
        child: _webuzzList(),
      ),
    );
  }

  Widget _webuzzList() {
    return FirestoreListView(
      query: controller.getFilterPosts(hashtag),
      itemBuilder: (context, doc) {
        final buzz = doc.data();

        if (buzz.isSuspended || !buzz.isPublished) return const SizedBox();
        if (controller.currentUser == null) return const SizedBox();

        if (buzz.validSponsor()) {
          return SponsorCard(
            normalWebuzz: buzz,
          );
        }

        if (!buzz.isSponsor) {
          if (controller.currentUser!.blockedUsers.contains(buzz.authorId)) {
            return const SizedBox();
          } else {
            return ReusableCard(
              normalWebuzz: buzz,
            );
          }
        }

        return const SizedBox();
      },
    );
  }
}
