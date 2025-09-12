import 'package:flutter/material.dart';

class BestDealsBanner extends StatelessWidget {
  final VoidCallback onExplorePressed;

  const BestDealsBanner({super.key, required this.onExplorePressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFE0B2), Color(0xFFFFCC80)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              "Best Deals • Up to 80% OFF",
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
            ),
          ),
          ElevatedButton(
            onPressed: onExplorePressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black87,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            child: const Text("Explore"),
          ),
        ],
      ),
    );
  }
}
