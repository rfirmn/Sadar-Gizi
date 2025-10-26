import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:project_capstone_1/firebase_options.dart';
import 'package:project_capstone_1/providers/consumed_products_provider.dart';
import 'package:project_capstone_1/providers/product_provider.dart';
import 'package:project_capstone_1/providers/user_auth_provider.dart';
import 'package:project_capstone_1/providers/user_provider.dart';
import 'package:project_capstone_1/screens/home_guest_screen.dart';
import 'package:project_capstone_1/screens/home_user_screen.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // Supabase
  try {
    await Supabase.initialize(
      url: "https://lpnsckrzagewefabszkw.supabase.co",
      anonKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxwbnNja3J6YWdld2VmYWJzemt3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjEzNjg0MDMsImV4cCI6MjA3Njk0NDQwM30.lkdox2kG4QzY4hxdpeCP5JaSpXwMFxnkiwkOGUcK8Vs",
    );
  } catch (e) {
    print('Supabase Initialization Error: $e');
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserAuthProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => ConsumedProductProvider()),

        ChangeNotifierProxyProvider<UserAuthProvider, UserProvider>(
        create: (context) => UserProvider(context.read<UserAuthProvider>()),
        update: (context, authProvider, previousUserProvider) =>
            previousUserProvider ?? UserProvider(authProvider),
        ),

      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<UserAuthProvider>(context);

    Widget initialScreen;

    if (authProvider.isCheckingAuth) {
      // Saat Firebase masih memeriksa status login
      initialScreen = const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    } else if (authProvider.isLoggedIn) {
      // Jika sudah login
      initialScreen = const HomeUserScreen();
    } else {
      // Jika belum login
      initialScreen = const HomeGuestScreen();
      // atau ganti ke LoginScreen() kalau mau langsung login
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SadarGizi',
      home: initialScreen,
    );
  }
}

// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp(
//   options: DefaultFirebaseOptions.currentPlatform,
//   );
//   runApp(
//     MultiProvider(
//       providers: [
//         ChangeNotifierProvider(create: (_) => AuthProvider()),
//       ],
//       child: const MyApp(),
//     ),
//   );
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       home: Consumer<AuthProvider>(
//         builder: (context, auth, _) {
//           return auth.isLoggedIn
//               ? const HomeUserScreen()
//               : const HomeGuestScreen();
//         },
//       ),
//     );
//   }
// }













// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

  
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'SadarGizi',
//       theme: ThemeData(),
//       home: const LoginScreen(),

      
//     );
//   }
// }

                                            