import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../pages/home/home_controller.dart';
import '../../utils/constants.dart';

class AnimatedAnnouncementWidget extends StatelessWidget {
  const AnimatedAnnouncementWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      builder: (controller) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 16),
          height: MediaQuery.of(context).size.height * 0.2,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14.0),
            gradient: LinearGradient(
              colors: [
                kPrimary,
                Colors.deepOrange.shade200,
                kPrimary.withOpacity(0.8),
              ],
              transform: GradientRotation(controller.rotate),
              stops: const [
                0.0,
                0.33,
                0.66,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Announcement!',
                  style: GoogleFonts.pacifico(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5.0),
                const Text(
                  'Hello everyone tomorrow we\'re gonna start voting for our lovely particepants, which are Sir. USB and Sir. Muhammad Zawwali parki.',
                  style: TextStyle(
                    fontSize: 15,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 2),
                InkWell(
                  onTap: () {},
                  child: const Text(
                    'Visit',
                    style: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
