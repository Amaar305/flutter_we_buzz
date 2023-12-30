import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../dashboard/my_app_controller.dart';
import 'level_page.dart';
import 'programs_controller.dart';

class ProgramsPage extends GetView<ProgramsController> {
  const ProgramsPage({super.key});
  static const String routeName = '/courses-page';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Courses'),
        actions: [
          GetX<AppController>(
            builder: (control) {
              if (FirebaseAuth.instance.currentUser != null) {
                final currentLoggedInUser = control.weBuzzUsers.firstWhere(
                    (user) =>
                        user.userId == FirebaseAuth.instance.currentUser!.uid);

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
      body: GetX<ProgramsController>(
        builder: (context) {
          return GridView.builder(
            itemCount: controller.programs.length,
            padding: const EdgeInsets.symmetric(
              horizontal: 12.0,
              vertical: 8.0,
            ),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 200,
              childAspectRatio: 1,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemBuilder: (context, index) {
              final progam = controller.programs[index];
              return ProgramGrid(
                title: progam.programName,
                onTap: () => Get.to(
                  () => LevelPage(
                    programName: progam.programName,
                    programId: progam.programId,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class ProgramGrid extends StatelessWidget {
  const ProgramGrid({super.key, required this.title, this.onTap});
  final String title;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.folder,
              color: Theme.of(context).colorScheme.primary,
              size: 45,
            ),
            const SizedBox(height: 20),
            Text(
              title.length >= 13 ? '${title.substring(0, 13)}...' : title,
              style: const TextStyle(fontSize: 20),
            ),
          ],
        ),
      ),
    );
  }
}
