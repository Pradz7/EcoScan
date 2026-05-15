import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'home_navigation.dart';
import 'firestore_service.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLogin = true;
  bool isLoading = false;

  Future<void> submitAuth() async {
    setState(() {
      isLoading = true;
    });

    try {
      if (isLogin) {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );
      } else {
        final userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );

        await userCredential.user?.updateDisplayName(
          usernameController.text.trim(),
        );
      }

      await FirestoreService.loadDetections();

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const HomeNavigation(),
        ),
      );
    } on FirebaseAuthException catch (e) {
      String message = "Authentication failed. Please try again.";

      if (e.code == "user-not-found") {
        message = "You don't have an account yet. Please register first.";
      } else if (e.code == "wrong-password") {
        message = "Wrong password. Please try again.";
      } else if (e.code == "invalid-email") {
        message = "Please enter a valid email address.";
      } else if (e.code == "email-already-in-use") {
        message = "This email is already registered. Please login instead.";
      } else if (e.code == "weak-password") {
        message = "Password must be at least 6 characters.";
      } else if (e.code == "missing-password") {
        message = "Please enter your password.";
      } else if (e.code == "invalid-credential") {
        message = "You don't have an account or the password is incorrect.";
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.redAccent,
        ),
      );
    }

    if (!mounted) return;

    setState(() {
      isLoading = false;
    });
  }

  @override
  void dispose() {
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B101B),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF161B26),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: Colors.white.withOpacity(0.08)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.recycling, color: Color(0xFF6BFB9A), size: 70),
                const SizedBox(height: 18),
                Text(
                  isLogin ? "Welcome Back" : "Create Account",
                  style: const TextStyle(
                    color: Color(0xFFE5E7EB),
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 30),

                if (!isLogin) ...[
                  TextField(
                    controller: usernameController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: "Username",
                      labelStyle: const TextStyle(color: Color(0xFF9CA3AF)),
                      prefixIcon: const Icon(
                        Icons.person_outline,
                        color: Color(0xFF6BFB9A),
                      ),
                      filled: true,
                      fillColor: const Color(0xFF0B101B),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: "Email",
                    labelStyle: const TextStyle(color: Color(0xFF9CA3AF)),
                    prefixIcon: const Icon(
                      Icons.email_outlined,
                      color: Color(0xFF6BFB9A),
                    ),
                    filled: true,
                    fillColor: const Color(0xFF0B101B),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                TextField(
                  controller: passwordController,
                  obscureText: true,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: "Password",
                    labelStyle: const TextStyle(color: Color(0xFF9CA3AF)),
                    prefixIcon: const Icon(
                      Icons.lock_outline,
                      color: Color(0xFF6BFB9A),
                    ),
                    filled: true,
                    fillColor: const Color(0xFF0B101B),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : submitAuth,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6BFB9A),
                      foregroundColor: const Color(0xFF0B101B),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: isLoading
                        ? const CircularProgressIndicator(
                            color: Color(0xFF0B101B),
                          )
                        : Text(
                            isLogin ? "Login" : "Register",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                  ),
                ),

                TextButton(
                  onPressed: () {
                    setState(() {
                      isLogin = !isLogin;
                    });
                  },
                  child: Text(
                    isLogin
                        ? "Don't have an account? Register"
                        : "Already have an account? Login",
                    style: const TextStyle(
                      color: Color(0xFF44E2CD),
                      fontWeight: FontWeight.bold,
                    ),
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