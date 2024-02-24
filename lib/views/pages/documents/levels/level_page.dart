import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hi_tweet/views/utils/constants.dart';

import '../../../widgets/custom_list_tile.dart';
import '../courses/courses_page.dart';
import 'levels_list.dart';

class LevelPage extends StatelessWidget {
  const LevelPage({
    super.key,
    required this.programName,
    required this.programId,
    required this.faculty,
  });
  final String programName;
  final String programId;
  final String faculty;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$programName Levels'),
      ),
      body: Padding(
        padding: kPadding,
        child: ListView.builder(
          itemCount: levels.length,
          itemBuilder: (context, index) => CustomListTile(
            title: Text(levels[index]),
            onTap: () => Get.to(
              () => CoursesView(
                programId: programId,
                programName: programName,
                level: levels[index],
                faculty: faculty,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
