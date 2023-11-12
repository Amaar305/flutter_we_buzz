import 'package:cloud_firestore/cloud_firestore.dart';

class Report {
  final String reportID;
  final ReportType reportType;
  final String reporterID;
  final String reason;
  final Timestamp createdAt;

  Report({
    required this.reportID,
    required this.reportType,
    required this.reporterID,
    required this.reason,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    String reportTypes;
    switch (reportType) {
      case ReportType.buzz:
        reportTypes = ReportType.buzz.name;
        break;
      case ReportType.user:
        reportTypes = ReportType.user.name;
        break;
      default:
        reportTypes = "";
    }
    return {
      "reportID": reportID,
      "reportType": reportTypes,
      "reporterID": reporterID,
      "reason": reason,
      "createdAt": createdAt,
    };
  }

  factory Report.fromJson(Map<String, dynamic> json, String docID) {
    ReportType reportType;
    switch (json['reportType']) {
      case "user":
        reportType = ReportType.user;

        break;
      case "buzz":
        reportType = ReportType.buzz;

        break;
      default:
        reportType = ReportType.unknown;
    }

    return Report(
      reportID: docID,
      reportType: reportType,
      reporterID: json['reporterID'] as String,
      reason: json['reason'] as String,
      createdAt: json['createdAt'] as Timestamp,
    );
  }

  factory Report.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Report.fromJson(data, doc.id);
  }
}

enum ReportType {
  buzz,
  user,
  unknown,
}
