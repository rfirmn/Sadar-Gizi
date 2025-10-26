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
        dailySugar += p.gula;
      }
      sugarList.add(dailySugar);
    }
    return sugarList;
  }

  // Ambil semua consumed products untuk user tertentu
  Future<void> fetchConsumedProducts(String uid) async {
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
  }

  // Ambil produk yang dikonsumsi HARI INI
  Future<void> fetchTodayConsumedProducts(String uid) async {
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
  }

  // Ambil 7 hari terakhir
  Future<void> fetchWeeklyConsumedProducts(String uid) async {
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

      await _db.collection('consumedProducts').doc(product.id).set(productMap);
      await _db.collection('products').doc(product.id).delete();

      _consumedProducts.add(product..consumedDate = consumedDate);

      if (onMoved != null) onMoved();
      notifyListeners();
    } catch (e) {
      print('Error move product: $e');
      rethrow;
    }
  }
}
