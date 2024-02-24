import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
import 'package:flutter/material.dart';

import '../../../model/we_buzz_model.dart';
import '../../../services/firebase_constants.dart';
import '../../../services/firebase_service.dart';
import '../../utils/constants.dart';
import '../home/cards/reusable_card.dart';
import '../home/cards/sponsor_card_widget.dart';

class BuzzSectionWidget extends StatelessWidget {
  const BuzzSectionWidget({
    super.key,
    this.isDraft = false,
    required this.userId,
  });
  final String userId;
  final bool isDraft;
  @override
  Widget build(BuildContext context) {
    final queryBuzz = FirebaseService.firebaseFirestore
        .collection(firebaseWeBuzzCollection)
        .where('authorId', isEqualTo: userId)
        .where('isSuspended', isEqualTo: false)
        .where('isPublished', isEqualTo: isDraft ? false : true)
        .orderBy('createdAt', descending: true)
        .withConverter(
          fromFirestore: (snapshot, options) => WeBuzz.fromJson(
            snapshot.data()!,
            snapshot.id,
            snapshot.reference,
          ),
          toFirestore: (buzz, options) => buzz.toJson(),
        );
    return Padding(
      padding: kPadding,
      child: FirestoreListView(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        query: queryBuzz,
        itemBuilder: (context, doc) {
          final myPost = doc.data();

          if (myPost.validSponsor()) {
            return SponsorCard(
              normalWebuzz: myPost,
            );
          }

          if (!myPost.isSponsor) {
            return ReusableCard(
              normalWebuzz: myPost,
            );
          }
          return const SizedBox();
        },
      ),
    );
  }
}


/*
Obx(
        () {
          final myPost = buzzController.weeBuzzItems.where((buzz) {
            if (isDraft) {
              return buzz.authorId == userId && !buzz.isPublished;
            } else {
              return buzz.authorId == userId && buzz.isPublished;
            }
          }).toList();
          return myPost.isNotEmpty
              ? ListView.builder(
                  scrollDirection: Axis.vertical,
                  itemCount: myPost.length,
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    if (myPost[index].validSponsor()) {
                      return SponsorCard(
                        normalWebuzz: myPost[index],
                      );
                    }

                    if (!myPost[index].isSponsor) {
                      return ReusableCard(
                        normalWebuzz: myPost[index],
                      );
                    }
                    return null;
                  },
                )
              : const NoBuzzPage(title: 'No Buzz Yet!');
        },
      )
*/ 
