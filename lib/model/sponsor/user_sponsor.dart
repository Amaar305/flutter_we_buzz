// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

class UserSponsor {
  final String userId;
  final String name;
  final String email;
  final String phone;

  final Timestamp createdAt;

  UserSponsor({
    required this.userId,
    required this.name,
    required this.email,
    required this.phone,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'userId': userId,
      'name': name,
      'email': email,
      'phone': phone,
      'createdAt': createdAt,
    };
  }

  factory UserSponsor.fromMap(Map<String, dynamic> map) {
    return UserSponsor(
      userId: map['userId'] as String,
      name: map['name'] as String,
      email: map['email'] as String,
      phone: map['phone'] as String,
      createdAt: map['createdAt'],
    );
  }

  String toJson() => json.encode(toMap());

  factory UserSponsor.fromJson(String source) =>
      UserSponsor.fromMap(json.decode(source) as Map<String, dynamic>);

  factory UserSponsor.fromDocument(DocumentSnapshot documentSnapshot) {
    Map<String, dynamic> map = documentSnapshot.data() as Map<String, dynamic>;
    return UserSponsor.fromMap(map);
  }
}
