import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:card/card_Holders/cardholders_signup.dart';
import 'package:card/card_Holders/dashboard/cardholder_dashboard.dart'; // <-- import dashboard

class CardholderSigninPage extends StatefulWidget {
  const CardholderSigninPage({super.key});

  @override
  State<CardholderSigninPage> createState() => _CardholderSigninPageState();
}

class _CardholderSigninPageState extends State<CardholderSigninPage> {
  final _formKey = GlobalKey<FormState>();
  final _auth = FirebaseAuth.instance;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _signin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      await _auth.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Sign In Successful!")));

      // Navigate to Cardholder Dashboard
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) =>
              // const EcommerceDashboard()),
              const CardholderDashboard(),
        ),
      );
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: ${e.message}")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final inputDecoration = InputDecoration(
      filled: true,
      fillColor: Colors.grey[200],
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text("Card Holder Sign In"),
        backgroundColor: const Color(0xFF1E212A),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: emailController,
                decoration: inputDecoration.copyWith(labelText: "Email"),
                keyboardType: TextInputType.emailAddress,
                validator: (v) => v!.isEmpty ? "Email required" : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: passwordController,
                decoration: inputDecoration.copyWith(labelText: "Password"),
                obscureText: true,
                validator: (v) => v!.isEmpty ? "Password required" : null,
              ),
              const SizedBox(height: 20),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _signin,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        backgroundColor: const Color(0xFF1E212A),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text("Sign In"),
                    ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CardholderSignupPage(),
                    ),
                  );
                },
                child: const Text(
                  "Don’t have an account? Sign Up",
                  style: TextStyle(color: Color(0xFF1E212A)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
