import 'package:flutter/material.dart';
import 'package:hi_tweet/views/shimmer/shimmers.dart';

class HomePageShimmer extends StatelessWidget {
  const HomePageShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 7,
      itemBuilder: (context, index) => const _ShimmerHomeWidget(),
    );
  }
}

class _ShimmerHomeWidget extends StatelessWidget {
  const _ShimmerHomeWidget();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 8,
      ),
      child: ShimmerSkeleton(
        width: 120,
        height: 120,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _postShimmerHeader(),
            const SizedBox(height: 10),
            const ShimmerSkeleton(width: double.infinity, height: 20),
            const SizedBox(height: 10),
            const ShimmerSkeleton(width: double.infinity, height: 20),
            const SizedBox(height: 10),
            const ShimmerSkeleton(width: double.infinity, height: 20),
            const SizedBox(height: 10),
            const ShimmerSkeleton(width: double.infinity, height: 20),
            const SizedBox(height: 10),
            const ShimmerSkeleton(width: double.infinity, height: 20),
            const SizedBox(height: 10),
            const ShimmerSkeleton(width: double.infinity, height: 20),
            const SizedBox(height: 10),
            _actionShimmerButton()
          ],
        ),
      ),
    );
  }

  Widget _actionShimmerButton() {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        ShimmerSkeleton(
          width: 30,
          height: 30,
        ),
        ShimmerSkeleton(
          width: 30,
          height: 30,
        ),
        ShimmerSkeleton(
          width: 30,
          height: 30,
        ),
      ],
    );
  }

  Widget _postShimmerHeader() {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            ShimmerSkeleton(
              width: 35,
              height: 35,
            ),
            SizedBox(
              width: 5,
            ),
            ShimmerSkeleton(
              width: 100,
              height: 15,
            ),
            SizedBox(
              width: 5,
            ),
            ShimmerSkeleton(
              width: 20,
              height: 20,
            ),
            SizedBox(
              width: 5,
            ),
            ShimmerSkeleton(
              height: 15,
              width: 50,
            )
          ],
        ),
        ShimmerSkeleton(
          width: 22,
          height: 10,
        )
      ],
    );
  }
}
