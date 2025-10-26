import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:project_capstone_1/screens/complete_signup_screen.dart';
import 'package:project_capstone_1/services/google_auth_service.dart';
import 'package:project_capstone_1/screens/login_screen.dart';
import 'package:project_capstone_1/widgets/form_widget.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmedPasswordController = TextEditingController();

  String? _gender;
  String? _activity;
  DateTime? _birthDate;

  bool _obscurePassword = true;
  bool _obscureConfirmedPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmedPasswordController.dispose();
    
    super.dispose();
  }

  Future<bool> signUpWithEmailAndPassword() async {
    if (!passwordConfirmed()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Password tidak cocok.")),
      );
      return false;
    }

    if (_gender == null || _activity == null || _birthDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Mohon lengkapi semua data profil.")),
      );
      return false;
    }
    if (_heightController.text.isEmpty || _weightController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Mohon isi tinggi dan berat badan.")),
      );
      return false;
    }

    try {
      final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      await addUserDetails(
        _nameController.text.trim(),
        _gender!,
        _birthDate!,
        double.parse(_heightController.text.trim()),
        double.parse(_weightController.text.trim()),
        _activity!,
        _emailController.text.trim(),
        userCredential.user!.uid,
      );

      return true; 
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Pendaftaran gagal: ${e.message}")),
      );
      return false;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Terjadi kesalahan tak terduga.")),
      );
      return false;
    }
  }
 
  Future addUserDetails(
    String name, 
    String gender, 
    DateTime birthDate, 
    double height, 
    double weight, 
    String activity, 
    String email,
    String uid, 
  ) async {
    
    await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'name': name,
        'gender': gender,
        'birthDate': birthDate, 
        'heightCm': height,
        'weightKg': weight,
        'activity': activity,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(), 
    });
  }

  bool passwordConfirmed(){
    if (_passwordController.text.trim() == _confirmedPasswordController.text.trim()) {
      return true;
    } else {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                    height: 190,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 40),

                const Text(
                  "Create Account",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F1724),
                  ),
                ),
                const SizedBox(height: 40),

                // NAMA
                CustomTextField(
                  hint: "Nama",
                  controller: _nameController,
                ),

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

                // EMAIL
                CustomTextField(
                  hint: "Email",
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                ),

                // PASSWORD
                CustomTextField(
                  hint: "Password",
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
                
                // CONFIRMED PASSWORD
                CustomTextField(
                  hint: "Confirmed Password",
                  controller: _confirmedPasswordController,
                  obscureText: _obscureConfirmedPassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmedPassword ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureConfirmedPassword = !_obscureConfirmedPassword;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 20),

                // SIGN UP BUTTON 
                SizedBox(
                  child: ElevatedButton(
                    onPressed: () async {
                      final success = await signUpWithEmailAndPassword();
                      if (success) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const LoginScreen()),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6B7B48),
                      elevation: 10,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 14,
                      ),
                    ),
                    child: const Text(
                      "Sign Up",
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Flexible(child: Divider(thickness: 1)),
                      Text("Or connect with"),
                      Flexible(child: Divider(thickness: 1)),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // GOOGLE SignUp
                GestureDetector(
                  onTap: () async {
                      final userCredential = await GoogleSignInService.signInWithGoogle();

                      if (userCredential != null) {
                          final User user = userCredential.user!;
                          
                          final userDoc = await FirebaseFirestore.instance
                              .collection('users')
                              .doc(user.uid)
                              .get();
                          
                          if (!userDoc.exists) {
                            await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
                              'email': user.email,
                              'displayName': user.displayName,
                              'isProfileComplete': false,
                            });
                          }
                          
                          final bool isComplete = userDoc.data()?['isProfileComplete'] ?? false; 

                          if (isComplete) {
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                              );
                          } else {
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (context) => const CompleteSignupScreen()), 
                              );
                            }
                          } else {
                            // Tampilkan SnackBar gagal
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Gagal masuk dengan Google")),
                            );
                          }
                    },
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.black54, width: 1),
                    ),
                    padding: const EdgeInsets.all(10),
                    child: const Icon(Icons.g_mobiledata, size: 40),
                  ),
                ),
                const SizedBox(height: 20),

                // LOGIN LINK
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Already have an account? "),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const LoginScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        "Login",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
