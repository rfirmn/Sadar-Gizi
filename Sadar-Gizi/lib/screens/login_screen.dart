import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:project_capstone_1/screens/home_user_screen.dart';
import 'package:provider/provider.dart';
import 'package:project_capstone_1/providers/user_provider.dart';
import 'package:project_capstone_1/screens/sign_up_screen.dart';
import 'package:project_capstone_1/widgets/form_widget.dart';
import 'package:project_capstone_1/services/google_auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

// LOGIN WITH EMAIL & PASSWORD
// TODO: PESAN PEMEBERITAHUAN LOGIN (BELUM PUNYA AKUN / EMAIL ATAU PASSWORD SALAH PASSWORD)
  Future<User?> loginWithEmailandPassword(BuildContext context) async {
  try {
    final userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );

    return userCredential.user;
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          "Akun belum terdaftar. Silakan Sign Up terlebih dahulu.",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Color(0xFFC70039),
      ),
    );
    return null;
  }
}


  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    return Scaffold(
      backgroundColor: const Color(0xFFFBE19D),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 10),
                Center(
                  child: Image.asset(
                    'assets/images/illustrations/Create-Account-3-Streamline-Milano.png',
                    height: 200,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 40),

                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Welcome!\nLogin",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F1724),
                    ),
                  ),
                ),
                const SizedBox(height: 50),

                // EMAIL FIELD
                CustomTextField(
                  hint: "Email",
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                ),

                // PASSWORD FIELD
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
                const SizedBox(height: 12),

                // LOGIN BUTTON
                ElevatedButton(
                  onPressed: () async {
                    final user = await loginWithEmailandPassword(context);

                    if (user != null) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const HomeUserScreen(),
                        ),
                      );
                    } 
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6B7B48),
                    elevation: 10,
                    shadowColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                  ),
                  child: const Text(
                    "Login",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 20),

                // SIGN UP LINK
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("New User? "),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SignUpScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        "Sign up",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),

                // OR DIVIDER
                Row(
                  children: const [
                    Expanded(child: Divider(thickness: 1)),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text("Or login with"),
                    ),
                    Expanded(child: Divider(thickness: 1)),
                  ],
                ),
                const SizedBox(height: 20),

                // GOOGLE BUTTON 
                // LOGIN WITH GOOGLE
                GestureDetector(
                  onTap: () async {
                    final userCredential = await GoogleSignInService.signInWithGoogle();

                    if (userCredential != null) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => HomeUserScreen()),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Google SignIn Cancel or failed"))
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
