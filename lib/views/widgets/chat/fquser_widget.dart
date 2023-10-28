import 'package:flutter/material.dart';
import 'package:full_screen_image/full_screen_image.dart';

class FQUsers extends StatelessWidget {
  const FQUsers({
    super.key,
    required this.isOnline,
    required this.imageUrl,
  });
  final bool isOnline;
  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: Theme.of(context).colorScheme.secondary,
            child: FullScreenWidget(
              disposeLevel: DisposeLevel.High,
              child: CircleAvatar(
                radius: 30,
                backgroundImage: AssetImage(imageUrl),
              ),
            ),
          ),
          if (isOnline)
            Positioned(
              top: 50,
              left: 32,
              right: 0,
              child: Icon(
                Icons.circle,
                size: 15,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
        ],
      ),
    );
  }
}
