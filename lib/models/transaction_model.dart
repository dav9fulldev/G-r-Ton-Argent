import 'package:hive/hive.dart';

part 'transaction_model.g.dart';

enum TransactionType { income, expense }

enum TransactionCategory {
  food,
  transport,
  entertainment,
  shopping,
  health,
  education,
  utilities,
  salary,
  freelance,
  investment,
  other
}

@HiveType(typeId: 1)
class TransactionModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String userId;

  @HiveField(2)
  final double amount;

  @HiveField(3)
  final TransactionType type;

  @HiveField(4)
  final TransactionCategory category;

  @HiveField(5)
  final DateTime date;

  @HiveField(6)
  final String description;

  @HiveField(7)
  final DateTime createdAt;

  TransactionModel({
    required this.id,
    required this.userId,
    required this.amount,
    required this.type,
    required this.category,
    required this.date,
    required this.description,
    required this.createdAt,
  });
}
