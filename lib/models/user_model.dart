import 'package:hive/hive.dart';

part 'user_model.g.dart';

@HiveType(typeId: 0)
class UserModel extends HiveObject {
  @HiveField(0)
  final String uid;

  @HiveField(1)
  final String email;

  @HiveField(2)
  final String name;

  @HiveField(3)
  final double monthlyBudget;

  @HiveField(4)
  final DateTime createdAt;

  @HiveField(5)
  final bool aiAdviceEnabled;

  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    this.monthlyBudget = 0.0,
    required this.createdAt,
    this.aiAdviceEnabled = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'monthlyBudget': monthlyBudget,
      'createdAt': createdAt.toIso8601String(),
      'aiAdviceEnabled': aiAdviceEnabled,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      monthlyBudget: (map['monthlyBudget'] ?? 0.0).toDouble(),
      createdAt: DateTime.parse(map['createdAt']),
      aiAdviceEnabled: map['aiAdviceEnabled'] ?? true,
    );
  }

  UserModel copyWith({
    String? uid,
    String? email,
    String? name,
    double? monthlyBudget,
    DateTime? createdAt,
    bool? aiAdviceEnabled,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      name: name ?? this.name,
      monthlyBudget: monthlyBudget ?? this.monthlyBudget,
      createdAt: createdAt ?? this.createdAt,
      aiAdviceEnabled: aiAdviceEnabled ?? this.aiAdviceEnabled,
    );
  }
}
