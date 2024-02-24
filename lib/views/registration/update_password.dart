import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hi_tweet/views/utils/constants.dart';
import 'package:lottie/lottie.dart';

import '../../controllers/update_password_controller.dart';
import '../widgets/home/my_buttons.dart';
import '../widgets/home/my_textfield.dart';

class UpdatePasswordPage extends GetView<UpdatePasswordController> {
  const UpdatePasswordPage({super.key});
  static const String routeName = '/update-pass-page';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: kPadding,
        child: Center(
          child: SingleChildScrollView(
            child: Form(
              key: controller.formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Lottie.asset('assets/lottie/1.json'),
                  const Text(
                    'You can only change your password each after two weeks.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 17),
                  ),
                  GetBuilder<UpdatePasswordController>(
                    builder: (_) {
                      return MyInputField(
                        controller: controller.currentPassEditingController,
                        label: 'Current password',
                        hintext: 'Enter Password',
                        iconData: Icons.lock,
                        obscureText: controller.obscureText,
                        validator: (value) {
                          if (value == null || value.isEmail) {
                            return 'Please enter password';
                          } else if (value.length < 7) {
                            return 'Password must be at least 7 characters!';
                          }
                          return null;
                        },
                        onTap: () {
                          controller.canOrCannotSee();
                        },
                      );
                    },
                  ),
                  GetBuilder<UpdatePasswordController>(
                    builder: (_) {
                      return MyInputField(
                        controller: controller.newPassEditingController,
                        label: 'New password',
                        hintext: 'Enter Password',
                        iconData: Icons.lock,
                        obscureText: controller.obscureText,
                        validator: (value) {
                          if (value == null || value.isEmail) {
                            return 'Please enter password';
                          } else if (value.length < 7) {
                            return 'Password must be at least 7 characters!';
                          }
                          return null;
                        },
                        onTap: () {
                          controller.canOrCannotSee();
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                  MyRegistrationButton(
                    title: 'Change Password',
                    secondaryColor: Colors.white,
                    toUpperCase: false,
                    onPressed: () {
                      controller.change(context);
                    },
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
