import 'package:flutter/material.dart';

import '../../../../model/we_buzz_model.dart';
import 'component/card_actions.dart';
import 'component/card_image.dart';
import 'component/card_top_actions.dart';
import 'component/card_user_info.dart';
import 'component/style_text.dart';

class ReusableCard extends StatelessWidget {
  const ReusableCard({
    Key? key,
    required this.normalWebuzz,
    this.snapShotWebuzz,
    this.isReport = false,
    this.originalId,
  }) : super(key: key);
  final WeBuzz normalWebuzz;
  final WeBuzz? snapShotWebuzz;
  final bool isReport;
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

            const SizedBox(height: 10),
            StylizedPostContent(content: normalWebuzz.content),
            if (normalWebuzz.imageUrl != null &&
                normalWebuzz.imageUrl!.isNotEmpty)
              CardImage(normalWebuzz: normalWebuzz),
            const SizedBox(height: 10),
            // const SizedBox(height: 10),
            // BuzzDate(normalWebuzz: normalWebuzz),
            // for hiding action buttons in the reply section
            if (isReport)
              Text(
                'Report Count ${normalWebuzz.reportCount}',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              )
            else if (snapShotWebuzz != null)
              const SizedBox()
            else
              ActionButtons(
                currentUser: currentUser,
                normalWebuzz: normalWebuzz,
              )
          ],
        ),
      ),
    );
  }
}
