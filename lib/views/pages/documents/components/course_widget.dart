import 'package:flutter/material.dart';
import 'package:hi_tweet/views/widgets/custom_list_tile.dart';

class CoursesTile extends StatelessWidget {
  const CoursesTile({
    super.key,
    required this.title,
    required this.url,
    this.onTap,
    this.onLongPress,
  });

  final String title;
  final String url;
  final void Function()? onTap;
  final void Function()? onLongPress;

  @override
  Widget build(BuildContext context) {
    return CustomListTile(
      onTap: onTap,
      title: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          Flexible(
            child: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                overflow: TextOverflow.ellipsis,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );

    /*
    Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        onTap: onTap,
        onLongPress: onLongPress,

        title: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            Flexible(
              child: Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  overflow: TextOverflow.ellipsis,
                ),
                overflow: TextOverflow.ellipsis,
              ),
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
  */
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
        borderRadius: BorderRadius.circular(10),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        child: ListTile(
          onTap: onTap,
          title: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
