// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

class Sponsorship {
  final String sponsorId;
  final String ownerId;
  final String title;
  final String description;
  final String? websiteUrl;
  final String phone;
  final String email;
  final String? xHandle;
  final String? facebookHandle;
  final String? instagramHandle;
  final List<String> pictures;
  final int duration;
  final double amount;

  final bool hasPaid;

  final Timestamp createdAt;

  Sponsorship({
    required this.sponsorId,
    required this.ownerId,
    required this.title,
    required this.description,
    required this.websiteUrl,
    required this.phone,
    required this.email,
    required this.xHandle,
    required this.facebookHandle,
    required this.instagramHandle,
    required this.pictures,
    required this.hasPaid,
    required this.duration,
    required this.createdAt,
    required this.amount,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'sponsorId': sponsorId,
      'ownerId': ownerId,
      'title': title,
      'description': description,
      'websiteUrl': websiteUrl,
      'phone': phone,
      'email': email,
      'xHandle': xHandle,
      'facebookHandle': facebookHandle,
      'instagramHandle': instagramHandle,
      'pictures': pictures,
      'duration': duration,
      'amount': amount,
      'hasPaid': hasPaid,
      'createdAt': createdAt,
    };
  }

  factory Sponsorship.fromMap(Map<String, dynamic> map, String sponsorId) {
    return Sponsorship(
      sponsorId: sponsorId,
      ownerId: map['ownerId'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      phone: map['phone'] as String,
      email: map['email'] as String,
      websiteUrl:
          map['websiteUrl'] != null ? map['websiteUrl'] as String : null,
      xHandle: map['xHandle'] != null ? map['xHandle'] as String : null,
      facebookHandle: map['facebookHandle'] != null
          ? map['facebookHandle'] as String
          : null,
      instagramHandle: map['instagramHandle'] != null
          ? map['instagramHandle'] as String
          : null,
      pictures: List<String>.from(
        (map['pictures'] as List<String>),
      ),
      createdAt: map['createdAt'] as Timestamp,
      duration: map['duration'] as int,
      hasPaid: map['hasPaid'] as bool,
      amount: map['amount'] as double,
    );
  }

  String toJson() => json.encode(toMap());

  factory Sponsorship.fromJson(String source) =>
      Sponsorship.fromMap(json.decode(source) as Map<String, dynamic>, '');

  factory Sponsorship.fromDocument(DocumentSnapshot documentSnapshot) {
    Map<String, dynamic> map = documentSnapshot.data() as Map<String, dynamic>;
    return Sponsorship.fromMap(map, documentSnapshot.id);
  }
}
