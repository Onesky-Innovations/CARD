import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SpecialsTab extends StatelessWidget {
  const SpecialsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          "Vouchers",
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
        ),
        const SizedBox(height: 12),
        StreamBuilder<QuerySnapshot>(
          stream: firestore.collectionGroup("vouchers").snapshots(),
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                ),
              );
            }
            if (!snap.hasData || snap.data!.docs.isEmpty) {
              return _emptyTile("No vouchers available yet");
            }
            final items = snap.data!.docs
                .map((d) => d.data() as Map<String, dynamic>)
                .toList();
            return Column(children: items.map((v) => _voucherTile(v)).toList());
          },
        ),
        const SizedBox(height: 20),
        const Text(
          "Promo Codes",
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
        ),
        const SizedBox(height: 12),
        StreamBuilder<QuerySnapshot>(
          stream: firestore.collectionGroup("promo_codes").snapshots(),
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                ),
              );
            }
            if (!snap.hasData || snap.data!.docs.isEmpty) {
              return _emptyTile("No promo codes available yet");
            }
            final items = snap.data!.docs
                .map((d) => d.data() as Map<String, dynamic>)
                .toList();
            return Column(children: items.map((p) => _promoTile(p)).toList());
          },
        ),
      ],
    );
  }
}

// 🔹 helper widget: empty state
Widget _emptyTile(String message) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    margin: const EdgeInsets.only(bottom: 12),
    decoration: BoxDecoration(
      color: Colors.grey[100],
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      children: [
        const Icon(Icons.info_outline),
        const SizedBox(width: 10),
        Expanded(child: Text(message)),
      ],
    ),
  );
}

// 🔹 helper widget: voucher tile
Widget _voucherTile(Map<String, dynamic> v) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    margin: const EdgeInsets.only(bottom: 12),
    decoration: BoxDecoration(
      color: Colors.green[50],
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      children: [
        const Icon(Icons.local_offer, size: 24),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                v["title"] ?? "Voucher",
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              Text(
                v["description"] ?? "",
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
        Text(
          v["code"] ?? "",
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ],
    ),
  );
}

// 🔹 helper widget: promo code tile
Widget _promoTile(Map<String, dynamic> p) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    margin: const EdgeInsets.only(bottom: 12),
    decoration: BoxDecoration(
      color: Colors.orange[50],
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      children: [
        const Icon(Icons.card_giftcard, size: 24),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                p["title"] ?? "Promo code",
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              Text(
                p["description"] ?? "",
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
        Text(
          p["code"] ?? "",
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ],
    ),
  );
}
