import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'homepage.dart';
import 'home_page_for_pets.dart';
import 'vet_connect_painter.dart';
import 'auth_services.dart'; // Import the AuthService class

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _loginFormKey = GlobalKey<FormState>();

  final AuthService _authService = AuthService(); // Instantiate AuthService

  // Handle login with email and password
  Future<void> _loginWithEmailAndPassword() async {
    if (_loginFormKey.currentState!.validate()) {
      try {
        final user = await _authService.loginWithEmailAndPassword(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );

        if (user != null) {
          print("User logged in: ${user.uid}");

          // Ensure the user is authenticated before querying Firestore
          if (FirebaseAuth.instance.currentUser == null) {
            print("Error: User authentication failed before Firestore query.");
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('Authentication failed. Try again.')),
            );
            return;
          }

          FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get()
              .then(
            (DocumentSnapshot<Map<String, dynamic>> currentUserData) {
              if (!currentUserData.exists) {
                print("Firestore document not found for user: ${user.uid}");
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('User data not found.')),
                );
                return;
              }

              final String userType =
                  currentUserData.data()?['role'] ?? 'Unknown';
              print("User role: $userType");

              // Navigate based on user role
              if (userType == 'Vet') {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const HomePage()),
                );
              } else {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                      builder: (context) => const HomePageForPets()),
                );
              }
            },
          ).catchError((error) {
            print("Error fetching user data: $error");
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error fetching user data: $error')),
            );
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Login failed. Please try again.')),
          );
        }
      } on FirebaseAuthException catch (e) {
        String errorMessage;
        if (e.code == 'user-not-found') {
          errorMessage = 'No user found for this email.';
        } else if (e.code == 'wrong-password') {
          errorMessage = 'Incorrect password.';
        } else {
          errorMessage = 'Login failed. Please try again.';
        }

        print("FirebaseAuthException: $errorMessage");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      } catch (e) {
        print("Unexpected error: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          CustomPaint(
            size: const Size(double.infinity, double.infinity),
            painter: VetConnectPainter(),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Form(
                  key: _loginFormKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        "Take Care Of Your Pet",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Enter your email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _passwordController,
                        decoration: const InputDecoration(
                          labelText: 'Password',
                          border: OutlineInputBorder(),
                        ),
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Enter your password';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _loginWithEmailAndPassword,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 50, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text("Log In"),
                      ),
                      const SizedBox(height: 10),
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacementNamed(context, '/signup');
                        },
                        child: const Text("Don't have an account? Sign Up"),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
