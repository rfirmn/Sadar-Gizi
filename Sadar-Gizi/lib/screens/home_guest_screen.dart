import 'package:flutter/material.dart';
import 'package:project_capstone_1/screens/login_screen.dart';
import 'package:project_capstone_1/screens/scan_screen.dart';

import 'package:project_capstone_1/widgets/navbar_widget.dart';

class HomeGuestScreen extends StatelessWidget {
  const HomeGuestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBE19D),
      bottomNavigationBar: const CustomNavBar(selectedIndex: 0),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const SizedBox(height: 12),

              // TAUKAH KAMU
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Tahukah kamu?",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Color(0xFF0F1724),
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      "Banyak makanan kemasan mengandung gula tersembunyi yang bisa melebihi batas harian tanpa kita sadari.",
                      style: TextStyle(fontSize: 12, color: Colors.black87),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Image.asset(
                          "assets/images/illustrations/Order-Groceries-Online-1-Streamline-Milano.png", 
                          height: 110,
                        ),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "SadarGizi",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0F1724),
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                "Bantu kamu mengenali kadar gula dan memantau asupan harian dengan mudah!",
                                style: TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // NUTRITION TRACKING
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Nutrition Tracking",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: Color(0xFF0F1724),
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            "Pantau nutrisi harianmu dan capai target kesehatan. Login untuk mulai!",
                            style: TextStyle(fontSize: 12),
                          ),
                          const SizedBox(height: 10),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const LoginScreen(),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF6B7B48),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 15,
                              ),
                            ),
                            child: const Text(
                              "Login",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    
                    Image.asset(
                      "assets/images/illustrations/Zero-Tasks-3-Streamline-Milano.png",
                      height: 120,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // SCAN NUTRITION FACT
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      "assets/images/illustrations/QR-Code-Purchase-3-Streamline-Milano.png", // ganti sesuai nama file
                      height: 90,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Scan Nutrition Fact",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: Color(0xFF0F1724),
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            "Pindai label makanan untuk lihat kadar gulanya secara instan.",
                            style: TextStyle(fontSize: 12),
                          ),
                          const SizedBox(height: 10),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const ScanScreen(),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF6B7B48),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 17,
                              ),
                            ),
                            child: const Text(
                              "Scan",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}