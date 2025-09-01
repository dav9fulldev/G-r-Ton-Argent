import 'package:hive/hive.dart';

part 'transaction_model.g.dart';

@HiveType(typeId: 0)
enum TransactionType {
  @HiveField(0)
  income,
  @HiveField(1)
  expense,
}

@HiveType(typeId: 1)
enum TransactionCategory {
  @HiveField(0)
  food,
  @HiveField(1)
  transport,
  @HiveField(2)
  entertainment,
  @HiveField(3)
  shopping,
  @HiveField(4)
  health,
  @HiveField(5)
  education,
  @HiveField(6)
  utilities,
  @HiveField(7)
  salary,
  @HiveField(8)
  freelance,
  @HiveField(9)
  investment,
  @HiveField(10)
  other,
}

@HiveType(typeId: 2)
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

  TransactionModel copyWith({
    String? id,
    String? userId,
    double? amount,
    TransactionType? type,
    TransactionCategory? category,
    DateTime? date,
    String? description,
    DateTime? createdAt,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      category: category ?? this.category,
      date: date ?? this.date,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'amount': amount,
      'type': type.name,
      'category': category.name,
      'date': date.toIso8601String(),
      'description': description,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'amount': amount,
      'type': type.name,
      'category': category.name,
      'date': date.toIso8601String(),
      'description': description,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      amount: (map['amount'] ?? 0.0).toDouble(),
      type: TransactionType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => TransactionType.expense,
      ),
      category: TransactionCategory.values.firstWhere(
        (e) => e.name == map['category'],
        orElse: () => TransactionCategory.other,
      ),
      date: DateTime.parse(map['date']),
      description: map['description'] ?? '',
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel.fromMap(json);
  }

  @override
  String toString() {
    return 'TransactionModel(id: $id, userId: $userId, amount: $amount, type: $type, category: $category, date: $date, description: $description, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TransactionModel &&
        other.id == id &&
        other.userId == userId &&
        other.amount == amount &&
        other.type == type &&
        other.category == category &&
        other.date == date &&
        other.description == description &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        userId.hashCode ^
        amount.hashCode ^
        type.hashCode ^
        category.hashCode ^
        date.hashCode ^
        description.hashCode ^
        createdAt.hashCode;
  }
}
