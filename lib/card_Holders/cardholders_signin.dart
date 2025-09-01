import 'package:flutter/material.dart';

class CardHolderPage extends StatelessWidget {
  const CardHolderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Card Holder", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF1E212A),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: const Center(
        child: Text(
          "Card Holder Signup/Login here",
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
