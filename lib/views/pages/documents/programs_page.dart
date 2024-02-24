import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../utils/constants.dart';
import '../../widgets/home/custom_tab_bar.dart';
import '../dashboard/my_app_controller.dart';
import 'components/bookmark_section.dart';
import 'components/explore_section.dart';
import 'components/for_you_section.dart';
import 'programs_controller.dart';

class ProgramsPage extends GetView<ProgramsController> {
  const ProgramsPage({super.key});
  static const String routeName = '/courses-page';

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: controller.tabTitles.length,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Programmes',
            style: GoogleFonts.pacifico(
              textStyle: const TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          actions: [
            GetX<AppController>(
              builder: (control) {
                if (FirebaseAuth.instance.currentUser != null) {
                  final currentLoggedInUser = control.weBuzzUsers.firstWhere(
                      (user) =>
                          user.userId ==
                          FirebaseAuth.instance.currentUser!.uid);

                  if (currentLoggedInUser.isStaff) {
                    return IconButton(
                      tooltip: 'upload file',
                      onPressed: () {
                        controller.showAlertDialog(currentLoggedInUser.userId);
                      },
                      icon: const Icon(Icons.add),
                    );
                  } else {
                    return const SizedBox();
                  }
                } else {
                  return const SizedBox();
                }
              },
            )
          ],
        ),
        body: Padding(
          padding: kPadding,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTabBar(list: controller.tabTitles),
              CustomTabBarView(
                children: [
                  const ForYouSection(),
                  ExploreSection(controller: controller),
                  const BookmarkSection(),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}



/*

SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Continue reading',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
              10.height,
              const ContinueReadingWidget(showButton: true),
              30.height,
              const Text(
                'Information Technology',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
              10.height,
              SizedBox(
                height: MediaQuery.sizeOf(context).height * 0.4,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 4,
                  itemBuilder: (context, index) {
                    return const BookCard();
                  },
                ),
              ),
             
            ],
          ),
        )
*/ 


/*

Padding(
              padding: kPadding,
              child: GetX<AppController>(
                builder: (control) {
                  return GridView.builder(
                    controller: controller.scrollController,
                    itemCount: control.programs.length,
                    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 200,
                      childAspectRatio: 1,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemBuilder: (context, index) {
                      final progam = control.programs[index];
                      return ProgramGrid(
                        title: progam.programName,
                        onTap: () {
                          Get.to(
                            () => LevelPage(
                              programName: progam.programName,
                              programId: progam.programId,
                              faculty: progam.faculty,
                            ),
                          );
                          // WeBuzz selectedAd = controller.getRandomAdvert();
                          // int guess = controller.nextNumber(20);
    
                          if (guess % 2 == 0) {
                            toast('Ad for 15 seconds');
                            Get.to(
                              () => AdvertPage(
                                advert: selectedAd,
                                navigaToPage: () => Get.off(
                                  () => LevelPage(
                                    programName: progam.programName,
                                    programId: progam.programId,
                                  ),
                                ),
                              ),
                            );
                          } else {
                            Get.to(
                              () => LevelPage(
                                programName: progam.programName,
                                programId: progam.programId,
                              ),
                            );
                          }
                        },
                      );
                    },
                  );
                },
              ),
            )
*/ 