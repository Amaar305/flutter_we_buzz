import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import '../pages/dashboard/my_app_controller.dart';
import '../pages/documents/levels/levels_list.dart';
import '../utils/constants.dart';
import '../widgets/home/custom_back_button.dart';
import '../widgets/home/custom_title.dart';
import '../widgets/home/my_buttons.dart';
import '../widgets/home/my_drop_button.dart';
import '../widgets/home/my_textfield.dart';
import 'login_page.dart';
import 'signup/signup_page_controller.dart';

class SignUpPage extends GetView<SignUpController> {
  const SignUpPage({super.key});
  static const routeName = '/sign-up';

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
                        const RegistrationTitle(title: 'Create New Account'),
                        const Text(
                          'Fill Your Details',
                          style: TextStyle(fontSize: 15),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 30),

                        // Email Field
                        MyInputField(
                          controller: controller.nameEditingController,
                          label: 'Full Name',
                          hintext: 'Enter name',
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your name';
                            }
                            if (value.length < 5) {
                              return 'Name must be greather than 5';
                            }

                            if (value.length > 18) {
                              return 'Name must be less than 18 characters';
                            }
                            return null;
                          },
                          iconData: Icons.person,
                        ),

                        // Email Field
                        MyInputField(
                          controller: controller.emailEditingController,
                          label: 'Email',
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
                        GetBuilder<SignUpController>(
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

                        MyDropDownButtonForm(
                          items: AppController.instance.programs
                              .map((p) => p.programName)
                              .toList(),
                          label: 'Program',
                          hintext: 'Select Program',
                          onChanged: controller.setProgramName,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please select your program of study';
                            }
                            return null;
                          },
                        ),
                        MyDropDownButtonForm(
                          icon: FontAwesomeIcons.userGraduate,
                          items: levels,
                          label: 'Level',
                          hintext: 'Select Level',
                          onChanged: controller.setCurrentLevel,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please select your current level';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 20),

                        // Button
                        MyRegistrationButton(
                          secondaryColor: Colors.white,
                          toUpperCase: false,
                          title: 'SIGN UP',
                          onPressed: () => controller.trySubmit(),
                        ),
                        const SizedBox(height: 30),

                        // Don't have accoun
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('Already have an account?'),
                            TextButton(
                              onPressed: () =>
                                  Get.toNamed(MyLoginPage.routeName),
                              child: const Text(
                                'Log In',
                                style: TextStyle(
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




/*



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
                      'Sign up to Webuzz',
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
                          obscureText: cont.obscureText,
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


*/ 