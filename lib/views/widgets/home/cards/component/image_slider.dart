import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:full_screen_image/full_screen_image.dart';

class ImageCarouselSlider extends StatelessWidget {
  const ImageCarouselSlider({
    super.key,
    required this.images,
  });

  final List<String> images;

  @override
  Widget build(BuildContext context) {
    return CarouselSlider.builder(
      itemCount: images.length,
      itemBuilder: (context, index, realIndex) {
        return CachedNetworkImage(
          imageUrl: images[index],
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
        );
      },
      options: CarouselOptions(
        autoPlay: true,
        reverse: true,
        viewportFraction: 1,
        enableInfiniteScroll: true,
        height: 300,
      ),
    );
  }
}
