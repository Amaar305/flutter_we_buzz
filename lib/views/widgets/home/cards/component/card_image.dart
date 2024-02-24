import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:full_screen_image/full_screen_image.dart';

import '../../../../../model/we_buzz_model.dart';

class CardImage extends StatelessWidget {
  const CardImage({super.key, required this.normalWebuzz});
final WeBuzz normalWebuzz;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(
          height: 10,
        ),
        CachedNetworkImage(
          imageUrl: normalWebuzz.imageUrl!,
          errorWidget: (context, url, error) => const Center(
            child: Icon(Icons.image_not_supported),
          ),
          placeholder: (context, url) {
            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
              ),
            );
          },
          imageBuilder: (context, imageProvider) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: InteractiveViewer(
                clipBehavior: Clip.none,
                child: FullScreenWidget(
                  disposeLevel: DisposeLevel.High,
                  child: Image(
                    image: imageProvider,
                    fit: BoxFit.fitWidth,
                    width: double.maxFinite,
                    height: 300,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
