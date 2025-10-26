import 'package:project_capstone_1/models/product_model.dart';

class NutritionService {
  // BMR
  static double hitungBMR({
    required double berat,
    required double tinggi,
    required int usia,
    required String gender,
  }) {
    if (gender.toLowerCase() == "pria") {
      return (10 * berat) + (6.25 * tinggi) - (5 * usia) + 5;
    } else {
      return (10 * berat) + (6.25 * tinggi) - (5 * usia) - 161;
    }
  }

  // TDEE
  static double hitungTDEE(double bmr, String aktivitas) {
    switch (aktivitas.toLowerCase()) {
      case "sedentari":
        return bmr * 1.2;
      case "ringan":
        return bmr * 1.375;
      case "sedang":
        return bmr * 1.55;
      case "berat":
        return bmr * 1.725;
      case "sangat berat":
        return bmr * 1.9;
      default:
        return bmr * 1.55;
    }
  }

  // Target nutrisi berdasarkan kalori (TDEE)
  static Map<String, double> hitungTargetNutrisi(double tdee) {
    return {
      "Carbs": tdee * 0.6 / 4, // 1g karbo = 4 kcal
      "Protein": tdee * 0.15 / 4, // 1g protein = 4 kcal
      "Fat": tdee * 0.15 / 9, // 1g fat = 9 kcal
      "Sugar": tdee * 0.10 / 4, // 1g gula = 4 kcal
      "Natrium": 2300, // max 2.3g
    };
  }

  // Total konsumsi nutrisi hari ini
  static Map<String, double> totalKonsumsi(List<Product> products) {
    double carbs = 0, protein = 0, fat = 0, sugar = 0, natrium = 0;
    for (var p in products) {
      carbs += p.karbo;
      protein += p.protein;
      fat += p.lemak;
      sugar += p.gula;
      natrium += p.garam;
    }
    return {
      "Carbs": carbs,
      "Protein": protein,
      "Fat": fat,
      "Sugar": sugar,
      "Natrium": natrium,
    };
  }

  // Sisa gula hari ini
  static double sisaGula(double targetGula, double konsumsiGula) {
    return targetGula - konsumsiGula;
  }

  // Persentase konsumsi
  static double persenKonsumsi(double konsumsi, double target) {
    return (konsumsi / target).clamp(0.0, 1.0);
  }

  // Tren gula mingguan
  static double rataRataMingguan(List<double> data) {
    if (data.isEmpty) return 0;
    return data.reduce((a, b) => a + b) / data.length;
  }

  static String pesanTrenGula(double rata2, double targetGula) {
    double persen = rata2 / targetGula * 100;
    if (persen > 100) {
      return '⚠️ Konsumsi gula melebihi batas harian! Coba kurangi minuman manis.';
    } else if (persen >= 80) {
      return '😊 Konsumsi gula mendekati batas, tetap jaga pola makan ya.';
    } else {
      return '👍 Bagus! Konsumsi gula kamu masih dalam batas aman minggu ini.';
    }
  }
}
