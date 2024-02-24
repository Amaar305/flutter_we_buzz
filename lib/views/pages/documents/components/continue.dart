import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hi_tweet/model/documents/lecture_note_model.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../../model/we_buzz_model.dart';
import '../../../shimmer/shimmers.dart';
import '../../../utils/constants.dart';
import '../../advert/advert_page.dart';
import '../programs_controller.dart';
import '../view/doc_view.dart';

class ContinueReadingWidget extends StatelessWidget {
  const ContinueReadingWidget({
    super.key,
    this.showButton = false,
    required this.lectureNoteModel,
  });
  final bool showButton;
  final LectureNoteModel lectureNoteModel;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: GestureDetector(
        onTap: () {
          if (!showButton) {
            try {
              WeBuzz selectedAd = ProgramsController.instance.getRandomAdvert();
              int guess = ProgramsController.instance.nextNumber(20);
              if (guess % 2 == 0) {
                toast('Ad for 15 seconds');
                Get.to(
                  () => AdvertPage(
                    advert: selectedAd,
                    navigaToPage: () => Get.off(
                      () => DocumentView(
                        url: lectureNoteModel.url,
                        title: lectureNoteModel.title,
                      ),
                    ),
                  ),
                );
              } else {
                Get.to(
                  () => DocumentView(
                    url: lectureNoteModel.url,
                    title: lectureNoteModel.title,
                  ),
                );
              }
            } catch (e) {
              Get.to(
                () => DocumentView(
                  url: lectureNoteModel.url,
                  title: lectureNoteModel.title,
                ),
              );
              log('Error trying to display an ads');
              log(e);
            }
          }
        },
        child: ShimmerSkeleton(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: MediaQuery.sizeOf(context).height * 0.17,
                width: MediaQuery.sizeOf(context).height * 0.15,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: const Image(
                    image: CachedNetworkImageProvider(coverImage),
                    fit: BoxFit.fitHeight,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lectureNoteModel.title,
                      textAlign: TextAlign.start,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      lectureNoteModel.programName,
                      textAlign: TextAlign.start,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                    if (showButton) ...[
                      const SizedBox(height: 10),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () {
                          try {
                            WeBuzz selectedAd =
                                ProgramsController.instance.getRandomAdvert();
                            int guess =
                                ProgramsController.instance.nextNumber(20);
                            if (guess % 2 == 0) {
                              toast('Ad for 15 seconds');
                              Get.to(
                                () => AdvertPage(
                                  advert: selectedAd,
                                  navigaToPage: () => Get.off(
                                    () => Get.to(
                                      () => DocumentView(
                                        url: lectureNoteModel.url,
                                        title: lectureNoteModel.title,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            } else {
                              Get.to(
                                () => Get.to(
                                  () => DocumentView(
                                    url: lectureNoteModel.url,
                                    title: lectureNoteModel.title,
                                  ),
                                ),
                              );
                            }
                          } catch (e) {
                            Get.to(
                              () => Get.to(
                                () => DocumentView(
                                  url: lectureNoteModel.url,
                                  title: lectureNoteModel.title,
                                ),
                              ),
                            );
                            log('Error trying to display an ads');
                            log(e);
                          }
                        },
                        child: const Text(
                          'Continue',
                          style: TextStyle(color: kblack),
                        ),
                      )
                    ]
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
