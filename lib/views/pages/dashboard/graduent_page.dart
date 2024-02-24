import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../utils/constants.dart';
import '../../widgets/home/my_buttons.dart';
import 'graduent_controller.dart';

class GraduantPage extends GetView<GraduentController> {
  const GraduantPage({super.key});
  static const String routeName = '/graduant-page';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: kPadding,
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  height: MediaQuery.sizeOf(context).height * 0.2,
                  child: Image.asset(
                    'assets/images/grad.png',
                    fit: BoxFit.fitHeight,
                  ),
                ),
                25.height,
                const Text(
                  'Not Undergraduate!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                10.height,
                const Text(
                  "You are not an undergraduate student, therefore, you are required to pay 5000 naira to utilize Webuzz.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                  ),
                ),
                20.height,
                Obx(
                  () {
                    if (controller.hasPaid.isTrue) return const SizedBox();
                    return MyRegistrationButton(
                      primaryColor: kPrimary,
                      secondaryColor: kblack,
                      title: 'Pay Now',
                      onPressed: () => controller.pay(context),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
