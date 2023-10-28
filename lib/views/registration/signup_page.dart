import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hi_tweet/views/utils/constants.dart';

import '../pages/dashboard/dashboard_controller.dart';
import '../widgets/home/my_button.dart';
import '../widgets/home/my_textfield.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});
  static const routeName = '/sign-up';

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final controller = AppController.instance;

  final _formKey = GlobalKey<FormState>();

  final RegExp emailValidation = RegExp(
      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
  void _trySubmit() {
    final isValid = _formKey.currentState!.validate();
    FocusScope.of(context).unfocus();

    if (isValid) {
      _formKey.currentState!.save();
      controller.registration(1);
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
                      'Sign up to Hi, Tweet',
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
                    MyTextField(
                      controller: controller.nameEditingController,
                      hintext: 'name',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your name';
                        } else if (value.length > 20 || value.length < 10) {
                          return 'Name should not be > 20 characters and < 10 characters!';
                        }
                        return null;
                      },
                      keyboardType: TextInputType.text,
                    ),
                    GetBuilder<AppController>(
                      builder: (cont) {
                        return MyTextField(
                          controller: controller.passwordEditingController,
                          hintext: 'password',
                          obscure: cont.obscureText,
                          validator: (value) {
                            if (value == null || value.isEmail) {
                              return 'Please enter password';
                            } else if (value.length < 7) {
                              return 'Password must be at least 7 characters!';
                            }
                            return null;
                          },
                          onTap: () => cont.canOrCannotSee(),
                        );
                      },
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    MyButton(
                      text: 'Sign Up',
                      onPressed: () => _trySubmit(),
                    ),
                    TextButton(
                      onPressed: () {
                        controller.clearTextControllers();
                        Get.back();
                      },
                      child: const Text('Already have an account? Log in'),
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
