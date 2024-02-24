import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';


import '../utils/constants.dart';
import '../widgets/home/custom_title.dart';
import '../widgets/home/my_buttons.dart';
import 'login_page.dart';
import 'signup_page.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});
  static const routeName = '/welcome-page';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            height: MediaQuery.sizeOf(context).height * 0.56,
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Colors.black45,
              image: DecorationImage(
                image: AssetImage('assets/images/ymsu.jpg'),
                fit: BoxFit.fitHeight,
                opacity: 0.5,
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  Text(
                    'Webuzz',
                    style: GoogleFonts.pacifico(
                      textStyle: const TextStyle(
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: MediaQuery.sizeOf(context).height * 0.47,
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              decoration: const BoxDecoration(
                color: Color.fromARGB(255, 250, 248, 230),
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
              child: _use(),
            ),
          ),
        ],
      ),
    );
  }
}

Widget _use() => SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 2),
          const RegistrationTitle(
            title: 'Welcome to Webuzz! 🐝',
            fontColor: Colors.black,
            fontSize: 20,
          ),
          const SizedBox(height: 2),
          Text(
            "Embark on academic excellence with news updates, lecture notes, and past questions mastery - your ultimate guide is here!",
            style: GoogleFonts.openSans(
              fontSize: 14,
              color: Colors.black,
            ),
            textAlign: TextAlign.start,
          ),
          const SizedBox(height: 30),
          MyRegistrationButton(
            toUpperCase: false,
            title: 'Login',
            primaryColor: kPrimary,
            secondaryColor: Colors.white,
            onPressed: () => Get.toNamed(MyLoginPage.routeName),
          ),
          const SizedBox(
            height: 20,
          ),
          MyRegistrationButton(
            toUpperCase: false,
            title: 'Create account',
            secondaryColor: Colors.white,
            onPressed: () => Get.toNamed(SignUpPage.routeName),
          ),
        ],
      ),
    );
