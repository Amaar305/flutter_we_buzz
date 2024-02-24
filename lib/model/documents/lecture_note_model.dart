import 'package:cloud_firestore/cloud_firestore.dart';

class LectureNoteModel {
  final String id;
  final String courseCode;
  final String faculty;
  final String title;
  final String level;
  final String programName;
  final String url;
  final String createdBy;
  final Timestamp createdAt;

  LectureNoteModel({
    required this.id,
    required this.courseCode,
    required this.title,
    required this.level,
    required this.url,
    required this.createdBy,
    required this.createdAt,
    required this.faculty,
    required this.programName,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'courseCode': courseCode,
      'title': title,
      'level': level,
      'url': url,
      'createdBy': createdBy,
      'createdAt': createdAt,
      "faculty": faculty,
      "programName": programName,
    };
  }

  factory LectureNoteModel.fromMap(Map<String, dynamic> map, String id) {
    return LectureNoteModel(
      id: id,
      courseCode: map['courseCode'] as String,
      title: map['title'] as String,
      level: map['level'] as String,
      url: map['url'] as String,
      createdBy: map['createdBy'] as String,
      createdAt: map['createdAt'] as Timestamp,
      faculty: map['faculty'] as String,
      programName: map['programName'] as String,
    );
  }

  factory LectureNoteModel.fromDocument(DocumentSnapshot snapshot) {
    final map = snapshot.data() as Map<String, dynamic>;
    return LectureNoteModel.fromMap(map, snapshot.id);
  }
}
