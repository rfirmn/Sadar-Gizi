import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project_capstone_1/providers/user_auth_provider.dart';

class UserProfile {
  final String uid;
  final String name;
  final String email;
  final String gender;
  final DateTime birthDate;
  final double heightCm;
  final double weightKg;
  final String activity;

  UserProfile({
    required this.uid,
    required this.name,
    required this.email,
    required this.gender,
    required this.birthDate,
    required this.heightCm,
    required this.weightKg,
    required this.activity,
  });

  factory UserProfile.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    final Timestamp? timestamp = data['birthDate'] as Timestamp?;
    final DateTime birthDate = timestamp?.toDate() ?? DateTime(2000);

    return UserProfile(
      uid: doc.id,
      name: data['name'] ?? 'N/A',
      email: data['email'] ?? 'N/A',
      gender: data['gender'] ?? 'N/A',
      birthDate: birthDate,
      heightCm: (data['heightCm'] as num?)?.toDouble() ?? 0.0,
      weightKg: (data['weightKg'] as num?)?.toDouble() ?? 0.0,
      activity: data['activity'] ?? 'N/A',
    );
  }
}

class UserProvider with ChangeNotifier {
  final UserAuthProvider _authProvider;
  UserProfile? _userProfile;
  StreamSubscription<DocumentSnapshot>? _userSubscription;

  UserProvider(this._authProvider) {
    _authProvider.addListener(_handleAuthChange);
    _handleAuthChange();
  }

  UserProfile? get userProfile => _userProfile;
  bool get isProfileLoaded => _userProfile != null;

  void _handleAuthChange() {
    if (_authProvider.isLoggedIn) {
      _startUserStream(_authProvider.currentUser!.uid);
    } else {
      _stopUserStream();
      _userProfile = null;
      notifyListeners();
    }
  }

  void _startUserStream(String uid) {
    _stopUserStream();

    _userSubscription = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .snapshots()
        .listen((docSnapshot) {
      if (docSnapshot.exists && docSnapshot.data() != null) {
        _userProfile = UserProfile.fromFirestore(docSnapshot);
        debugPrint('✅ User data loaded for UID: $uid');
      } else {
        _userProfile = null;
        debugPrint('⚠️ User document not found for UID: $uid');
      }
      notifyListeners();
    }, onError: (error) {
      debugPrint('❌ Error fetching user data: $error');
      _userProfile = null;
      notifyListeners();
    });
  }

  void _stopUserStream() {
    _userSubscription?.cancel();
    _userSubscription = null;
  }

  @override
  void dispose() {
    _authProvider.removeListener(_handleAuthChange);
    _stopUserStream();
    super.dispose();
  }
}
