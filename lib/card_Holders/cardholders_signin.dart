import 'package:card/card_Holders/cardholders_signup.dart';
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
      body: Center(
        child: ElevatedButton.icon(
          icon: const Icon(Icons.credit_card, color: Color(0xFF1E212A)),
          label: const Text(
            'Sign Up as Card Holder',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 50),
            backgroundColor: Colors.white,
            foregroundColor: const Color(0xFF1E212A),
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const CardholderSignupPage(),
              ),
            );
          },
        ),
      ),
    );
  }
}
