import 'package:cloud_firestore/cloud_firestore.dart';

class FacultyModel {
  final String id;
  final String name;
  final String createdBy;
  final Timestamp createdAt;

  FacultyModel({
    required this.id,
    required this.name,
    required this.createdBy,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'createdBy': createdBy,
      'createdAt': createdAt,
    };
  }

  factory FacultyModel.fromMap(Map<String, dynamic> map, id) {
    return FacultyModel(
      id: id,
      name: map['name'] as String,
      createdBy: map['createdBy'] as String,
      createdAt: map['createdAt'] as Timestamp,
    );
  }

  factory FacultyModel.fromDocument(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return FacultyModel.fromMap(data, snapshot.id);
  }
}
