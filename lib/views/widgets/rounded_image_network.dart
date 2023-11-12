import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:full_screen_image/full_screen_image.dart';
import 'package:hi_tweet/views/utils/constants.dart';

class RoundedImageNetwork extends StatelessWidget {
  const RoundedImageNetwork({
    super.key,
    required this.size,
    required this.imageUrl,
  });
  final double size;
  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return FullScreenWidget(
      disposeLevel: DisposeLevel.Medium,
      child: Container(
        height: size,
        width: size,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: CachedNetworkImageProvider(
              imageUrl,
            ),
            // image: AssetImage('assets/images/user.png'),
            fit: BoxFit.cover,
          ),
          borderRadius: BorderRadius.all(
            Radius.circular(size),
          ),
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}

class RoundedImageNetworkWithStatusIndicator extends RoundedImageNetwork {
  final bool isOnline;
  final bool onlineStatus;
  const RoundedImageNetworkWithStatusIndicator( {
    required Key key,
    required super.size,
    required super.imageUrl,
    required this.isOnline,
    required this.onlineStatus,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.bottomRight,
      children: [
        super.build(context),
        
       if(onlineStatus) Container(
          height: size * 0.20,
          width: size * 0.20,
          decoration: BoxDecoration(
            color:
                isOnline ? Theme.of(context).colorScheme.primary : kDefaultGrey,
            borderRadius: BorderRadius.circular(size),
          ),
        ),
      ],
    );
  }
}
