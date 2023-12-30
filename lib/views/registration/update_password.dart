import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/update_password_controller.dart';
import '../widgets/home/my_button.dart';
import '../widgets/home/my_textfield.dart';

class UpdatePasswordPage extends GetView<UpdatePasswordController> {
  const UpdatePasswordPage({super.key});
  static const String routeName = '/update-pass-page';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: SingleChildScrollView(
          child: Form(
            key: controller.formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 25.0),
                  child: Text(
                    'You can only change your password each after two weeks.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 20),
                  ),
                ),
                GetBuilder<UpdatePasswordController>(
                  builder: (_) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25.0),
                      child: MyTextField(
                        controller: controller.currentPassEditingController,
                        hintext: 'Current Password',
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
                      ),
                    );
                  },
                ),
                GetBuilder<UpdatePasswordController>(
                  builder: (_) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25.0),
                      child: MyTextField(
                        controller: controller.newPassEditingController,
                        hintext: 'New Password',
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
                      ),
                    );
                  },
                ),
                const SizedBox(height: 10),
                MyButton(
                  text: 'Change Password',
                  onPressed: () {
                    controller.change(context);
                  },
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
