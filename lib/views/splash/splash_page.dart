import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';


class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});
  static const routeName = '/splash-page';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Theme.of(context).colorScheme.primary,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(),

              Image.asset(
                'assets/images/logo.png',
                width: MediaQuery.sizeOf(context).width * 0.25,
              ),

              const SizedBox(height: 15),
              // Title
              Text(
                'Webuzz',
                style: GoogleFonts.pacifico(
                  textStyle: const TextStyle(
                    fontSize: 25.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const Spacer(),
              const CircularProgressIndicator(
                strokeWidth: BorderSide.strokeAlignCenter,
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
