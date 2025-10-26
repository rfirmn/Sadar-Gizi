import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:project_capstone_1/screens/scan_result_screen.dart';
import 'package:project_capstone_1/services/camera_service.dart';
import 'package:project_capstone_1/services/tflite_service.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  File? _selectedImage;
  final _tfliteService = TFLiteService();

  Future<void> _pickFromGallery() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _openCamera() async {
    final cameras = await availableCameras();
    final image = await Navigator.push<File?>(
      context,
      MaterialPageRoute(
        builder: (_) => CameraService(camera: cameras.first),
      ),
    );

    if (image != null) {
      setState(() {
        _selectedImage = image;
      });
    }
  }

  Future<void> _analyzeWithNutriFact() async {
    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Pilih gambar terlebih dahulu")),
      );
      return;
    }

    // Tampilkan loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    // Muat model YOLO & OCR
    await _tfliteService.loadModel();
    final ocrResult = await _tfliteService.analyzeImage(_selectedImage!.path);

    // Tutup loading
    if (mounted) Navigator.pop(context);

    // Konversi hasil OCR menjadi data nutrisi
    final inferenceResult = _parseOCRResultToPred(ocrResult);

    // Navigasi ke hasil scan
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ScanResultScreen(
          imagePath: _selectedImage!.path,
          inferenceResult: inferenceResult,
        ),
      ),
    );
  }

  Future<void> _analyzeWithBarcode() async {
    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Pilih gambar terlebih dahulu")),
      );
      return;
    }

    // Navigasi ke hasil scan tanpa inference (untuk barcode)
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ScanResultScreen(
          imagePath: _selectedImage!.path,
        ),
      ),
    );
  }

  Map<String, dynamic> _parseOCRResultToPred(Map<String, String> ocrResult) {
    double parseDouble(String? value) {
      if (value == null) return 0.0;
      return double.tryParse(value.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0;
    }

    return {
      "nutriGrade": "B", // placeholder, bisa dihitung otomatis nanti
      "gula": parseDouble(ocrResult["gula"]),
      "garam": parseDouble(ocrResult["garam"]),
      "lemak": parseDouble(ocrResult["lemak"]),
      "protein": parseDouble(ocrResult["protein"]),
      "kalori": parseDouble(ocrResult["kalori"]),
      "karbo": parseDouble(ocrResult["karbo"]),
      "serat": parseDouble(ocrResult["serat"]),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBE19D),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 10),

                  // Image Preview Container
                  Container(
                    height: 500,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: _selectedImage == null
                        ? const Center(
                            child: Icon(
                              Icons.camera_alt_outlined,
                              size: 60,
                              color: Colors.black54,
                            ),
                          )
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.file(
                              _selectedImage!,
                              fit: BoxFit.cover,
                              width: double.infinity,
                            ),
                          ),
                  ),

                  const SizedBox(height: 20),

                  // Gallery & Camera Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildRoundedButton("Galery", onTap: _pickFromGallery),
                      const SizedBox(width: 12),
                      _buildRoundedButton("Camera", onTap: _openCamera),
                    ],
                  ),

                  const SizedBox(height: 20),
                  SizedBox(
                    width: 180,
                    child: Divider(
                      color: Colors.black,
                      thickness: 0.8,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "Analyze with:",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // NutriFact & Barcode Analysis Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildRoundedButton("NutriFact", onTap: _analyzeWithNutriFact),
                      const SizedBox(width: 12),
                      _buildRoundedButton("Barcode", onTap: _analyzeWithBarcode),
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

  static Widget _buildRoundedButton(String text, {required VoidCallback onTap}) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
        ),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        elevation: 1,
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.black87,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}