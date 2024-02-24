import 'package:cloud_firestore/cloud_firestore.dart';

import 'transaction_type.dart';

class TransactionModel {
  final String id;
  final String reference;
  final String transactionItemId;
  final double amount;

  final TransactionType transactionType;
  final Timestamp createdAt;

  TransactionModel({
    required this.id,
    required this.reference,
    required this.transactionItemId,
    required this.amount,
    required this.createdAt,
    required this.transactionType,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'reference': reference,
      'transactionItemId': transactionItemId,
      'amount': amount,
      'transactionType': transactionType.name,
      'createdAt': createdAt,
    };
  }

  factory TransactionModel.fromJson(Map<String, dynamic> json, String id) {
    TransactionType transactionType;
    switch (json['transactionType']) {
      case 'sponsor':
        transactionType = TransactionType.sponsor;

        break;
      case 'verifyMe':
        transactionType = TransactionType.verifyMe;

        break;
      case 'premium':
        transactionType = TransactionType.premium;

        break;
      case 'graduant':
        transactionType = TransactionType.graduant;

        break;

      default:
        transactionType = TransactionType.unknown;
    }
    return TransactionModel(
      id: id,
      reference: json['reference'] as String,
      transactionItemId: json['transactionItemId'] as String,
      amount: json['amount'] as double,
      transactionType: transactionType,
      createdAt: json['createdAt'] as Timestamp,
    );
  }

  factory TransactionModel.fromSnapshot(DocumentSnapshot snapshot) {
    Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;

    return TransactionModel.fromJson(data, snapshot.id);
  }
}
