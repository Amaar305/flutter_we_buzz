import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hi_tweet/views/utils/constants.dart';
import 'package:hi_tweet/views/widgets/home/my_buttons.dart';
import 'package:lottie/lottie.dart';

import '../../controllers/forgot_password_controller.dart';
import '../widgets/home/my_textfield.dart';

class ForgotPasswordPage extends GetView<ForgotPasswordController> {
  const ForgotPasswordPage({super.key});
  static const String routeName = '/forgot-pass-page';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: kPadding,
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Lottie.asset('assets/lottie/1.json'),
              const Text(
                'Enter your email and we\'ll send you a password reset link',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 17),
              ),
              MyInputField(
                controller: controller.textEditingController,
                hintext: 'Email',
                keyboardType: TextInputType.emailAddress,
                iconData: Icons.email,
                label: 'Enter your email',
              ),
              const SizedBox(height: 10),
              MyRegistrationButton(
                toUpperCase: false,
                secondaryColor: Colors.white,
                title: 'Reset',
                onPressed: () {
                  if (controller.textEditingController.text.isNotEmpty) {
                    controller.passwordReset();
                  }
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
