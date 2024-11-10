import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vet_connect/splash/splash_screen.dart';
import 'SignInPage.dart';
import 'homepage.dart';
import 'home_page_for_pets.dart';
import 'login_page.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const VetConnectApp());
}

class VetConnectApp extends StatelessWidget {
  const VetConnectApp({super.key});

  Future<Widget> determineStartupScreen() async {
    User? user = FirebaseAuth.instance.currentUser;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userType = prefs.getString('userType');

    if (user != null) {
      // User is logged in
      if (userType == 'VET') {
        return HomePage();
      } else if (userType == 'PET') {
        return HomePageForPets();
      } else {
        return SignInPage(); // Prompt for selection
      }
    } else {
      return LoginPage(); // User is not logged in
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VetConnect',
      theme: ThemeData(
        primarySwatch: Colors.purple,
      ),
      home: FutureBuilder<Widget>(
        future: determineStartupScreen(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return SplashScreen();
          } else if (snapshot.hasData) {
            return snapshot.data!;
          } else {
            return LoginPage(); // Default fallback
          }
        },
      ),
      routes: {
        '/splash': (context) => SplashScreen(),
        '/login': (context) => LoginPage(),
        '/signup': (context) => SignInPage(),
        '/home': (context) => HomePage(),
      },
    );
  }
}
