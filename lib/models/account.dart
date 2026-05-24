// lib/models/account.dart
import 'person.dart';

class Account {
  final int id;
  final String username;
  final String passwordHash;
  final Person? person;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool active;

  Account({
    required this.id,
    required this.username,
    required this.passwordHash,
    this.person,
    this.createdAt,
    this.updatedAt,
    required this.active,
  });

  // Optional constructor for login/authentication
  Account.login({
    required this.username,
    required this.passwordHash,
  })  : id = 0,
        person = null,
        createdAt = null,
        updatedAt = null,
        active = true;

  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      id: json['id'] as int,
      username: json['username'] as String,
      passwordHash: json['password_hash'] as String,
      person: json['person'] != null
          ? Person.fromJson(json['person'])
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      active: json['active'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'password_hash': passwordHash,
      'person': person?.toJson(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'active': active,
    };
  }

  @override
  String toString() {
    return 'Account('
        'id: $id, '
        'username: $username, '
        'passwordHash: $passwordHash, '
        'person: $person, '
        'createdAt: $createdAt, '
        'updatedAt: $updatedAt, '
        'active: $active'
        ')';
  }
}