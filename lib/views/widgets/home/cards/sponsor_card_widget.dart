import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:hi_tweet/services/firebase_service.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../model/we_buzz_model.dart';

import '../../../pages/sponsor/sponsor_page.dart';
import '../../../utils/method_utils.dart';
import 'component/card_actions.dart';
import 'component/card_top_actions.dart';
import 'component/card_user_info.dart';
import 'component/image_slider.dart';
import 'component/sponsor_indecator.dart';
import 'component/style_text.dart';

class SponsorCard extends StatelessWidget {
  const SponsorCard({
    Key? key,
    required this.normalWebuzz,
    this.snapShotWebuzz,
    this.chart = false,
    this.originalId,
  }) : super(key: key);
  final WeBuzz normalWebuzz;
  final WeBuzz? snapShotWebuzz;
  final bool chart;
  final String? originalId;
  @override
  Widget build(BuildContext context) {
    final buzzOwner = getWeBuzzUser(normalWebuzz.authorId);
    final currentUser = getCurrentUser();

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.symmetric(
        // horizontal: 15,
        vertical: 8,
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (normalWebuzz.isRebuzz) ...[
              const Text('Rebuzzed'),
              const SizedBox(height: 10),
            ],

            TopCardHeader(
              buzzOwner: buzzOwner,
              currentUser: currentUser,
              normalWebuzz: normalWebuzz,
              isReply: snapShotWebuzz != null,
              originalId: originalId ?? '',
            ),
            const SponsorIndecator(),
            const SizedBox(height: 10),
            StylizedPostContent(content: normalWebuzz.content),
            const SizedBox(height: 10),
            ImageCarouselSlider(images: normalWebuzz.images!),

            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (normalWebuzz.websiteUrl != null &&
                    normalWebuzz.websiteUrl!.isURL) ...[
                  TextButton(
                    onPressed: () async {
                      try {
                        final websiteUrl = Uri.parse(normalWebuzz.websiteUrl!);

                        launchUrl(
                          websiteUrl,
                          mode: LaunchMode.externalApplication,
                        );

                        final userId = FirebaseAuth.instance.currentUser == null
                            ? ''
                            : FirebaseAuth.instance.currentUser!.uid;

                        SponsorTracker sponsorTracker = SponsorTracker(
                          id: MethodUtils.generatedId,
                          sponsorId: normalWebuzz.id,
                          userId: userId,
                          isWhatsapp: false,
                          createdAt: Timestamp.now(),
                        );

                        await FirebaseService.sponsorTracker(sponsorTracker);
                      } catch (e) {
                        log('Error trying to create a sponsor tracker');
                        log(e);
                      }
                    },
                    child: const Text('Get offer'),
                  ),
                ],
                TextButton.icon(
                  onPressed: () async {
                    try {
                      MethodUtils.openWhatsAppChat(normalWebuzz.whatsapp!);

                      final userId = FirebaseAuth.instance.currentUser == null
                          ? ''
                          : FirebaseAuth.instance.currentUser!.uid;

                      SponsorTracker sponsorTracker = SponsorTracker(
                        id: MethodUtils.generatedId,
                        sponsorId: normalWebuzz.id,
                        userId: userId,
                        isWhatsapp: true,
                        createdAt: Timestamp.now(),
                      );

                      await FirebaseService.sponsorTracker(sponsorTracker);
                    } catch (e) {
                      log('Error trying to create a sponsor tracker');
                      log(e);
                    }
                  },
                  icon: const Icon(FontAwesomeIcons.whatsapp),
                  label: const Text('Whatsapp'),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // BuzzDate(normalWebuzz: normalWebuzz),
            // for hiding action buttons in the reply section
            if (snapShotWebuzz == null && chart == false)
              // hide the action button in reply and sponsor chart page
              ActionButtons(
                currentUser: currentUser,
                normalWebuzz: normalWebuzz,
              )
            else
              // show it in home feed and any other page
              SponsorActionsButton(normalWebuzz: normalWebuzz),
          ],
        ),
      ),
    );
  }
}

class SponsorActionsButton extends StatelessWidget {
  const SponsorActionsButton({
    super.key,
    required this.normalWebuzz,
  });

  final WeBuzz normalWebuzz;

  @override
  Widget build(BuildContext context) {
    DateTime currentDate = DateTime.now();
    DateTime sponsorEndDate = normalWebuzz.createdAt
        .toDate()
        .add(Duration(days: normalWebuzz.duration! * 7));

    double remainingDays =
        sponsorEndDate.difference(currentDate).inDays.toDouble();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (normalWebuzz.expired)
          // if sponsor expired, show expired indicator
          const Text(
            'Expired',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.redAccent,
            ),
          )
        else if (!normalWebuzz.hasPaid)
          // else if sponsor has not paid the buzz, show not pay indicator
          const Text(
            'Yet to pay!',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.redAccent,
            ),
          )
        else
          // else, show the remaining date before expire
          SizedBox(
            width: MediaQuery.sizeOf(context).width * 0.5,
            child: Row(
              children: [
                const Icon(Icons.timelapse_outlined, size: 20),
                5.width,
                Flexible(
                  child: Text(
                    'Remaining: ${remainingDays.round()} days',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        if (normalWebuzz.authorId == FirebaseAuth.instance.currentUser!.uid)
          TextButton.icon(
            onPressed: () => Get.to(() => SponsorPage(sponsor: normalWebuzz)),
            icon: const Icon(Icons.update),
            label: const Text('Update'),
          )
      ],
    );
  }
}
