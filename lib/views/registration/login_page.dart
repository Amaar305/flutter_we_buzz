import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../utils/constants.dart';
import '../widgets/home/custom_back_button.dart';
import '../widgets/home/custom_title.dart';
import '../widgets/home/my_buttons.dart';
import '../widgets/home/my_textfield.dart';
import 'forget_password.dart';
import 'login/login_page_controller.dart';
import 'signup_page.dart';

class MyLoginPage extends GetView<LoginController> {
  const MyLoginPage({super.key});
  static const routeName = '/login';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: kPadding,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CustomBackButton(),
                const SizedBox(height: 30),
                Form(
                  key: controller.formKey,
                  child: Center(
                    child: Column(
                      children: [
                        // Logo
                        Image.asset(
                          'assets/images/logo.png',
                          width: MediaQuery.sizeOf(context).width * 0.25,
                        ),

                        const SizedBox(height: 15),
                        // Title
                        const RegistrationTitle(title: 'Welcome Back'),
                        const SizedBox(height: 30),

                        // Email Field
                        MyInputField(
                          controller: controller.emailEditingController,
                          label: 'Email Address',
                          hintext: 'Enter email',
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter email';
                            } else if (!controller.hasEmailMatched(value)) {
                              return 'Please enter a valid email address!';
                            }
                            return null;
                          },
                          keyboardType: TextInputType.emailAddress,
                          iconData: Icons.email,
                        ),

                        // Password Field
                        GetBuilder<LoginController>(
                          builder: (_) {
                            return MyInputField(
                              controller: controller.passwordEditingController,
                              label: 'Password',
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

                        // Actions
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                GetBuilder<LoginController>(builder: (_) {
                                  return Checkbox(
                                    value: controller.rememberMe,
                                    onChanged: (value) {
                                      controller.updateRememberMe(value!);
                                    },
                                  );
                                }),
                                const Text('Remember me'),
                              ],
                            ),
                            TextButton(
                              onPressed: () {
                                Get.toNamed(ForgotPasswordPage.routeName);
                              },
                              child: const Text('Forgot password'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Button
                        MyRegistrationButton(
                          title: 'LOGIN',
                          onPressed: () => controller.trySubmit(),
                        ),
                        const SizedBox(height: 30),

                        // Don't have accoun
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('Don\'t have an account?'),
                            TextButton(
                              onPressed: () {
                                Get.toNamed(SignUpPage.routeName);
                              },
                              child: const Text(
                                'sign up',
                                style: TextStyle(
                                  decoration: TextDecoration.underline,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
