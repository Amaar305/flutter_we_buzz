// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

class SaveBuzz {
  final String id;
  final String buzzId;
  final String userId;
  final Timestamp createdAt;

  SaveBuzz({
    required this.id,
    required this.buzzId,
    required this.userId,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'buzzId': buzzId,
      'userId': userId,
      'createdAt': createdAt,
    };
  }

  factory SaveBuzz.fromMap(Map<String, dynamic> map, String id) {
    return SaveBuzz(
      id: id,
      buzzId: map['buzzId'] as String,
      userId: map['userId'] as String,
      createdAt: map['createdAt'] as Timestamp,
    );
  }

  String toJson() => json.encode(toMap());

  factory SaveBuzz.fromJson(String source) =>
      SaveBuzz.fromMap(json.decode(source) as Map<String, dynamic>, '');

  factory SaveBuzz.fromDocument(DocumentSnapshot snapshot) {
    final json = snapshot.data() as Map<String, dynamic>;
    return SaveBuzz.fromMap(json, snapshot.id);
  }
}
