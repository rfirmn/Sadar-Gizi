import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:project_capstone_1/screens/list_product_screen.dart';
import 'package:provider/provider.dart';
import '../models/product_model.dart';
import '../providers/product_provider.dart';
import '../services/supabase_service.dart';

class ScanResultScreen extends StatefulWidget {
  final String imagePath;
  final Map<String, dynamic>? inferenceResult; // hasil dari OCR/YOLO (optional)

  const ScanResultScreen({
    super.key,
    required this.imagePath,
    this.inferenceResult,
  });

  @override
  State<ScanResultScreen> createState() => _ScanResultScreenState();
}

class _ScanResultScreenState extends State<ScanResultScreen> {
  bool _isLoading = false;

  Color _getBackgroundColor(String grade) {
    switch (grade.toUpperCase()) {
      case 'A':
        return const Color.fromARGB(255, 44, 87, 45);
      case 'B':
        return const Color.fromARGB(255, 147, 202, 142);
      case 'C':
        return Colors.orange.shade200;
      case 'D':
        return const Color.fromARGB(255, 160, 71, 71);
      default:
        return Colors.grey.shade300;
    }
  }

  String _getNutriGradeImage(String grade) {
    switch (grade.toUpperCase()) {
      case 'A':
        return 'assets/images/nutri_grade_labels/A-nutri-grade.png';
      case 'B':
        return 'assets/images/nutri_grade_labels/B-nutri-grade.png';
      case 'C':
        return 'assets/images/nutri_grade_labels/C-nutri-grade.png';
      case 'D':
        return 'assets/images/nutri_grade_labels/D-nutri-grade.png';
      default:
        return 'assets/images/nutri_grade_labels/default.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    // Parsing hasil OCR/inference atau gunakan dummy data
    final pred = widget.inferenceResult ?? {};
    
    double parseOrZero(dynamic val) {
      if (val == null) return 0.0;
      if (val is num) return val.toDouble();
      return double.tryParse(val.toString()) ?? 0.0;
    }

    // Jika ada inference result, gunakan data dari OCR
    // Jika tidak, gunakan dummy data
    final Product productData;
    
    if (widget.inferenceResult != null) {
      // Data dari OCR/YOLO
      productData = Product(
        uid: FirebaseAuth.instance.currentUser?.uid ?? "guest",
        gula: parseOrZero(pred["gula"]),
        garam: parseOrZero(pred["garam"]),
        lemak: parseOrZero(pred["lemak"]),
        protein: parseOrZero(pred["protein"]),
        serat: parseOrZero(pred["serat"]),
        kalori: parseOrZero(pred["kalori"]),
        karbo: parseOrZero(pred["karbo"]),
        nutriGrade: pred["nutriGrade"] ?? "B",
        imageUrl: widget.imagePath,
        scanDate: DateTime.now(),
        consumedDate: null,
      );
    } else {
      // Dummy data (untuk barcode atau mode manual)
      productData = Product(
        uid: FirebaseAuth.instance.currentUser!.uid,
        gula: 20,
        garam: 10,
        lemak: 5,
        protein: 14,
        serat: 0,
        kalori: 270,
        karbo: 0,
        nutriGrade: "B",
        imageUrl: widget.imagePath,
        scanDate: DateTime.now(),
        consumedDate: null,
      );
    }

    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    final bgColor = _getBackgroundColor(productData.nutriGrade);
    final nutriImage = _getNutriGradeImage(productData.nutriGrade);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text(
          'HASIL SCAN',
          style: TextStyle(
            color: Colors.white,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.black87,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.green))
          : SingleChildScrollView(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 6,
                          offset: const Offset(2, 3),
                        )
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Image Preview
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: File(widget.imagePath).existsSync()
                              ? Image.file(
                                  File(widget.imagePath),
                                  height: 150,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                )
                              : Image.asset(
                                  widget.imagePath,
                                  height: 150,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                        ),
                        const SizedBox(height: 16),

                        // Nutri Grade & Scan Date
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Image.asset(
                              nutriImage,
                              height: 40,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Scan date: ${productData.scanDate.toLocal().toString().split(' ')[0]}",
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Nutrition Facts
                        const Text(
                          "Nutrition Facts",
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildNutritionRow("Gula", productData.gula),
                        _buildNutritionRow("Garam", productData.garam),
                        _buildNutritionRow("Lemak jenuh", productData.lemak),
                        _buildNutritionRow("Protein", productData.protein),
                        _buildNutritionRow("Kalori", productData.kalori),
                        _buildNutritionRow("Karbo", productData.karbo),
                        _buildNutritionRow("Serat", productData.serat),

                        const SizedBox(height: 25),

                        // Action Buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton(
                              onPressed: () => Navigator.pop(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blueAccent,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text("Back"),
                            ),
                            ElevatedButton(
                              onPressed: () async {
                                setState(() => _isLoading = true);
                                final supabaseService = SupabaseService();

                                // Upload ke Supabase
                                final imageUrl = await supabaseService.uploadImage(
                                  File(widget.imagePath),
                                );

                                if (imageUrl == null) {
                                  setState(() => _isLoading = false);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("Upload gambar gagal!"),
                                    ),
                                  );
                                  return;
                                }

                                // Simpan ke Firebase dengan imageUrl dari Supabase
                                final product = Product(
                                  uid: FirebaseAuth.instance.currentUser!.uid,
                                  gula: productData.gula,
                                  garam: productData.garam,
                                  lemak: productData.lemak,
                                  protein: productData.protein,
                                  serat: productData.serat,
                                  kalori: productData.kalori,
                                  karbo: productData.karbo,
                                  nutriGrade: productData.nutriGrade,
                                  imageUrl: imageUrl, // URL dari Supabase
                                  scanDate: productData.scanDate,
                                  consumedDate: productData.consumedDate,
                                );

                                await productProvider.addProduct(product);
                                setState(() => _isLoading = false);

                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Produk berhasil ditambahkan!"),
                                  ),
                                );
                                
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const ProductListScreen(),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text("Add"),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildNutritionRow(String label, double value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 15,
              color: Colors.black87,
            ),
          ),
          Text(
            value.toStringAsFixed(0),
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}