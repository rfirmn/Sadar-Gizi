import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:project_capstone_1/screens/home_user_screen.dart';
import 'package:project_capstone_1/widgets/form_widget.dart';

class CompleteSignupScreen extends StatefulWidget {
  const CompleteSignupScreen({super.key});

  @override
  State<CompleteSignupScreen> createState() => _CompleteSignupScreenState();
}

class _CompleteSignupScreenState extends State<CompleteSignupScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();

  // State Variables
  String? _gender;
  String? _activity;
  DateTime? _birthDate;

  @override
  void dispose() {
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  Future<void> saveCompleteProfile(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      if (_gender == null || _activity == null || _birthDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Mohon lengkapi semua data.")),
        );
        return;
      }

      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("User tidak ditemukan.")),
          );
          return;
        }

        final double height = double.parse(_heightController.text.trim());
        final double weight = double.parse(_weightController.text.trim());

        await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
          'heightCm': height,
          'weightKg': weight,
          'gender': _gender,
          'activity': _activity,
          'birthDate': _birthDate,
          'isProfileComplete': true,
        });

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeUserScreen()),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Terjadi kesalahan: $e")),
        );
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Complete Profile"),
        backgroundColor: const Color(0xFFFBE19D)
      ),
      backgroundColor: const Color(0xFFFBE19D),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 10),
                Center(
                  child: Image.asset(
                    'assets/images/illustrations/Create-Account-4-Streamline-Milano.png',
                    height: 180,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 30),

                const Text(
                  "Lengkapi Data Diri",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F1724),
                  ),
                ),
                const SizedBox(height: 30),

                // JENIS KELAMIN
                CustomDropdownField(
                  hint: "Jenis Kelamin",
                  value: _gender,
                  items: const ["Laki-laki", "Perempuan"],
                  onChanged: (value) {
                    setState(() {
                      _gender = value;
                    });
                  },
                ),

                // TANGGAL LAHIR
                CustomDatePickerField(
                  hint: "Tanggal Lahir",
                  selectedDate: _birthDate,
                  onDateSelected: (picked) {
                    setState(() {
                      _birthDate = picked;
                    });
                  },
                ),

                // TINGGI
                CustomTextField(
                  hint: "Tinggi (cm)",
                  controller: _heightController,
                  keyboardType: TextInputType.number,
                ),

                // BERAT
                CustomTextField(
                  hint: "Berat (kg)",
                  controller: _weightController,
                  keyboardType: TextInputType.number,
                ),

                // AKTIVITAS HARIAN
                CustomDropdownFieldDetailed(
                  hint: "Aktivitas Harian",
                  value: _activity,
                  items: const [
                    {"value": "Sedentari", "label": "Sedentari (minim aktivitas)"},
                    {"value": "Ringan", "label": "Ringan (olahraga 1–2 kali/minggu)"},
                    {"value": "Sedang", "label": "Sedang (olahraga 3–5 kali/minggu)"},
                    {"value": "Berat", "label": "Berat (olahraga 6–7 kali/minggu)"},
                    {"value": "Sangat Berat", "label": "Sangat Berat (olahraga intens 2 kali sehari)"},
                  ],
                  onChanged: (value) {
                    setState(() {
                      _activity = value;
                    });
                  },
                ),

                const SizedBox(height: 30),

                // SIGN UP BUTTON
                ElevatedButton(
                  onPressed: () => saveCompleteProfile(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6B7B48),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                  ),
                  child: const Text("Sign Up", style: TextStyle(fontSize: 16, color: Colors.white)),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
