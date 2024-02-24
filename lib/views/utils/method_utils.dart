// ignore_for_file: deprecated_member_use

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';

import '../../model/we_buzz_user_model.dart';
import '../pages/chat/add_users_page/add_users_controller.dart';

class MethodUtils {
  static String get generatedId => const Uuid().v4();

  static String formatDate(Timestamp createdAt) {
    DateTime date = createdAt.toDate();

    Duration difference = DateTime.now().difference(date);
    if (difference.inDays >= 365) {
      int years = (difference.inDays / 365).floor();
      return '${years}year${years > 1 ? 's' : ''}';
    } else if (difference.inDays >= 30) {
      int months = (difference.inDays / 30).floor();
      return '${months}month${months > 1 ? 's' : ''}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}day${difference.inDays > 1 ? 's' : ''} ';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}hour${difference.inHours > 1 ? 's' : ''}';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}minute${difference.inMinutes > 1 ? 's' : ''}';
    } else {
      return 'Just now';
    }
  }

  static String formatNumber(int number) {
    if (number > 1000000) {
      double result = number / 1000000;
      return '${result.toStringAsFixed(result.truncateToDouble() == result ? 0 : 1)}m';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}k';
    } else {
      return number.toString();
    }
  }

  static String formatDateWithMonthAndDay(Timestamp createdAt) {
    DateTime date =
        DateTime.fromMillisecondsSinceEpoch(createdAt.millisecondsSinceEpoch);
    DateFormat formatter = DateFormat('dd MMM');
    String formatted = formatter.format(date);
    return formatted;
  }

// for getting a last message  from millisecondsEpoch
  static String getFormattedDate({required String time}) {
    final date = DateTime.fromMillisecondsSinceEpoch(int.parse(time));
    return TimeOfDay.fromDateTime(date).format(Get.context!);
  }

  //  for getting a last message time (used in user card)
  static String getLastMessageTime(
      {required String time, bool showYear = false}) {
    final DateTime sent = DateTime.fromMillisecondsSinceEpoch(int.parse(time));
    final DateTime now = DateTime.now();

    if (now.day == sent.day &&
        now.month == sent.month &&
        now.year == sent.year) {
      return TimeOfDay.fromDateTime(sent).format(Get.context!);
    }
    return showYear
        ? "${sent.day} ${_getMonth(sent)} ${sent.year}"
        : "${sent.day} ${_getMonth(sent)}";
  }

  // for getting a month name from month no. or index
  static String _getMonth(DateTime date) {
    switch (date.month) {
      case 1:
        return "Jan";
      case 2:
        return "Feb";
      case 3:
        return "Mar";
      case 4:
        return "Apr";
      case 5:
        return "May";
      case 6:
        return "Jun";
      case 7:
        return "Jul";
      case 8:
        return "Aug";
      case 9:
        return "Sep";
      case 10:
        return "Oct";
      case 11:
        return "Nov";
      case 12:
        return "Dec";
    }
    return "NA";
  }

// Function to make a phone call
  static void makePhoneCall(String phoneNumber) async {
    String url = 'tel:$phoneNumber';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      // Handle the case where the user can't launch the phone call.
      log('Could not launch $url');
      toast('Could not call $url');
    }
  }

  // Function to send an email
  static void sendEmail({
    required String to,
    required String subject,
    required String body,
  }) async {
    String url =
        'mailto:$to?subject=${Uri.encodeComponent(subject)}&body=${Uri.encodeComponent(body)}';

    if (await canLaunch(url)) {
      await launch(url);
    } else {
      // Handle the case where the user can't launch the email app.
      log('Could not launch $url');
    }
  }

  static final RegExp emailValidation = RegExp(
      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");

  static bool shouldDisplayDMButton(WeBuzzUser targetUser) {
    var dmPrivacy = targetUser.directMessagePrivacy;

    var currenttUsersFollowers =
        AddUsersController.instance.currenttUsersFollowers;
    var currenttUsersFollowing =
        AddUsersController.instance.currenttUsersFollowing;

    // Display the DM button based on DM privacy settings
    // Display the DM button based on DM privacy settings
    if (dmPrivacy == DirectMessagePrivacy.everyone) {
      return true;
    } else if (dmPrivacy == DirectMessagePrivacy.followers &&
        currenttUsersFollowing.contains(targetUser.userId)) {
      return true;
    } else if (dmPrivacy == DirectMessagePrivacy.following &&
        currenttUsersFollowers.contains(targetUser.userId)) {
      return true;
    } else if (dmPrivacy == DirectMessagePrivacy.mutual &&
        currenttUsersFollowing.contains(targetUser.userId) &&
        currenttUsersFollowers.contains(targetUser.userId)) {
      return true;
    }

    return false;
  }

  static String formatPhoneNumber(String phoneNumber) {
    // Check if the number starts with '0' and not with '+234'
    if (phoneNumber.startsWith('0') && !phoneNumber.startsWith('+234')) {
      // Remove leading '0' and add '+234' prefix
      phoneNumber = '+234${phoneNumber.substring(1)}';
    }

    return phoneNumber;
  }

  static void openWhatsAppChat(String phoneNumber) async {
    // The URL scheme for opening WhatsApp chat with a specific number
    final number = MethodUtils.formatPhoneNumber(phoneNumber);
    final Uri whatsappUrl = Uri.parse("https://wa.me/$number");

    try {
      await launchUrl(whatsappUrl);
    } catch (e) {
      toast("Could not launch $whatsappUrl");
    }
  }
}
