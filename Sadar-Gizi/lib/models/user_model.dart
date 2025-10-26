import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String name;
  final String gender;
  final DateTime birthDate; 
  final double heightCm;
  final double weightKg;
  final String activity;
  final String email;

  UserModel({
    required this.name,
    required this.gender,
    required this.birthDate,
    required this.heightCm,
    required this.weightKg,
    required this.activity,
    required this.email,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'gender': gender,
      'birthDate': birthDate,
      'heightCm': heightCm,
      'weightKg': weightKg,
      'activity': activity,
      'email': email,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    DateTime parsedBirthDate;

    if (map['birthDate'] is Timestamp) {
      parsedBirthDate = (map['birthDate'] as Timestamp).toDate();
    } else if (map['birthDate'] is DateTime) {
      parsedBirthDate = map['birthDate'] as DateTime;
    } else {
      parsedBirthDate = DateTime.now(); // fallback kalau null
    }

    return UserModel(
      name: map['name'] ?? '',
      gender: map['gender'] ?? 'Perempuan',
      birthDate: parsedBirthDate,
      heightCm: (map['heightCm'] ?? 0).toDouble(),
      weightKg: (map['weightKg'] ?? 0).toDouble(),
      activity: map['activity'] ?? 'Sedang',
      email: map['email'] ?? '',
    );
  }
}
