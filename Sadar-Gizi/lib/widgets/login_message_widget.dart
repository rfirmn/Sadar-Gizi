import 'package:flutter/material.dart';
import 'package:project_capstone_1/screens/login_screen.dart';

class LoginMessage extends StatelessWidget {
  const LoginMessage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
             
              Image.asset(
                'assets/images/illustrations/Approval-1-Streamline-Milano.png',
                height: 225,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 24),

              // 📝 Pesan teks
              const Text(
                'Silakan login terlebih dahulu untuk mengakses fitur ini.',
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontSize: 28,
                  color: Color.fromARGB(255, 0, 0, 0), 
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: 140,
                height: 45,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero,
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const LoginScreen(),
                      ),
                    );
                  },
                  child: const Text(
                    'Login',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      //fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
