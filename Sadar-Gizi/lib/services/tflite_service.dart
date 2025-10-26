import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class TFLiteService {
  late Interpreter _interpreter;
  List<String> _labels = [];

  /// Muat model YOLO dan label
  Future<void> loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset('assets/model.tflite');
      _labels = await rootBundle
          .loadString('assets/labels.txt')
          .then((value) => value.split('\n').where((e) => e.isNotEmpty).toList());
      print("✅ Model YOLO & label berhasil dimuat");
      print("📋 Labels: $_labels");
    } catch (e) {
      print("❌ Gagal memuat model: $e");
    }
  }

  /// Jalankan YOLO + OCR MLKit
  Future<Map<String, String>> analyzeImage(String imagePath) async {
    final imageBytes = File(imagePath).readAsBytesSync();
    final decoded = img.decodeImage(imageBytes)!;
    final resized = img.copyResize(decoded, width: 640, height: 640);

    // (1) Buat input YOLO
    var input = List.generate(1, (_) =>
        List.generate(640, (_) =>
            List.generate(640, (_) => List.filled(3, 0.0))));
    for (int y = 0; y < 640; y++) {
      for (int x = 0; x < 640; x++) {
        final pixel = resized.getPixel(x, y);
        input[0][y][x][0] = pixel.r / 255.0;
        input[0][y][x][1] = pixel.g / 255.0;
        input[0][y][x][2] = pixel.b / 255.0;
      }
    }

    // (2) Jalankan YOLO inference
    var output = List.filled(1 * 12 * 8400, 0.0)
        .reshape([1, 12, 8400]);
    _interpreter.run(input, output);

    // (3) Ambil deteksi label "nutrition-fact" dengan confidence threshold lebih rendah
    Map<String, dynamic>? box;
    double bestConfidence = 0.0;
    
    for (int i = 0; i < 8400; i++) {
      double x = output[0][0][i];
      double y = output[0][1][i];
      double w = output[0][2][i];
      double h = output[0][3][i];
      double conf = output[0][4][i];
      
      // Turunkan threshold untuk deteksi lebih sensitif
      if (conf > 0.25) {
        int cls = 0;
        double maxScore = 0;
        for (int j = 5; j < 12; j++) {
          if (output[0][j][i] > maxScore) {
            maxScore = output[0][j][i];
            cls = j - 5;
          }
        }

        if (cls < _labels.length) {
          String label = _labels[cls];
          print("🔍 Deteksi: $label (conf: ${conf.toStringAsFixed(2)}, class_score: ${maxScore.toStringAsFixed(2)})");
          
          // Cari label "nutrition-fact" dengan confidence tertinggi
          if (label.toLowerCase().contains("nutrition") && conf > bestConfidence) {
            bestConfidence = conf;
            box = {
              'x1': ((x - w / 2) * 640).clamp(0.0, 640.0),
              'y1': ((y - h / 2) * 640).clamp(0.0, 640.0),
              'x2': ((x + w / 2) * 640).clamp(0.0, 640.0),
              'y2': ((y + h / 2) * 640).clamp(0.0, 640.0),
            };
          }
        }
      }
    }

    if (box == null) {
      print("⚠️ Tidak ditemukan area Nutrition Facts, OCR dijalankan seluruh gambar.");
    } else {
      print("✅ Nutrition Facts ditemukan: ${box.toString()}");
    }

    // (4) Crop area Nutrition Facts
    final xMin = (box?['x1'] ?? 0.0).toInt();
    final yMin = (box?['y1'] ?? 0.0).toInt();
    final xMax = (box?['x2'] ?? 640.0).toInt();
    final yMax = (box?['y2'] ?? 640.0).toInt();

    final cropWidth = (xMax - xMin).clamp(1, resized.width);
    final cropHeight = (yMax - yMin).clamp(1, resized.height);

    final cropped = img.copyCrop(
      resized,
      x: xMin,
      y: yMin,
      width: cropWidth,
      height: cropHeight,
    );

    final tempPath = '${Directory.systemTemp.path}/cropped.png';
    File(tempPath).writeAsBytesSync(img.encodePng(cropped));

    // (5) Gunakan Google MLKit untuk OCR
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
    final inputImage = InputImage.fromFilePath(tempPath);
    final recognizedText = await textRecognizer.processImage(inputImage);
    await textRecognizer.close();

    final rawText = recognizedText.text;
    print("📄 Hasil OCR MLKit:\n$rawText");

    // (6) Ekstrak nilai nutrisi - fokus pada bagian data saja
    final result = _parseNutritionTable(rawText);
    return result;
  }

  /// Parse tabel nutrisi dengan fokus pada bagian data nilai
  Map<String, String> _parseNutritionTable(String text) {
    final result = <String, String>{
      "gula": "0",
      "garam": "0",
      "lemak": "0",
      "protein": "0",
      "kalori": "0",
      "karbo": "0",
      "serat": "0",
    };

    // Ekstrak semua angka yang berdiri sendiri (nilai nutrisi)
    final lines = text.split('\n').map((e) => e.trim()).toList();
    
    // Cari index di mana bagian nilai dimulai (setelah header)
    int dataStartIndex = -1;
    for (int i = 0; i < lines.length; i++) {
      if (lines[i].toLowerCase().contains('energi total')) {
        dataStartIndex = i;
        print("📍 Data dimulai dari baris $i: '${lines[i]}'");
        break;
      }
    }

    if (dataStartIndex == -1) {
      print("⚠️ Tidak menemukan 'Energi Total', mencari dari awal");
      dataStartIndex = 0;
    }

    // List untuk menyimpan angka yang ditemukan setelah header
    List<String> numbers = [];
    
    for (int i = dataStartIndex; i < lines.length; i++) {
      final line = lines[i];
      final lineLower = line.toLowerCase();
      
      // Skip baris yang mengandung keyword yang tidak relevan
      if (lineLower.contains('persen') || 
          lineLower.contains('kebutuhan') ||
          lineLower.contains('tinggi') ||
          lineLower.contains('rendah') ||
          lineLower.contains('barcode') ||
          line.contains('|')) {
        continue;
      }
      
      // Ambil angka dari baris yang hanya berisi angka + satuan (tanpa %)
      final numberMatch = RegExp(r'^(\d+)\s*(?:g|mg|kkal)?$').firstMatch(line);
      if (numberMatch != null) {
        final value = numberMatch.group(1)!;
        numbers.add(value);
        print("📊 Angka ditemukan: $value (baris: '$line')");
      }
      
      // Atau ambil angka dari baris yang mengandung 'kkal'
      if (lineLower.contains('kkal') && !lineLower.contains('2150')) {
        final kkalMatch = RegExp(r'(\d+)\s*kkal').firstMatch(line);
        if (kkalMatch != null && result['kalori'] == '0') {
          result['kalori'] = kkalMatch.group(1)!;
          print("✅ KALORI: ${kkalMatch.group(1)} (dari: '$line')");
        }
      }
    }

    print("\n📋 Total angka ditemukan: ${numbers.length}");
    print("   Angka: $numbers");

    // Mapping angka ke field berdasarkan urutan standar tabel nutrisi Indonesia
    // Urutan: Lemak Total, Lemak Trans, Lemak Jenuh, Kolesterol, Protein, Karbo, Serat, Gula, Garam
    
    if (numbers.length >= 7) {
      // Cari pola berdasarkan nilai yang masuk akal
      int idx = 0;
      
      // Lemak Total (biasanya 5-15g)
      if (idx < numbers.length) {
        final val = int.tryParse(numbers[idx]) ?? 0;
        if (val > 0 && val <= 20) {
          result['lemak'] = numbers[idx];
          print("✅ LEMAK: ${numbers[idx]} (index $idx)");
          idx++;
        }
      }
      
      // Skip Lemak Trans (biasanya 0)
      if (idx < numbers.length && numbers[idx] == '0') {
        idx++;
      }
      
      // Lemak Jenuh (skip)
      if (idx < numbers.length) {
        final val = int.tryParse(numbers[idx]) ?? 0;
        if (val > 0 && val <= 10) {
          idx++;
        }
      }
      
      // Kolesterol (skip, biasanya 0 atau kecil)
      if (idx < numbers.length && numbers[idx] == '0') {
        idx++;
      }
      
      // Protein
      if (idx < numbers.length) {
        result['protein'] = numbers[idx];
        print("✅ PROTEIN: ${numbers[idx]} (index $idx)");
        idx++;
      }
      
      // Karbohidrat Total
      if (idx < numbers.length) {
        final val = int.tryParse(numbers[idx]) ?? 0;
        if (val > 0 && val <= 50) {
          result['karbo'] = numbers[idx];
          print("✅ KARBO: ${numbers[idx]} (index $idx)");
          idx++;
        }
      }
      
      // Serat Pangan
      if (idx < numbers.length) {
        final val = int.tryParse(numbers[idx]) ?? 0;
        if (val >= 0 && val <= 20) {
          result['serat'] = numbers[idx];
          print("✅ SERAT: ${numbers[idx]} (index $idx)");
          idx++;
        }
      }
      
      // Gula
      if (idx < numbers.length) {
        final val = int.tryParse(numbers[idx]) ?? 0;
        if (val >= 0 && val <= 30) {
          result['gula'] = numbers[idx];
          print("✅ GULA: ${numbers[idx]} (index $idx)");
          idx++;
        }
      }
      
      // Garam (Natrium) - biasanya dalam mg (50-500)
      if (idx < numbers.length) {
        final val = int.tryParse(numbers[idx]) ?? 0;
        if (val >= 10) {
          result['garam'] = numbers[idx];
          print("✅ GARAM: ${numbers[idx]} mg (index $idx)");
        }
      }
    } else {
      print("⚠️ Angka yang ditemukan kurang dari 7, parsing mungkin tidak akurat");
    }

    print("\n📊 Hasil Final Parsing:");
    result.forEach((key, value) {
      print("   $key: $value");
    });

    return result;
  }
}