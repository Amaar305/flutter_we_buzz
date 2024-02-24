import 'package:cloud_firestore/cloud_firestore.dart';

class ProgramModel {
  final String programId;
  final String programName;
  final String faculty;
  final String createdBy;

  final Timestamp createdAt;

  ProgramModel({
    required this.programId,
    required this.programName,
    required this.createdBy,
    required this.createdAt,
    required this.faculty,
  });

  Map<String, dynamic> toJson() {
    return {
      "programId": programId,
      "programName": programName,
      "createdBy": createdBy,
      "createdAt": createdAt,
      "faculty": faculty,
    };
  }

  factory ProgramModel.fromJson(Map<String, dynamic> json, String id) {
    return ProgramModel(
      programId: id,
      programName: json['programName'] as String,
      createdBy: json['createdBy'] as String,
      createdAt: json['createdAt'] as Timestamp,
      faculty: json['faculty'] as String,
    );
  }

  factory ProgramModel.fromDocument(DocumentSnapshot documentSnapshot) {
    Map<String, dynamic> json = documentSnapshot.data() as Map<String, dynamic>;
    return ProgramModel.fromJson(json, documentSnapshot.id);
  }
}
