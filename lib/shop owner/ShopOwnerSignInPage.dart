// import 'package:card/shop%20owner/ShopOwnerHome.dart';
import 'home_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'ShopOwnerSignupPage.dart';

class ShopOwnerSignInPage extends StatefulWidget {
  const ShopOwnerSignInPage({super.key});

  @override
  _ShopOwnerSignInPageState createState() => _ShopOwnerSignInPageState();
}

class _ShopOwnerSignInPageState extends State<ShopOwnerSignInPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  bool _isLoading = false;

  final Color _primaryColor = const Color(0xFF1E212A);
  final Color _accentColor = const Color(0xFF61dafb);
  final Color _onPrimaryColor = Colors.white;

  late final AnimationController _animationController;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Signed in as ${userCredential.user!.email}")),
        );
      }

      // Navigate to ShopOwnerHome (bottom nav)
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomePage(uid: userCredential.user!.uid),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      String message = "Error signing in";
      if (e.code == 'user-not-found') message = "No user found for that email";
      if (e.code == 'wrong-password') message = "Wrong password provided";

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    bool obscure = false,
    TextInputType? keyboard,
    required IconData icon,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboard,
      style: TextStyle(color: _onPrimaryColor),
      validator: (v) => v!.isEmpty ? "$label required" : null,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: _onPrimaryColor.withOpacity(0.6)),
        prefixIcon: Icon(icon, color: _onPrimaryColor.withOpacity(0.6)),
        filled: true,
        fillColor: _onPrimaryColor.withOpacity(0.05),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _onPrimaryColor.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _accentColor, width: 2),
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _primaryColor,
      body: SafeArea(
        child: FadeTransition(
          opacity: _animation,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(Icons.storefront_outlined, color: _accentColor, size: 80),
                const SizedBox(height: 20),
                Text(
                  "Welcome Back",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: _onPrimaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Sign in to your shop owner account",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: _onPrimaryColor.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 40),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _buildTextField(
                        "Email",
                        emailController,
                        keyboard: TextInputType.emailAddress,
                        icon: Icons.email_outlined,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        "Password",
                        passwordController,
                        obscure: true,
                        icon: Icons.lock_outline,
                      ),
                      const SizedBox(height: 24),
                      _isLoading
                          ? Center(
                              child: CircularProgressIndicator(
                                color: _accentColor,
                              ),
                            )
                          : ElevatedButton(
                              onPressed: _signIn,
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size(double.infinity, 50),
                                backgroundColor: _accentColor,
                                foregroundColor: _primaryColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                              ),
                              child: const Text(
                                "Sign In",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account?",
                      style: TextStyle(color: _onPrimaryColor.withOpacity(0.7)),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: () {
                        if (mounted) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ShopOwnerSignupPage(),
                            ),
                          );
                        }
                      },
                      child: Text(
                        "Sign Up",
                        style: TextStyle(
                          color: _accentColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
