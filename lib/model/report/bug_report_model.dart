// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:cloud_firestore/cloud_firestore.dart';

class ReportBug {
  final String id;
  final String description;
  final String user;
  final String? imageUrl;

  final bool? isReviewed;
  final Timestamp createdAt;

  ReportBug({
    required this.id,
    required this.description,
    required this.user,
    required this.imageUrl,
    required this.createdAt,
    this.isReviewed = false,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'description': description,
      'user': user,
      'imageUrl': imageUrl,
      'createdAt': createdAt,
      'isReviewed': isReviewed,
    };
  }

  factory ReportBug.fromMap(Map<String, dynamic> map, String id) {
    return ReportBug(
      id: id,
      description: map['description'] as String,
      user: map['user'] as String,
      imageUrl: map['imageUrl'] != null ? map['imageUrl'] as String : null,
      createdAt: map['createdAt'] as Timestamp,
      isReviewed: map['isReviewed'] as bool?
    );
  }

  factory ReportBug.fromDocumentSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return ReportBug.fromMap(data, snapshot.id);
  }

  @override
  bool operator ==(covariant ReportBug other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.description == description &&
        other.user == user &&
        other.imageUrl == imageUrl &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        description.hashCode ^
        user.hashCode ^
        imageUrl.hashCode ^
        createdAt.hashCode;
  }
}
