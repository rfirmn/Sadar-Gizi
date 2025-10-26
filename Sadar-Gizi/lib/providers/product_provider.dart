import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';

class ProductProvider with ChangeNotifier {
  final List<Product> _products = [];

  List<Product> get products => _products;

  // Tambahkan map id dokumen
  final Map<String, String> _docIds = {}; // key = uid + timestamp atau product hash, value = docId

  Future<void> addProduct(Product product) async {
    // Simpan ke Firestore dan ambil docId
    final docRef = await FirebaseFirestore.instance
        .collection('products')
        .add(product.toMap());

    // Simpan docId di product
    product.id = docRef.id; // pastikan Product punya property id
    _products.add(product);
    notifyListeners();
  }

  Future<void> deleteProduct(String docId) async {
    await FirebaseFirestore.instance
        .collection('products')
        .doc(docId)
        .delete();

    _products.removeWhere((p) => p.id == docId);
    notifyListeners();
  }

  Future<void> fetchProductsByUser(String uid) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('products')
        .where('uid', isEqualTo: uid)
        .orderBy('scanDate', descending: true)
        .get();

    final data = snapshot.docs.map((doc) {
      final product = Product.fromMap(doc.data());
      product.id = doc.id; // simpan id dokumen untuk delete/update
      return product;
    }).toList();

    _products
      ..clear()
      ..addAll(data);

    notifyListeners();
  }
}
