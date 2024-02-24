import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hi_tweet/model/campus_announcement.dart';
import 'package:hi_tweet/views/utils/method_utils.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../pages/home/home_controller.dart';
import '../../utils/constants.dart';

class AnimatedAnnouncementWidget extends StatelessWidget {
  const AnimatedAnnouncementWidget({
    super.key,
    required this.announcement,
    this.onLongPress,
    this.onTap,
    this.isBug = false,
  });
  final CampusAnnouncement announcement;
  final void Function()? onLongPress;
  final void Function()? onTap;
  final bool isBug;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      builder: (controller) {
        return GestureDetector(
          onTap: onTap,
          onLongPress: onLongPress,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 16),
            height: MediaQuery.of(context).size.height * 0.22,
            margin: const EdgeInsets.only(top: 10),
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14.0),
              gradient: LinearGradient(
                colors: [
                  kPrimary,
                  Colors.deepOrange.shade200,
                  kPrimary.withOpacity(0.8),
                ],
                transform: GradientRotation(controller.rotate),
                stops: const [
                  0.0,
                  0.33,
                  0.66,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isBug ? 'Bug Report!' : 'Announcement!',
                    style: GoogleFonts.pacifico(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5.0),
                  Text(
                    announcement.content,
                    style: const TextStyle(
                      fontSize: 15,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 15),
                  if (announcement.url == null)
                    Text(
                      MethodUtils.formatDate(announcement.updatedAt),
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                            fontStyle: FontStyle.italic,
                          ),
                    ),
                  if (announcement.url != null)
                    if (announcement.url!.isURL) ...[
                      const SizedBox(height: 2),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          InkWell(
                            onTap: () {
                              if (announcement.url!.isEmpty) return;
                              final webUrl = Uri.parse(announcement.url!);
                              launchUrl(webUrl,
                                  mode: LaunchMode.externalApplication);
                            },
                            child: const Text(
                              'Go to site',
                              style: TextStyle(
                                color: kPrimary,
                                fontSize: 15.5,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          Flexible(
                            child: Text(
                              MethodUtils.formatDate(announcement.updatedAt),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .copyWith(
                                    fontStyle: FontStyle.italic,
                                  ),
                            ),
                          )
                        ],
                      ),
                    ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class BannerAnnouncementWidget extends StatelessWidget {
  const BannerAnnouncementWidget({
    super.key,
    required this.announcement,
    this.onLongPress,
    this.onTap,
    this.isBug = false,
  });
  final CampusAnnouncement announcement;
  final void Function()? onLongPress;
  final void Function()? onTap;
  final bool isBug;
  @override
  Widget build(BuildContext context) {
    // return const MyWidget();

    return GestureDetector(
      onLongPress: onLongPress,
      onTap: onTap,
      child: Container(
        height: MediaQuery.sizeOf(context).height * 0.22,
        margin: const EdgeInsets.only(top: 10),
        width: double.infinity,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.black26,
          borderRadius: BorderRadius.circular(14.0),
          image: DecorationImage(
            image: CachedNetworkImageProvider(announcement.image!),
            fit: BoxFit.cover,
            opacity: .7,
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isBug ? 'Bug Report!' : 'Announcement!',
                style: GoogleFonts.pacifico(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5.0),
              Text(
                announcement.content,
                style: const TextStyle(
                  fontSize: 15,
                  fontStyle: FontStyle.italic,
                  color: Colors.white,
                ),
              ),
              if (announcement.url != null)
                if (announcement.url!.isURL) ...[
                  const SizedBox(height: 2),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InkWell(
                        onTap: () {
                          if (announcement.url!.isEmpty) return;
                          final webUrl = Uri.parse(announcement.url!);
                          launchUrl(webUrl,
                              mode: LaunchMode.externalApplication);
                        },
                        child: const Text(
                          'Go to site',
                          style: TextStyle(
                            color: kPrimary,
                            fontSize: 15.5,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      Flexible(
                        child: Text(
                          MethodUtils.formatDate(announcement.updatedAt),
                          style:
                              Theme.of(context).textTheme.bodyMedium!.copyWith(
                                    fontStyle: FontStyle.italic,
                                  ),
                        ),
                      )
                    ],
                  ),
                ],
            ],
          ),
        ),
      ),
    );
  }
}

class MyWidget extends StatelessWidget {
  const MyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final deviceWidth = MediaQuery.sizeOf(context).width;
    final deviceHeight = MediaQuery.sizeOf(context).height;
    return Stack(
      textDirection: TextDirection.rtl,
      children: [
        bannerImage(deviceWidth, deviceHeight),
        _gradientBoxWidget(deviceWidth, deviceHeight),
      ],
    );
  }
}

Widget bannerImage(deviceWidth, deviceHeight) {
  return SizedBox(
    width: deviceWidth * 0.80,
    height: deviceHeight * 0.22,
    child: Container(
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(10)),
        image: DecorationImage(
          image: AssetImage('assets/images/ymsu.jpg'),
          fit: BoxFit.cover,
          opacity: 0.65,
        ),
      ),
    ),
  );
}

Widget _gradientBoxWidget(deviceWidth, deviceHeight) {
  return Align(
    alignment: Alignment.bottomRight,
    child: Container(
      height: deviceHeight * 0.22,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.horizontal(left: Radius.circular(10)),
        gradient: LinearGradient(
          colors: [
            // Color.fromARGB(255, 179, 170, 89),
            Color.fromRGBO(130, 120, 60, 1.0),
            Colors.transparent,
          ],
          stops: [
            0.65,
            1.0,
          ],
          begin: Alignment.bottomLeft,
          end: Alignment.bottomCenter,
        ),
      ),
    ),
  );
}
