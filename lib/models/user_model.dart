import 'package:hive/hive.dart';

part 'user_model.g.dart';

@HiveType(typeId: 3)
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

  @HiveField(6)
  final String? profilePhotoUrl;

  @HiveField(7)
  final String language;

  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    required this.monthlyBudget,
    required this.createdAt,
    this.aiAdviceEnabled = true,
    this.profilePhotoUrl,
    this.language = 'fr',
  });

  UserModel copyWith({
    String? uid,
    String? email,
    String? name,
    double? monthlyBudget,
    DateTime? createdAt,
    bool? aiAdviceEnabled,
    String? profilePhotoUrl,
    String? language,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      name: name ?? this.name,
      monthlyBudget: monthlyBudget ?? this.monthlyBudget,
      createdAt: createdAt ?? this.createdAt,
      aiAdviceEnabled: aiAdviceEnabled ?? this.aiAdviceEnabled,
      profilePhotoUrl: profilePhotoUrl ?? this.profilePhotoUrl,
      language: language ?? this.language,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'monthlyBudget': monthlyBudget,
      'createdAt': createdAt.toIso8601String(),
      'aiAdviceEnabled': aiAdviceEnabled,
      'profilePhotoUrl': profilePhotoUrl,
      'language': language,
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
      profilePhotoUrl: map['profilePhotoUrl'],
      language: map['language'] ?? 'fr',
    );
  }

  @override
  String toString() {
    return 'UserModel(uid: $uid, email: $email, name: $name, monthlyBudget: $monthlyBudget, createdAt: $createdAt, aiAdviceEnabled: $aiAdviceEnabled)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel &&
        other.uid == uid &&
        other.email == email &&
        other.name == name &&
        other.monthlyBudget == monthlyBudget &&
        other.createdAt == createdAt &&
        other.aiAdviceEnabled == aiAdviceEnabled &&
        other.profilePhotoUrl == profilePhotoUrl &&
        other.language == language;
  }

  @override
  int get hashCode {
    return uid.hashCode ^
        email.hashCode ^
        name.hashCode ^
        monthlyBudget.hashCode ^
        createdAt.hashCode ^
        aiAdviceEnabled.hashCode ^
        profilePhotoUrl.hashCode ^
        language.hashCode;
  }
}
