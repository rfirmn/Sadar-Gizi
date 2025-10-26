import 'package:flutter/material.dart';
import 'package:project_capstone_1/screens/home_guest_screen.dart';
import 'package:provider/provider.dart';
import 'package:project_capstone_1/providers/user_provider.dart';
import 'package:project_capstone_1/providers/user_auth_provider.dart';
import 'package:project_capstone_1/screens/edit_profile_screen.dart';
import 'package:project_capstone_1/widgets/form_widget.dart';
import 'package:project_capstone_1/widgets/navbar_widget.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  // HITUNG USIA DARI TANGGAL LAHIR
  int getAge(DateTime birthDate) {
    DateTime today = DateTime.now();
    int age = today.year - birthDate.year;
    if (today.month < birthDate.month ||
        (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final authProvider = Provider.of<UserAuthProvider>(context);

    final userProfile = userProvider.userProfile;

    return Scaffold(
      backgroundColor: const Color(0xFFFBE19D),
      bottomNavigationBar: const CustomNavBar(selectedIndex: 0),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              const Text(
                "Profile",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F1724),
                ),
              ),
              const SizedBox(height: 30),

              
              if (userProvider.isProfileLoaded == false)
                const Center(
                  child: Column(
                    children: [
                      CircularProgressIndicator(color: Color(0xFF6B7B48)),
                      SizedBox(height: 12),
                      Text(
                        "Memuat data pengguna...",
                        style: TextStyle(fontSize: 16, color: Colors.black54),
                      ),
                    ],
                  ),
                )
              else if (userProfile == null)
                const Text(
                  "Belum ada data pengguna",
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                )
              else ...[
                
                ProfileField(label: "Nama", value: userProfile.name),
                ProfileField(label: "Jenis Kelamin", value: userProfile.gender),
                ProfileField(
                  label: "Usia",
                  value:
                      "${getAge(userProfile.birthDate)} tahun",
                ),
                ProfileField(
                  label: "Tinggi (cm)",
                  value: "${userProfile.heightCm.toStringAsFixed(0)} cm",
                ),
                ProfileField(
                  label: "Berat (kg)",
                  value: "${userProfile.weightKg.toStringAsFixed(0)} kg",
                ),
                ProfileField(
                  label: "Aktivitas Harian",
                  value: userProfile.activity,
                ),
                ProfileField(
                  label: "Email",
                  value: userProfile.email,
                ),
              ],

              const SizedBox(height: 30),

              // EDIT BUTTON
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const EditProfileScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6B7B48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 40,
                  ),
                ),
                child: const Text(
                  "Edit Profile",
                  style: TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(height: 12),

              // LOGOUT BUTTON
              ElevatedButton(
                onPressed: () async {
                  await authProvider.signOut();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Berhasil logout"),
                      backgroundColor: Colors.redAccent,
                    ),
                  );
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const HomeGuestScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromRGBO(239, 83, 80, 1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 40,
                  ),
                ),
                child: const Text(
                  "Log Out",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
