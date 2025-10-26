import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:project_capstone_1/widgets/form_widget.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _emailController = TextEditingController();

  String? _gender;
  DateTime? _birthDate;
  String? _activity;

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

 
  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final doc =
          await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

      if (doc.exists) {
        final data = doc.data()!;
        final birthDateField = data['birthDate'];
        DateTime? parsedBirthDate;

        if (birthDateField is Timestamp) {
          parsedBirthDate = birthDateField.toDate();
        } else if (birthDateField is String) {
          parsedBirthDate = DateTime.tryParse(birthDateField);
        }

        setState(() {
          _nameController.text = data['name'] ?? '';
          _gender = data['gender'] ?? 'Perempuan';
          _birthDate = parsedBirthDate ?? DateTime(2000, 1, 1);
          _heightController.text =
              (data['heightCm'] ?? data['height'] ?? 0).toString();
          _weightController.text =
              (data['weightKg'] ?? data['weight'] ?? 0).toString();
          _activity = data['activity'] ?? 'Sedang';
          _emailController.text = user.email ?? '';
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal memuat data pengguna: $e")),
      );
    }
  }

 
  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => _isLoading = true);

    try {
      final newEmail = _emailController.text.trim();

     
      if (newEmail.isNotEmpty && newEmail != user.email) {
        await user.verifyBeforeUpdateEmail(newEmail);
      }

     
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'name': _nameController.text.trim(),
        'gender': _gender,
        'birthDate': _birthDate != null ? Timestamp.fromDate(_birthDate!) : null,
        'heightCm': double.tryParse(_heightController.text) ?? 0,
        'weightKg': double.tryParse(_weightController.text) ?? 0,
        'activity': _activity,
        'email': newEmail.isNotEmpty ? newEmail : user.email,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Profil berhasil diperbarui!"),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }

      
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      final message = e.message ?? "Terjadi kesalahan autentikasi.";
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Terjadi kesalahan: $e"),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBE19D),
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFF6B7B48)),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      const SizedBox(height: 40),
                      Image.asset(
                        'assets/images/illustrations/Reset-Password-3-Streamline-Milano.png',
                        height: 180,
                      ),
                      const SizedBox(height: 30),
                      const Text(
                        "Edit Profile",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F1724),
                        ),
                      ),
                      const SizedBox(height: 30),

                      CustomTextField(
                        hint: "Nama",
                        controller: _nameController,
                        validator: (val) =>
                            val == null || val.isEmpty ? "Nama wajib diisi" : null,
                      ),

                      CustomDropdownField(
                        hint: "Jenis Kelamin",
                        value: _gender,
                        items: const ["Laki-laki", "Perempuan"],
                        onChanged: (val) => setState(() => _gender = val),
                      ),

                      CustomDatePickerField(
                        hint: "Tanggal Lahir",
                        selectedDate: _birthDate,
                        onDateSelected: (date) =>
                            setState(() => _birthDate = date),
                      ),

                      CustomTextField(
                        hint: "Tinggi (cm)",
                        controller: _heightController,
                        keyboardType: TextInputType.number,
                        validator: (val) =>
                            val == null || val.isEmpty ? "Tinggi wajib diisi" : null,
                      ),

                      CustomTextField(
                        hint: "Berat (kg)",
                        controller: _weightController,
                        keyboardType: TextInputType.number,
                        validator: (val) =>
                            val == null || val.isEmpty ? "Berat wajib diisi" : null,
                      ),

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
                        onChanged: (val) => setState(() => _activity = val),
                      ),

                      CustomTextField(
                        hint: "Email",
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        validator: (val) =>
                            val == null || val.isEmpty ? "Email wajib diisi" : null,
                      ),

                      const SizedBox(height: 25),

                      ElevatedButton(
                        onPressed: _saveProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6B7B48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          padding: const EdgeInsets.symmetric(
                              vertical: 14, horizontal: 40),
                        ),
                        child: const Text(
                          "Save",
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),

                      const SizedBox(height: 10),

                      ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade400,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          padding: const EdgeInsets.symmetric(
                              vertical: 14, horizontal: 40),
                        ),
                        child: const Text(
                          "Cancel",
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
