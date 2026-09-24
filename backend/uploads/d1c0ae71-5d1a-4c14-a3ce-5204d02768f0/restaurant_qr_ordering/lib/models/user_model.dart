import 'package:cloud_firestore/cloud_firestore.dart';

/// Roles supported by the system.
enum UserRole { customer, chef, admin }

UserRole userRoleFromString(String value) {
  return UserRole.values.firstWhere(
    (e) => e.name == value,
    orElse: () => UserRole.customer,
  );
}

/// Represents an application user (chef / admin - customers are anonymous).
class UserModel {
  final String userId;
  final String name;
  final String email;
  final UserRole role;
  final String? fcmToken;
  final DateTime createdAt;

  const UserModel({
    required this.userId,
    required this.name,
    required this.email,
    required this.role,
    this.fcmToken,
    required this.createdAt,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    return UserModel(
      userId: id,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      role: userRoleFromString(map['role'] ?? 'customer'),
      fcmToken: map['fcmToken'],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'role': role.name,
      'fcmToken': fcmToken,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
