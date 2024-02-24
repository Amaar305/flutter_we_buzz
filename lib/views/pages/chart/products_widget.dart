import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
import 'package:flutter/material.dart';

import '../../../model/we_buzz_model.dart';
import '../../../services/firebase_constants.dart';
import '../../../services/firebase_service.dart';
import '../../widgets/home/cards/sponsor_card_widget.dart';

class MyProducts extends StatelessWidget {
  const MyProducts({
    super.key,
    required this.productType,
  });

  final ProductType productType;

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    return FirestoreListView(
      query: FirebaseService.firebaseFirestore
          .collection(firebaseWeBuzzCollection)
          .where('authorId', isEqualTo: userId)
          .where('isSuspended', isEqualTo: false)
          .where('isPublished', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .withConverter(
            fromFirestore: (snapshot, options) => WeBuzz.fromJson(
              snapshot.data()!,
              snapshot.id,
              snapshot.reference,
            ),
            toFirestore: (buzz, options) => buzz.toJson(),
          ),
      itemBuilder: (context, doc) {
        final buzz = doc.data();

        switch (productType) {
          case ProductType.ongoing:
            if (buzz.validSponsor()) {
              return SponsorCard(
                normalWebuzz: buzz,
                chart: true,
              );
            }
            {}
            break;
          case ProductType.expired:
            if (buzz.isSponsor && buzz.expired) {
              return SponsorCard(
                normalWebuzz: buzz,
                chart: true,
              );
            }
            break;
          case ProductType.notPaid:
            if (buzz.isSponsor && !buzz.hasPaid) {
              return SponsorCard(
                normalWebuzz: buzz,
                chart: true,
              );
            }
            break;
          default:
            return const SizedBox();
        }

        return const SizedBox();
      },
    );
  }
}

/*
ListView.builder(
          itemCount: sponsors.length,
          itemBuilder: (context, index) {
            final sponsor = sponsors[index];
            return SponsorCard(normalWebuzz: sponsor, chart: true);
          },
        )
*/

enum ProductType {
  ongoing,
  expired,
  notPaid,
  chart,
}
