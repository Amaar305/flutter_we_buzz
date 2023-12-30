import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'components/course_widget.dart';
import 'courses/courses.dart';
import 'levels_list.dart';

class LevelPage extends StatelessWidget {
  const LevelPage({
    super.key,
    required this.programName,
    required this.programId,
  });
  final String programName;
  final String programId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$programName Levels'),
      ),
      body: ListView.builder(
        itemCount: levels.length,
        itemBuilder: (context, index) => LevelTiles(
          title: levels[index],
          onTap: () => Get.to(
            () => CoursesView(
              programId: programId,
              programName: programName,
              level: levels[index],
            ),
          ),
        ),
      ),
    );
  }
}
