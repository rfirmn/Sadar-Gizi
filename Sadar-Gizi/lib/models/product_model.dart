import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  String? id; // ID dokumen Firestore
  String uid;
  double gula;
  double garam;
  double lemak;
  double protein;
  double serat;
  double kalori;
  double karbo;
  String nutriGrade;
  String imageUrl;
  DateTime scanDate;
   DateTime? consumedDate;

  Product({
    this.id,
    required this.uid,
    required this.gula,
    required this.garam,
    required this.lemak,
    required this.protein,
    required this.serat,
    required this.kalori,
    required this.karbo,
    required this.nutriGrade,
    required this.imageUrl,
    required this.scanDate,
    required this.consumedDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'gula': gula,
      'garam': garam,
      'lemak': lemak,
      'protein': protein,
      'serat': serat,
      'kalori': kalori,
      'karbo': karbo,
      'nutriGrade': nutriGrade,
      'imageUrl': imageUrl,
      'scanDate': scanDate.toIso8601String(),
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      uid: map['uid'] ?? '',
      gula: (map['gula'] ?? 0).toDouble(),
      garam: (map['garam'] ?? 0).toDouble(),
      lemak: (map['lemak'] ?? 0).toDouble(),
      protein: (map['protein'] ?? 0).toDouble(),
      serat: (map['serat'] ?? 0).toDouble(),
      kalori: (map['kalori'] ?? 0).toDouble(),
      karbo: (map['karbo'] ?? 0).toDouble(),
      nutriGrade: map['nutriGrade'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      scanDate: map['scanDate'] is Timestamp
          ? (map['scanDate'] as Timestamp).toDate()
          : DateTime.parse(map['scanDate']),
      consumedDate: map['consumedDate'] != null
          ? map['consumedDate'] is Timestamp
              ? (map['consumedDate'] as Timestamp).toDate()
              : DateTime.parse(map['consumedDate'])
          : null,
    );
  }


}
