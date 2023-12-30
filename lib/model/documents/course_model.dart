import 'package:cloud_firestore/cloud_firestore.dart';

class CourseModel {
  final String programId;
  final String courseCode;
  final String courseName;
  final String level;
  final String uploadedBy;
  final String url;
  final Timestamp uploadedAt;

  CourseModel({
    required this.programId,
    required this.courseCode,
    required this.courseName,
    required this.uploadedBy,
    required this.url,
    required this.level,
    required this.uploadedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      "programId": programId,
      "courseCode": courseCode,
      "courseName": courseName,
      "level": level,
      "uploadedBy": uploadedBy,
      "uploadedAt": uploadedAt,
      "url": url,
    };
  }

  factory CourseModel.fromJson(Map<String, dynamic> json) {
    return CourseModel(
      courseCode: json['courseCode'],
      uploadedBy: json['uploadedBy'],
      programId: json['programId'],
      courseName: json['courseName'],
      level: json['level'],
      uploadedAt: json['uploadedAt'] as Timestamp,
      url: json['url'],
    );
  }

  factory CourseModel.fromDocument(DocumentSnapshot documentSnapshot) {
    Map<String, dynamic> json = documentSnapshot.data() as Map<String, dynamic>;
    return CourseModel.fromJson(json);
  }
}
