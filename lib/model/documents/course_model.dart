import 'package:cloud_firestore/cloud_firestore.dart';

class CourseModel {
  final String courseID;
  final String programId;
  final String courseCode;
  final String courseName;
  final String level;
  final String uploadedBy;
  final String lectureRefrence;
  final bool pastQ;
  final bool isFreeBook;
  final Timestamp uploadedAt;

  CourseModel({
    required this.courseID,
    required this.programId,
    required this.courseCode,
    required this.courseName,
    required this.uploadedBy,
    required this.lectureRefrence,
    required this.level,
    this.pastQ = false,
    required this.isFreeBook,
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
      "lectureRefrence": lectureRefrence,
      "pastQ": pastQ,
      "isFreeBook": isFreeBook,
      "courseID": courseID,
    };
  }

  factory CourseModel.fromJson(Map<String, dynamic> json, String id) {
    return CourseModel(
      courseID: id,
      courseCode: json['courseCode'],
      uploadedBy: json['uploadedBy'],
      programId: json['programId'],
      courseName: json['courseName'],
      level: json['level'],
      uploadedAt: json['uploadedAt'] as Timestamp,
      lectureRefrence: json['lectureRefrence'],
      pastQ: json['pastQ'],
      isFreeBook: json['isFreeBook'],
    );
  }

  factory CourseModel.fromDocument(DocumentSnapshot documentSnapshot) {
    Map<String, dynamic> json = documentSnapshot.data() as Map<String, dynamic>;
    return CourseModel.fromJson(json, documentSnapshot.id);
  }
}
