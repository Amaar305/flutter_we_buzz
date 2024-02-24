import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
import 'package:flutter/material.dart';

import '../../pages/home/home_controller.dart';
import '../../shimmer/home_page_shimmer.dart';
import 'cards/reusable_card.dart';
import 'cards/sponsor_card_widget.dart';
import 'custom_carousel_announcement_builder.dart';

class ExploreBuzz extends StatelessWidget {
  const ExploreBuzz({
    super.key,
    required this.controller,
  });

  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    return FirestoreQueryBuilder(
      query: controller.queryBuzz,
      pageSize: 10,
      builder: (context, snapshot, _) {
        if (snapshot.isFetching) {
          return const HomePageShimmer();
        } else if (snapshot.hasError) {
          return Text('Something went wrong! ${snapshot.error}');
        } else {
          return ListView.builder(
            controller: controller.exploreScrollController,
            itemCount: snapshot.docs.length + 1,
            itemBuilder: (context, index) {
              final hasEnd = snapshot.hasMore &&
                  index == snapshot.docs.length &&
                  !snapshot.isFetchingMore;

              if (hasEnd) snapshot.fetchMore();
              if (index == 0) {
                return const CustomCarouselAnnouncementBuilderWidget();
              }

              final buzz = snapshot.docs[index - 1].data();

              if (!buzz.isPublished) return const SizedBox();

              if (buzz.validSponsor()) {
                return SponsorCard(normalWebuzz: buzz);
              }

              if (!buzz.isSponsor) {
                if (controller.currentUser().blockedUsers
                    .contains(buzz.authorId)) {
                  return const SizedBox();
                } else {
                  return ReusableCard(normalWebuzz: buzz);
                }
              }
              return null;
            },
          );
        }
      },
    );
  }
}
