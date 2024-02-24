import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../pages/home/filters/hashtag_filter_page.dart';

class StylizedPostContent extends StatelessWidget {
  final String content;

  const StylizedPostContent({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    return RichTextStyler(content: content, context: context);
  }
}

class RichTextStyler extends StatelessWidget {
  final String content;
  final BuildContext context;

  const RichTextStyler(
      {super.key, required this.content, required this.context});

  @override
  Widget build(BuildContext context) {
    final hashtagRegex = RegExp(r'#\w+');
    final urlRegex = RegExp(r'(https?://\S+)');

    final matches = <Match>[];
    matches.addAll(hashtagRegex.allMatches(content));
    matches.addAll(urlRegex.allMatches(content));
    matches.sort((a, b) => a.start.compareTo(b.start));

    final textSpans = <TextSpan>[];
    int currentStart = 0;

    void addTextSpan(int start, int end, TextStyle style) {
      if (end > start) {
        textSpans.add(TextSpan(
          text: content.substring(start, end),
          style: style,
        ));
      }
    }

    for (final match in matches) {
      // Add the text before the hashtag or URL
      addTextSpan(currentStart, match.start, updateTextStyle(context));

      // Stylize the hashtag or URL
      textSpans.add(
        TextSpan(
          text: match.group(0),
          style: match.pattern == hashtagRegex
              ? TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                  // Add other styling as needed
                )
              : const TextStyle(
                  color: Colors.blue, // Change to your desired color for URLs
                  fontWeight: FontWeight.bold,
                  // Add other styling as needed
                ),
          recognizer: TapGestureRecognizer()
            ..onTap = () async {
              if (match.pattern == hashtagRegex) {
                // Handle hashtag click event
                Get.to(() => HashTagFilterPage(
                      hashtag: match.group(0)!,
                    ));
              } else {
                final websiteUrl = Uri.parse(match.group(0)!);
                launchUrl(websiteUrl, mode: LaunchMode.externalApplication);

                // Handle URL click event
              }
            },
        ),
      );

      currentStart = match.end;
    }

    // Add the remaining text after the last hashtag or URL
    addTextSpan(currentStart, content.length, updateTextStyle(context));

    return RichText(
      text: TextSpan(
        children: textSpans,
        style: updateTextStyle(context),
      ),
    );
  }

  // Extracted method to update text style based on theme
  TextStyle updateTextStyle(BuildContext context) {
    return Theme.of(context).textTheme.bodyLarge!;
  }
}
