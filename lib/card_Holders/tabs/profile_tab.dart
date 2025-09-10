import 'package:flutter/material.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        "Profile Tab – user details and settings",
        style: TextStyle(fontSize: 16),
      ),
    );
  }
}
