import 'package:flutter/material.dart';
import 'package:project_capstone_1/providers/consumed_products_provider.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:project_capstone_1/widgets/navbar_widget.dart';
import '../providers/product_provider.dart';
import '../models/product_model.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  Color getGradeColor(String grade) {
    switch (grade.toUpperCase()) {
      case "A":
        return Colors.green;
      case "B":
        return Colors.lightGreen;
      case "C":
        return Colors.orange;
      case "D":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  void initState() {
    super.initState();
    final uid = FirebaseAuth.instance.currentUser!.uid;
    Provider.of<ProductProvider>(context, listen: false).fetchProductsByUser(uid);
  }

  // Fungsi untuk membangun teks nutrisi lengkap beserta nilainya
  List<String> _buildNutritionList(Product product) {
    return [
      'Gula: ${product.gula}',
      'Garam: ${product.garam}',
      'Lemak: ${product.lemak}',
      'Protein: ${product.protein}',
      'Serat: ${product.serat}',
      'Kalori: ${product.kalori}',
      'Karbo: ${product.karbo}',
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBE19D),
      bottomNavigationBar: const CustomNavBar(selectedIndex: 0),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              const Text(
                "Product List",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F1724),
                ),
              ),
              const SizedBox(height: 20),

              // Expanded untuk scrollable list
              Expanded(
                child: Consumer<ProductProvider>(
                  builder: (context, productProvider, _) {
                    final userProducts = productProvider.products;

                    if (userProducts.isEmpty) {
                      return const Center(
                        child: Text("Belum ada produk yang discan."),
                      );
                    }

                    return SingleChildScrollView(
                      child: Column(
                        children: userProducts.map((product) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                // GAMBAR PRODUK
                                ClipRRect(
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(18),
                                    bottomLeft: Radius.circular(18),
                                  ),
                                  child: Image.network(
                                    product.imageUrl,
                                    width: 100,
                                    height: 100,
                                    fit: BoxFit.cover,
                                  ),
                                ),

                                // INFO PRODUK
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // Tanggal Scan
                                        Text(
                                          product.scanDate
                                              .toLocal()
                                              .toString()
                                              .split(' ')[0],
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                        const SizedBox(height: 6),

                                        // Grade & Nutrisi
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            // NUTRITION GRADE
                                            CircleAvatar(
                                              radius: 10,
                                              backgroundColor:
                                                  getGradeColor(product.nutriGrade),
                                              child: Text(
                                                product.nutriGrade,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 6),

                                            // NUTRISI
                                            Wrap(
                                              spacing: 6,
                                              runSpacing: 4,
                                              children: _buildNutritionList(product)
                                                  .map((nutrient) => Text(
                                                        nutrient,
                                                        style: const TextStyle(
                                                          fontSize: 12,
                                                        ),
                                                      ))
                                                  .toList(),
                                            ),
                                          ],
                                        ),

                                        // Tombol aksi
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
                                            IconButton(
                                              icon: const Icon(Icons.delete,
                                                  color: Colors.redAccent),
                                              onPressed: () {
                                                Provider.of<ProductProvider>(context,
                                                        listen: false)
                                                    .deleteProduct(product.id!);
                                              },
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.check_circle,
                                                  color: Colors.green),
                                              onPressed: () async {
                                                final provider = Provider.of<ConsumedProductProvider>(context, listen: false);
                                                await provider.moveProductToConsumed(
                                                  product,
                                                  onMoved: () {
                                                    // hapus dari list lokal ProductListScreen supaya langsung hilang
                                                    setState(() {
                                                      Provider.of<ProductProvider>(context, listen: false)
                                                          .products
                                                          .removeWhere((p) => p.id == product.id);
                                                    });
                                                  },
                                                );
                                              },
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
