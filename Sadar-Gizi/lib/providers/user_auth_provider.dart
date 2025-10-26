import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserAuthProvider with ChangeNotifier {
  late final FirebaseAuth _auth = FirebaseAuth.instance;

  User? _currentUser;
  bool _isCheckingAuth = true;

  // --- GETTERS ---
  User? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  bool get isCheckingAuth => _isCheckingAuth;

  UserAuthProvider() {
    // Mendengarkan perubahan status otentikasi secara real-time
    _auth.authStateChanges().listen((User? user) {
      _currentUser = user;
      _isCheckingAuth = false;
      notifyListeners();
      if (user == null) {
        print('User is signed out.');
      } else {
        print('User is signed in: ${user.uid}');
      }
    });
  }

  // Fungsi Logout
  Future<void> signOut() async {
    await _auth.signOut();
    notifyListeners();
  }
}
