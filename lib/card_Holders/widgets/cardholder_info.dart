import 'package:flutter/material.dart';

class CardholderInfo extends StatelessWidget {
  final String? cardholderName;
  final String activePin;
  final Function(String) onPinChanged;
  final VoidCallback? onPinTap;

  const CardholderInfo({
    super.key,
    required this.cardholderName,
    required this.activePin,
    required this.onPinChanged,
    this.onPinTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.grey[300],
            child: const Icon(Icons.person, color: Colors.black87),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              cardholderName ?? "User",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          GestureDetector(
            onTap: onPinTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.location_on,
                    size: 18,
                    color: Colors.black87,
                  ),
                  const SizedBox(width: 4),
                  Text(activePin.isNotEmpty ? activePin : "Set PIN"),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
