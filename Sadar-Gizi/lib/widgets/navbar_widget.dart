import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:project_capstone_1/screens/profile_screen.dart';
import 'package:project_capstone_1/screens/home_user_screen.dart';
import 'package:project_capstone_1/screens/home_guest_screen.dart';
import 'package:project_capstone_1/screens/list_product_screen.dart';
import 'package:project_capstone_1/screens/scan_screen.dart';
import 'package:project_capstone_1/screens/fun_facts_screen.dart';
import 'package:project_capstone_1/providers/user_auth_provider.dart';
import 'package:project_capstone_1/widgets/login_message_widget.dart';

class CustomNavBar extends StatefulWidget {
  final int selectedIndex;

  const CustomNavBar({super.key, this.selectedIndex = 0});

  @override
  State<CustomNavBar> createState() => _CustomNavBarState();
}

class _CustomNavBarState extends State<CustomNavBar> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.selectedIndex;
  }

  void _onItemTapped(BuildContext context, int index) {
    final auth = Provider.of<UserAuthProvider>(context, listen: false);
    bool loggedIn = auth.isLoggedIn;

    Widget page;
    bool usePush = false; 

    switch (index) {
      case 0:
        page = loggedIn ? const HomeUserScreen() : const HomeGuestScreen();
        break;
      case 1:
        page = loggedIn ? const ProductListScreen() : const LoginMessage();
        usePush = !loggedIn; 
        break;
      case 2:
        page = const ScanScreen(); usePush = true;
        break;
      case 3:
        page = loggedIn ? const FunFactsScreen() : const LoginMessage();
        usePush = !loggedIn;
        break;
      case 4:
        page = loggedIn ? const ProfileScreen() : const LoginMessage();
        usePush = !loggedIn;
        break;
      default:
        page = loggedIn ? const HomeUserScreen() : const HomeGuestScreen();
    }

    setState(() => _currentIndex = index);

   
    if (usePush) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => page),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => page),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 65,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            spreadRadius: 1,
            blurRadius: 10,
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // MENU ICONS
          Positioned.fill(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem("assets/images/icons/home.png", "Home", 0),
                _buildNavItem("assets/images/icons/list.png", "Product List", 1),
                const SizedBox(width: 60), // ruang tombol tengah
                _buildNavItem("assets/images/icons/fun-facts.png", "Fun Facts", 3),
                _buildNavItem("assets/images/icons/profile.png", "Profile", 4),
              ],
            ),
          ),

          // LABEL "SCAN" DI TENGAH
          Align(
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.only(top: 25),
              child: const Text(
                'Scan',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontSize: 12,
                ),
              ),
            ),
          ),

          // TOMBOL SCAN
          Positioned(
            top: -25,
            left: MediaQuery.of(context).size.width / 2 - 30,
            child: GestureDetector(
              onTap: () => _onItemTapped(context, 2),
              child: Container(
                width: 55,
                height: 55,
                decoration: BoxDecoration(
                  color: const Color(0xFF6B7B48),
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Center(
                  child: Image.asset(
                    "assets/images/icons/scan.png",
                    width: 35,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(String iconPath, String label, int index) {
    bool isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => _onItemTapped(context, index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            iconPath,
            height: 20,
            color: const Color.fromARGB(255, 0, 0, 0),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: const Color.fromARGB(255, 0, 0, 0),
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
