import 'package:cloud_firestore/cloud_firestore.dart';

class ProgramModel {
  final String programId;
  final String programName;
  final String createdBy;
  final Timestamp createdAt;

  ProgramModel({
    required this.programId,
    required this.programName,
    required this.createdBy,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      "programId": programId,
      "programName": programName,
      "createdBy": createdBy,
      "createdAt": createdAt,
    };
  }

  factory ProgramModel.fromJson(Map<String, dynamic> json, String id) {
    return ProgramModel(
      programId: id,
      programName: json['programName'],
      createdBy: json['createdBy'],
      createdAt: json['createdAt'] as Timestamp,
    );
  }

  factory ProgramModel.fromDocument(DocumentSnapshot documentSnapshot) {
    Map<String, dynamic> json = documentSnapshot.data() as Map<String, dynamic>;
    return ProgramModel.fromJson(json, documentSnapshot.id);
  }
}
