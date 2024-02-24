import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hi_tweet/views/utils/constants.dart';
import 'package:hi_tweet/views/widgets/home/my_buttons.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../controllers/verify_user_controller.dart';

class VerifyUserPage extends GetView<VerifyUserController> {
  const VerifyUserPage({super.key});
  static const String routeName = '/verify-user-page';

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: kPadding.copyWith(left: 20, right: 20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '🌟Premium Features',
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                20.height,
                const Text(
                  'Unlock Premium Features Today!',
                  style: TextStyle(
                    fontSize: 22.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                20.height,
                const PremiumFeatureItem(
                  title: 'Chat Images with BuzzBot🐝',
                  description:
                      'Seamlessly communicate with our AI through image inputs for instant assistance and personalized responses.',
                ),
                const PremiumFeatureItem(
                  title: 'Ad-Free Lecture Notes 📔',
                  description:
                      'Dive into your study materials without interruptions. Say goodbye to pesky ads while reading lecture notes.',
                ),
                const PremiumFeatureItem(
                  title: 'Ad-Free Past Questions 📑',
                  description:
                      'Prepare for exams hassle-free. Access past questions without the distraction of advertisements.',
                ),
                const PremiumFeatureItem(
                  title: 'Verification Badge 🌟',
                  description:
                      'Stand out as a verified user with a special badge displayed on your profile and any content you create. Build credibility and trust within our community.',
                ),
                const PremiumFeatureItem(
                  title: 'Access to Great Features 🎁',
                  description:
                      'Explore a world of possibilities with our premium features designed to enhance your user experience.',
                ),
                10.height,
                const Text(
                  'One-time Payment: 2000 naira only!',
                  style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                ),
                20.height,
                Obx(() {
                  if (controller.hasPaid.isTrue) return const SizedBox();
                  return MyRegistrationButton(
                    title: 'Try Today!',
                    secondaryColor: kblack,
                    primaryColor: kPrimary,
                    onPressed: () {
                      controller.verifyMe(context);
                    },
                    toUpperCase: false,
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class PremiumFeatureItem extends StatelessWidget {
  final String title;
  final String description;

  const PremiumFeatureItem({
    super.key,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8.0),
        Text(description),
        const SizedBox(height: 20.0),
      ],
    );
  }
}
