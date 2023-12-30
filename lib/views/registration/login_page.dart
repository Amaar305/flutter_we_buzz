import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../pages/dashboard/my_app_controller.dart';
import '../utils/constants.dart';
import '../widgets/home/my_button.dart';
import '../widgets/home/my_textfield.dart';
import 'forget_password.dart';
import 'signup_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  static const routeName = '/login';

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final controller = AppController.instance;

  final _formKey = GlobalKey<FormState>();

  final RegExp emailValidation = RegExp(
      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
  void _trySubmit() {
    final isValid = _formKey.currentState!.validate();
    FocusScope.of(context).unfocus();

    if (isValid) {
      _formKey.currentState!.save();
      controller.registration(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: kDefaultAppPadding,
        child: Form(
          key: _formKey,
          child: Center(
            child: SingleChildScrollView(
              child: Container(
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Log in to Webuzz',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    MyTextField(
                      controller: controller.emailEditingController,
                      hintext: 'email',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter email';
                        } else if (!emailValidation.hasMatch(value)) {
                          return 'Please enter a valid email address!';
                        }
                        return null;
                      },
                      keyboardType: TextInputType.emailAddress,
                    ),
                    GetBuilder<AppController>(
                      builder: (_) {
                        return MyTextField(
                          controller: controller.passwordEditingController,
                          hintext: 'password',
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {
                            Get.toNamed(ForgotPasswordPage.routeName);
                          },
                          child: const Text('Forgot password'),
                        ),
                      ],
                    ),
                    MyButton(
                      text: 'Log In',
                      onPressed: () => _trySubmit(),
                    ),
                    TextButton(
                      onPressed: () {
                        controller.clearTextControllers();
                        Get.toNamed(SignUpPage.routeName);
                      },
                      child: const Text('Don\'t have an account? Sign up here'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
