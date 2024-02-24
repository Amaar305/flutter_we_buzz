import 'package:flutter/material.dart';

class SponsorIndecator extends StatelessWidget {
  const SponsorIndecator({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // String userId = FirebaseAuth.instance.currentUser == null
        //     ? ''
        //     : FirebaseAuth.instance.currentUser!.uid;
        // final currentUser = AppController.instance.weBuzzUsers
        //     .firstWhere((user) => user.userId == userId);
        // currentUser.sponsor
        //     ? Get.toNamed(SponsorPage.routeName)
        //     : Get.toNamed(SponsorAgreementPage.routeName);
      },
      child: const Row(
        children: [
          Text(
            'Sponsored',
            style: TextStyle(
              fontStyle: FontStyle.italic,
              fontSize: 12,
            ),
          ),
          SizedBox(width: 5),
          Icon(
            Icons.info,
            size: 15,
          )
        ],
      ),
    );
  }
}
