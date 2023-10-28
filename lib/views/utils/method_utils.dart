import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

class MethodUtils {
  static String get generatedId => const Uuid().v4();

  static String formatDate(Timestamp createdAt) {
    DateTime date = createdAt.toDate();

    Duration difference = DateTime.now().difference(date);
    if (difference.inDays >= 365) {
      int years = (difference.inDays / 365).floor();
      return '$years year${years > 1 ? 's' : ''} ago';
    } else if (difference.inDays >= 30) {
      int months = (difference.inDays / 30).floor();
      return '$months month${months > 1 ? 's' : ''} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
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
  static String getLastMessageTime({required String time}) {
    final DateTime sent = DateTime.fromMillisecondsSinceEpoch(int.parse(time));
    final DateTime now = DateTime.now();

    if (now.day == sent.day &&
        now.month == sent.month &&
        now.year == sent.year) {
      return TimeOfDay.fromDateTime(sent).format(Get.context!);
    }
    return "${sent.day} ${_getMonth(sent)}";
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
}
