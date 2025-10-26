import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:project_capstone_1/providers/consumed_products_provider.dart';
import 'package:provider/provider.dart';
import 'package:project_capstone_1/widgets/navbar_widget.dart';
import 'package:project_capstone_1/models/product_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeUserScreen extends StatefulWidget {
  const HomeUserScreen({super.key});

  @override
  State<HomeUserScreen> createState() => _HomeUserScreenState();
}

class _HomeUserScreenState extends State<HomeUserScreen> {
  // Dummy data user
  final double berat = 55;
  final double tinggi = 160;
  final int usia = 21;
  final String gender = "wanita";
  final String aktivitas = "sedang";

  // Target nutrisi harian
  final double targetGula = 50;
  final double targetKarbo = 250;
  final double targetProtein = 80;
  final double targetGaram = 2.3; // dalam gram (2300mg)
  final double targetLemak = 70;

  @override
  void initState() {
    super.initState();

    // Ambil produk yang dikonsumsi hari ini dan mingguan
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      final provider = Provider.of<ConsumedProductProvider>(context, listen: false);
      provider.fetchTodayConsumedProducts(uid);
      provider.fetchWeeklyConsumedProducts(uid);
    });
  }

  double hitungBMR() {
    if (gender == "pria") {
      return (10 * berat) + (6.25 * tinggi) - (5 * usia) + 5;
    } else {
      return (10 * berat) + (6.25 * tinggi) - (5 * usia) - 161;
    }
  }

  double getActivityFactor(String aktivitas) {
    switch (aktivitas.toLowerCase()) {
      case "sedentari":
        return 1.2;
      case "ringan":
        return 1.375;
      case "sedang":
        return 1.55;
      case "berat":
        return 1.725;
      case "sangat berat":
        return 1.9;
      default:
        return 1.55;
    }
  }

  String getWeeklyTrendMessage(List<double> data, double target) {
    if (data.isEmpty) return "Belum ada data konsumsi gula minggu ini.";
    
    double avg = data.reduce((a, b) => a + b) / data.length;
    if (avg < target * 0.8) {
      return "Konsumsi gulamu masih di bawah target, tetap jaga asupan seimbang!";
    } else if (avg <= target) {
      return "Konsumsi gulamu sudah baik minggu ini, pertahankan ya!";
    } else {
      return "Konsumsi gulamu melebihi batas! Kurangi minuman dan camilan manis.";
    }
  }

  Color getGradeColor(String grade) {
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

  List<String> _buildNutritionList(Product product) {
    final List<String> nutrients = [];
    nutrients.add("Kalori: ${product.kalori} kcal");
    nutrients.add("Gula: ${product.gula} g");
    nutrients.add("Garam: ${product.garam} g");
    nutrients.add("Lemak: ${product.lemak} g");
    nutrients.add("Protein: ${product.protein} g");
    nutrients.add("Serat: ${product.serat} g");
    return nutrients;
  }

  @override
  Widget build(BuildContext context) {
    final double bmr = hitungBMR();
    final double tdee = bmr * getActivityFactor(aktivitas);

    return Scaffold(
      backgroundColor: const Color(0xFFFBE19D),
      bottomNavigationBar: const CustomNavBar(selectedIndex: 0),
      body: SafeArea(
        child: Consumer<ConsumedProductProvider>(
          builder: (context, provider, _) {
            // Ambil data nutrisi real-time
            final todayNutrition = provider.getTodayNutrition();
            final weeklySugarData = provider.weeklySugar;
            
            final double konsumsiGula = todayNutrition['gula'] ?? 0;
            final double konsumsiKarbo = todayNutrition['karbo'] ?? 0;
            final double konsumsiProtein = todayNutrition['protein'] ?? 0;
            final double konsumsiGaram = todayNutrition['garam'] ?? 0;
            final double konsumsiLemak = todayNutrition['lemak'] ?? 0;
            
            final double persenGula = targetGula > 0 ? konsumsiGula / targetGula : 0;
            final String pesanTren = getWeeklyTrendMessage(weeklySugarData, targetGula);

            // Update nutrisi map dengan data real
            final Map<String, Map<String, double>> nutrisiRealtime = {
              "Carbs": {"consumed": konsumsiKarbo, "target": targetKarbo},
              "Protein": {"consumed": konsumsiProtein, "target": targetProtein},
              "Natrium": {"consumed": konsumsiGaram, "target": targetGaram},
              "Fat": {"consumed": konsumsiLemak, "target": targetLemak},
              "Sugar": {"consumed": konsumsiGula, "target": targetGula},
            };

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),

                  // ========== GULA HARI INI (REAL DATA) ==========
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Sisa gula hari ini",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Color(0xFF0F1724)),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                "${(targetGula - konsumsiGula).toStringAsFixed(1)} g",
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: konsumsiGula > targetGula 
                                      ? Colors.red 
                                      : Colors.black,
                                ),
                              ),
                              Text("Target ${targetGula.toStringAsFixed(0)} g"),
                              Text("Terkonsumsi ${konsumsiGula.toStringAsFixed(1)} g"),
                            ],
                          ),
                        ),
                        CircularPercentIndicator(
                          radius: 45,
                          lineWidth: 8,
                          percent: persenGula.clamp(0.0, 1.0),
                          progressColor: persenGula > 1.0 
                              ? Colors.red 
                              : const Color(0xFF0F5BCA),
                          backgroundColor: Colors.grey.shade200,
                          circularStrokeCap: CircularStrokeCap.round,
                          center: Text("${(persenGula * 100).toStringAsFixed(0)}%"),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ========== NUTRITION TRACKING (REAL DATA) ==========
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
                          "Nutrition Tracking",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: Color(0xFF0F1724)),
                        ),
                        const SizedBox(height: 12),
                        ...nutrisiRealtime.entries.map((entry) {
                          final label = entry.key;
                          final consumed = entry.value["consumed"]!;
                          final target = entry.value["target"]!;
                          final percentNutrisi = target > 0 ? (consumed / target).clamp(0.0, 1.0) : 0.0;

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  label,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Expanded(
                                      child: LinearPercentIndicator(
                                        lineHeight: 8,
                                        percent: percentNutrisi,
                                        progressColor: consumed > target 
                                            ? Colors.red 
                                            : Colors.blueAccent,
                                        backgroundColor: Colors.grey.shade200,
                                        barRadius: const Radius.circular(10),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      "${consumed.toStringAsFixed(1)} / ${target.toStringAsFixed(0)}",
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: consumed > target 
                                            ? Colors.red 
                                            : Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ========== TREN GULA MINGGUAN (REAL DATA) ==========
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
                          "Tren Gula Mingguan",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: Color(0xFF0F1724)),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 160,
                          child: weeklySugarData.isEmpty
                              ? const Center(
                                  child: Text("Belum ada data konsumsi minggu ini"))
                              : BarChart(
                                  BarChartData(
                                    gridData: FlGridData(
                                      show: true,
                                      drawHorizontalLine: true,
                                      horizontalInterval: 10,
                                      getDrawingHorizontalLine: (value) => FlLine(
                                        color: value == targetGula
                                            ? Colors.redAccent
                                            : Colors.grey.shade300,
                                        strokeWidth: value == targetGula ? 2 : 0.5,
                                        dashArray: value == targetGula ? [6, 6] : null,
                                      ),
                                    ),
                                    borderData: FlBorderData(show: false),
                                    titlesData: FlTitlesData(
                                      bottomTitles: AxisTitles(
                                        sideTitles: SideTitles(
                                          showTitles: true,
                                          getTitlesWidget: (value, _) {
                                            const days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
                                            return Text(days[value.toInt() % 7]);
                                          },
                                        ),
                                      ),
                                      leftTitles: AxisTitles(
                                          sideTitles: SideTitles(showTitles: false)),
                                    ),
                                    barGroups: List.generate(weeklySugarData.length, (i) {
                                      return BarChartGroupData(
                                        x: i,
                                        barRods: [
                                          BarChartRodData(
                                            toY: weeklySugarData[i],
                                            color: weeklySugarData[i] > targetGula
                                                ? Colors.red
                                                : Colors.blueAccent,
                                            width: 14,
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                        ],
                                      );
                                    }),
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ========== PESAN TREN ==========
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF8D6),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline, color: Colors.orange),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            pesanTren,
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ======== DAILY CONSUMPTION ==========
                  const Text(
                    "Daily Consumption",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Color(0xFF0F1724)),
                  ),
                  const SizedBox(height: 10),

                  provider.todayProducts.isEmpty
                      ? Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Center(
                            child: Text("Belum ada konsumsi hari ini."),
                          ),
                        )
                      : Column(
                          children: provider.todayProducts.map((product) {
                            return Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(18),
                                      bottomLeft: Radius.circular(18),
                                    ),
                                    child: product.imageUrl.isNotEmpty
                                        ? Image.network(
                                            product.imageUrl,
                                            width: 100,
                                            height: 100,
                                            fit: BoxFit.cover,
                                          )
                                        : const Icon(Icons.fastfood, size: 100),
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.all(10),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          CircleAvatar(
                                            radius: 12,
                                            backgroundColor: getGradeColor(product.nutriGrade),
                                            child: Text(
                                              product.nutriGrade,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Wrap(
                                            spacing: 6,
                                            runSpacing: 4,
                                            children: _buildNutritionList(product)
                                                .map((nutrient) => Text(
                                                      nutrient,
                                                      style: const TextStyle(fontSize: 12),
                                                    ))
                                                .toList(),
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
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}