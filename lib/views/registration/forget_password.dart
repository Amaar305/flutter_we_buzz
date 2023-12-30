import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hi_tweet/views/widgets/home/my_button.dart';

import '../../controllers/forgot_password_controller.dart';
import '../widgets/home/my_textfield.dart';

class ForgotPasswordPage extends GetView<ForgotPasswordController> {
  const ForgotPasswordPage({super.key});
  static const String routeName = '/forgot-pass-page';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 25.0),
            child: Text(
              'Enter your email and we\'ll send you a password reset link',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: MyTextField(
              controller: controller.textEditingController,
              hintext: 'Email',
              keyboardType: TextInputType.emailAddress,
            ),
          ),
          const SizedBox(height: 10),
          MyButton(
            text: 'Reset Password',
            onPressed: () {
              if (controller.textEditingController.text.isNotEmpty) {
                controller.passwordReset();
              }
            },
          )
        ],
      ),
    );
  }
}
