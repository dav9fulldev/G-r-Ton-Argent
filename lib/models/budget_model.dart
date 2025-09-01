import 'package:hive/hive.dart';

part 'budget_model.g.dart';

@HiveType(typeId: 3)
class BudgetModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String userId;

  @HiveField(2)
  final double monthlyBudget;

  @HiveField(3)
  final DateTime createdAt;

  @HiveField(4)
  final DateTime updatedAt;

  BudgetModel({
    required this.id,
    required this.userId,
    required this.monthlyBudget,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BudgetModel.fromJson(Map<String, dynamic> json) {
    return BudgetModel(
      id: json['id'],
      userId: json['userId'],
      monthlyBudget: (json['monthlyBudget'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'monthlyBudget': monthlyBudget,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  BudgetModel copyWith({
    String? id,
    String? userId,
    double? monthlyBudget,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BudgetModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      monthlyBudget: monthlyBudget ?? this.monthlyBudget,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'BudgetModel(id: $id, userId: $userId, monthlyBudget: $monthlyBudget, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BudgetModel &&
        other.id == id &&
        other.userId == userId &&
        other.monthlyBudget == monthlyBudget &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        userId.hashCode ^
        monthlyBudget.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode;
  }
}
