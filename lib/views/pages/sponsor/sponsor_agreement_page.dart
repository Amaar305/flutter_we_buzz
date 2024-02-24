import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hi_tweet/services/firebase_service.dart';
import 'package:hi_tweet/views/utils/constants.dart';
import 'package:nb_utils/nb_utils.dart';

class SponsorAgreementPage extends StatelessWidget {
  const SponsorAgreementPage({super.key});
  static const routeName = '/sposor-agree-page';

  @override
  Widget build(BuildContext context) {
    void showCongratulationsDialog() {
      showDialog(
        barrierDismissible: false,
        barrierColor: kPrimary.withOpacity(0.03),
        useSafeArea: true,
        context: context,
        builder: (BuildContext context) {
          return WillPopScope(
            onWillPop: () => Future.value(false),
            child: AlertDialog(
              title: const Text('Congratulations!'),
              content: const Text(
                  'You have successfully become a sponsor on Webuzz. Welcome to our community!'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Close the dialog
                    Navigator.pop(context); // Close the dialog
                  },
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Webuzz Sponsor Agreement'),
      ),
      body: SingleChildScrollView(
        padding: kPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Introduction:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Greetings and welcome to Webuzz! We appreciate your interest in becoming a sponsor and utilizing our platform to showcase your products. Before you embark on this exciting journey, please take a moment to read and agree to the terms outlined below.',
            ),
            const SizedBox(height: 16),
            const Text(
              'Agreement Text:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              '1. Commitment to Quality:\nBy agreeing to become a sponsor on Webuzz, you pledge to uphold the highest standards of product quality, service, and ethical business practices. We believe in fostering a community of excellence, and your commitment to delivering exceptional products is crucial.\n\n'
              '2. Weekly Subscription Fee:\nIn order to maintain your sponsorship and the visibility of your products on our platform, a weekly subscription fee of 500 naira will be charged. This fee ensures continuous access to our dynamic user base and marketing tools that enhance your brand presence.\n\n'
              '3. Payment Authorization:\nYou hereby authorize Webuzz to automatically deduct the weekly subscription fee from the provided payment method. It is your responsibility to ensure that the payment details are up-to-date and valid.\n\n'
              '4. Duration of Agreement:\nThis agreement is valid on a week-to-week basis. You have the flexibility to terminate the sponsorship at any time, provided a notice is given before the start of the next billing cycle.\n\n'
              '5. Code of Conduct:\nAs a sponsor, you agree to adhere to our community guidelines and ethical standards. Any breach of these guidelines may result in the termination of your sponsorship without refund.\n\n'
              '6. Confidentiality:\nInformation shared on the Webuzz platform, including user data and business insights, is strictly confidential. You agree not to disclose or misuse any confidential information obtained through your sponsorship.',
            ),
            const SizedBox(height: 16),
            const Text(
              'Importance Speech:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Becoming a sponsor on Webuzz is not just a business decision; it\'s an investment in your brand\'s growth and visibility. Our platform is designed to connect you with a diverse audience eager to discover new and innovative products. Your commitment to quality and ethical business practices will undoubtedly elevate your brand in the eyes of our community.\n\n'
              'Remember, success is not just about what you achieve individually, but the positive impact you make on others. By joining Webuzz, you\'re not just promoting products; you\'re becoming part of a community that values excellence, integrity, and collaboration.\n\n'
              'Thank you for choosing Webuzz as your advertising partner. We look forward to a mutually beneficial collaboration, and together, we can create a marketplace that fosters innovation, trust, and success.',
            ),
            32.height,
            const Text('Coming soon!')
            // AppButton(
            //   shapeBorder: RoundedRectangleBorder(
            //     borderRadius: BorderRadius.circular(30),
            //   ),
            //   color: kPrimary,
            //   elevation: 10,
            //   onTap: () async {
            //     String userId = FirebaseAuth.instance.currentUser == null
            //         ? ''
            //         : FirebaseAuth.instance.currentUser!.uid;

            //     try {
            //       await FirebaseService.updateUserData(
            //               {'sponsor': true}, userId)
            //           .then((_) {
            //         showCongratulationsDialog();
            //       });
            //     } catch (e) {
            //       toast('Error trying to update user data');
            //       log(e);
            //     }
            //   },
            //   child: Text(
            //     'I Agree',
            //     style: boldTextStyle(color: kDefaultGrey),
            //   ).center(),
            // )
          ],
        ),
      ),
    );
  }
}
