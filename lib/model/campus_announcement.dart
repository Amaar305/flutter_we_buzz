// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:cloud_firestore/cloud_firestore.dart';

class CampusAnnouncement {
  final String id;
  final String content;
  late String? image;
  late String? url;
  final Timestamp timestamp;
  final Timestamp updatedAt;
  final int durationInHours;
  final String createdBy;

  CampusAnnouncement({
    required this.id,
    required this.content,
    this.image,
    this.url,
    required this.timestamp,
    required this.updatedAt,
    required this.durationInHours,
    required this.createdBy,
  });

  bool shouldDisplay() {
    DateTime now = DateTime.now();
    DateTime expirationTime =
        updatedAt.toDate().add(Duration(hours: durationInHours));
    return now.isBefore(expirationTime);
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'content': content,
      'image': image,
      'timestamp': timestamp,
      'updatedAt': updatedAt,
      'durationInHours': durationInHours,
      'url': url,
      'createdBy': createdBy,
    };
  }

  factory CampusAnnouncement.fromJson(Map<String, dynamic> json, String id) {
    return CampusAnnouncement(
      content: json['content'],
      timestamp: json['timestamp'],
      updatedAt: json['updatedAt'],
      durationInHours: json['durationInHours'],
      image: json['image'],
      url: json['url'],
      id: id,
      createdBy: json['createdBy'],
    );
  }

  factory CampusAnnouncement.fromDocument(DocumentSnapshot documentSnapshot) {
    final data = documentSnapshot.data() as Map<String, dynamic>;
    return CampusAnnouncement.fromJson(data, documentSnapshot.id);
  }

  CampusAnnouncement copyWith({
    String? id,
    String? content,
    String? image,
    String? url,
    Timestamp? timestamp,
    Timestamp? updatedAt,
    int? durationInHours,
    String? createdBy,
  }) {
    return CampusAnnouncement(
      id: id ?? this.id,
      content: content ?? this.content,
      image: image ?? this.image,
      url: url ?? this.url,
      timestamp: timestamp ?? this.timestamp,
      updatedAt: updatedAt ?? this.updatedAt,
      durationInHours: durationInHours ?? this.durationInHours,
      createdBy: createdBy ?? this.createdBy,
    );
  }
}
