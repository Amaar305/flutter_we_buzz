import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import '../../dashboard/my_app_controller.dart';
import '../levels/level_page.dart';
import '../programs_controller.dart';
import 'program_card_widget.dart';

class ExploreSection extends StatelessWidget {
  const ExploreSection({
    super.key,
    required this.controller,
  });

  final ProgramsController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        DropdownButton(
          icon: const Icon(Icons.sort),
          underline: Container(),
          items: const [
            DropdownMenuItem(
              value: 'asc',
              child: Row(
                children: [
                  // ignore: deprecated_member_use
                  Icon(FontAwesomeIcons.sortAlphaUp),
                  SizedBox(
                    width: 10,
                  ),
                  Text('Asc')
                ],
              ),
            ),
            DropdownMenuItem(
              value: 'desc',
              child: Row(
                children: [
                  // ignore: deprecated_member_use
                  Icon(FontAwesomeIcons.sortAlphaDesc),
                  SizedBox(
                    width: 10,
                  ),
                  Text('Desc')
                ],
              ),
            ),
          ],
          onChanged: (value) {
            if (value == 'asc') {
              AppController.instance.programs.sort(
                (a, b) => a.programName.compareTo(b.programName),
              );
            } else if (value == 'desc') {
              AppController.instance.programs.sort(
                (a, b) => b.programName.compareTo(a.programName),
              );
            }
          },
        ),
        Expanded(
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

                      // if (guess % 2 == 0) {
                      //   toast('Ad for 15 seconds');
                      //   Get.to(
                      //     () => AdvertPage(
                      //       advert: selectedAd,
                      //       navigaToPage: () => Get.off(
                      //         () => LevelPage(
                      //           programName: progam.programName,
                      //           programId: progam.programId,
                      //         ),
                      //       ),
                      //     ),
                      //   );
                      // } else {
                      //   Get.to(
                      //     () => LevelPage(
                      //       programName: progam.programName,
                      //       programId: progam.programId,
                      //     ),
                      //   );
                      // }
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
