import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:full_screen_image/full_screen_image.dart';

import '../../../../../model/message_model.dart';

class ImageMessage extends StatelessWidget {
  const ImageMessage({super.key, required this.message});
  final MessageModel message;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.45, //45% of total width

      child: AspectRatio(
        aspectRatio: 1.6,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: FullScreenWidget(
            disposeLevel: DisposeLevel.High,
            child: CachedNetworkImage(
              imageUrl: message.content,
              placeholder: (context, url) => const Padding(
                padding: EdgeInsets.all(8.0),
                child: CircularProgressIndicator(strokeWidth: 1.5),
              ),
              errorWidget: (context, url, error) => const Center(
                child: Icon(
                  Icons.image,
                  size: 70,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
