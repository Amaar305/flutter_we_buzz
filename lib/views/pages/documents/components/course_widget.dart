import 'package:flutter/material.dart';

class CoursesTile extends StatelessWidget {
  const CoursesTile({
    super.key,
    required this.title,
    required this.url,
    this.onTap,
  });

  final String title;
  final String url;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: ListTile(
        onTap: onTap,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        // trailing: isDownloaded
        //     ? const Icon(Icons.download_done)
        //     : IconButton(
        //         onPressed: () {
        //           DownloadService().downloadFile(url, title);
        //         },
        //         icon: const Icon(Icons.download),
        //       ),
      ),
    );
  }
}

class LevelTiles extends StatelessWidget {
  const LevelTiles({
    super.key,
    required this.title,
    this.onTap,
  });
  final String title;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: ListTile(
        onTap: onTap,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
