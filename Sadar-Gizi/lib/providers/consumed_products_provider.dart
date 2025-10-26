import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';

class ConsumedProductProvider with ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  final List<Product> _consumedProducts = [];
  List<Product> get consumedProducts => _consumedProducts;

  // User info login sekarang
  Map<String, dynamic>? _currentUser;
  Map<String, dynamic>? get currentUser => _currentUser;

  // List produk hari ini
  List<Product> get todayProducts {
    final today = DateTime.now();
    return _consumedProducts.where((p) =>
        p.consumedDate != null &&
        p.consumedDate!.year == today.year &&
        p.consumedDate!.month == today.month &&
        p.consumedDate!.day == today.day).toList();
  }

  // List konsumsi gula 7 hari terakhir
  List<double> get weeklySugar {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 6));
    List<double> sugarList = [];

    for (int i = 0; i < 7; i++) {
      final day = weekAgo.add(Duration(days: i));
      final dailyProducts = _consumedProducts.where((p) =>
        p.consumedDate != null &&
        p.consumedDate!.year == day.year &&
        p.consumedDate!.month == day.month &&
        p.consumedDate!.day == day.day).toList();

      double dailySugar = 0;
      for (var p in dailyProducts) {
        dailySugar += _parseDouble(p.gula);
      }
      sugarList.add(dailySugar);
    }
    return sugarList;
  }

  // ========== TAMBAHAN: HITUNG TOTAL NUTRISI HARI INI ==========
  Map<String, double> getTodayNutrition() {
    double totalKalori = 0;
    double totalGula = 0;
    double totalGaram = 0;
    double totalLemak = 0;
    double totalProtein = 0;
    double totalSerat = 0;
    double totalKarbo = 0;

    for (var product in todayProducts) {
      totalKalori += _parseDouble(product.kalori);
      totalGula += _parseDouble(product.gula);
      totalGaram += _parseDouble(product.garam);
      totalLemak += _parseDouble(product.lemak);
      totalProtein += _parseDouble(product.protein);
      totalSerat += _parseDouble(product.serat);
      totalKarbo += _parseDouble(product.karbo);
    }

    return {
      'kalori': totalKalori,
      'gula': totalGula,
      'garam': totalGaram,
      'lemak': totalLemak,
      'protein': totalProtein,
      'serat': totalSerat,
      'karbo': totalKarbo,
    };
  }

  // Helper untuk parse string/dynamic ke double
  double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    
    if (value is double) return value;
    if (value is int) return value.toDouble();
    
    if (value is String) {
      try {
        // Hapus karakter non-numerik kecuali titik dan koma
        String cleaned = value.replaceAll(RegExp(r'[^\d.,]'), '');
        cleaned = cleaned.replaceAll(',', '.');
        return double.tryParse(cleaned) ?? 0.0;
      } catch (e) {
        return 0.0;
      }
    }
    
    return 0.0;
  }

  // Ambil semua consumed products untuk user tertentu
  Future<void> fetchConsumedProducts(String uid) async {
    try {
      final snapshot = await _db
          .collection('consumedProducts')
          .where('uid', isEqualTo: uid)
          .orderBy('scanDate', descending: true)
          .get();

      final data = snapshot.docs.map((doc) {
        final product = Product.fromMap(doc.data());
        product.id = doc.id;
        return product;
      }).toList();

      _consumedProducts
        ..clear()
        ..addAll(data);

      notifyListeners();
    } catch (e) {
      print('Error fetching consumed products: $e');
    }
  }

  // Ambil produk yang dikonsumsi HARI INI
  Future<void> fetchTodayConsumedProducts(String uid) async {
    try {
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final snapshot = await _db
          .collection('consumedProducts')
          .where('uid', isEqualTo: uid)
          .where('consumedDate', isGreaterThanOrEqualTo: startOfDay)
          .where('consumedDate', isLessThan: endOfDay)
          .orderBy('consumedDate', descending: true)
          .get();

      final data = snapshot.docs.map((doc) {
        final product = Product.fromMap(doc.data());
        product.id = doc.id;
        return product;
      }).toList();

      _consumedProducts
        ..clear()
        ..addAll(data);

      notifyListeners();
    } catch (e) {
      print('Error fetching today products: $e');
    }
  }

  // Ambil 7 hari terakhir
  Future<void> fetchWeeklyConsumedProducts(String uid) async {
    try {
      final now = DateTime.now();
      final weekAgo = now.subtract(const Duration(days: 6));

      final snapshot = await _db
          .collection('consumedProducts')
          .where('uid', isEqualTo: uid)
          .where('consumedDate', isGreaterThanOrEqualTo: weekAgo)
          .orderBy('consumedDate', descending: false)
          .get();

      final data = snapshot.docs.map((doc) {
        final product = Product.fromMap(doc.data());
        product.id = doc.id;
        return product;
      }).toList();

      _consumedProducts
        ..clear()
        ..addAll(data);

      notifyListeners();
    } catch (e) {
      print('Error fetching weekly products: $e');
    }
  }

  // Simpan info user
  void setCurrentUser(Map<String, dynamic> userData) {
    _currentUser = userData;
    notifyListeners();
  }

  // Pindahkan product ke consumedProducts
  Future<void> moveProductToConsumed(Product product, {Function? onMoved}) async {
    try {
      final consumedDate = DateTime.now();
      final productMap = product.toMap();
      productMap['consumedDate'] = consumedDate;

      // Simpan ke collection consumedProducts
      await _db.collection('consumedProducts').doc(product.id).set(productMap);
      
      // Hapus dari collection products
      await _db.collection('products').doc(product.id).delete();

      // Update local list
      product.consumedDate = consumedDate;
      _consumedProducts.add(product);

      if (onMoved != null) onMoved();
      notifyListeners();
    } catch (e) {
      print('Error move product: $e');
      rethrow;
    }
  }

  // Method tambahan: Hapus consumed product
  Future<void> deleteConsumedProduct(String productId) async {
    try {
      await _db.collection('consumedProducts').doc(productId).delete();
      _consumedProducts.removeWhere((p) => p.id == productId);
      notifyListeners();
    } catch (e) {
      print('Error deleting consumed product: $e');
      rethrow;
    }
  }

  // Clear local data (untuk logout)
  void clearData() {
    _consumedProducts.clear();
    _currentUser = null;
    notifyListeners();
  }
}