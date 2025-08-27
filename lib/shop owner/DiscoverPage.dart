import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DiscoverPage extends StatelessWidget {
  final String uid;
  const DiscoverPage({required this.uid, super.key});

  @override
  Widget build(BuildContext context) {
    final firestore = FirebaseFirestore.instance;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Discover Offers",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: firestore
                    .collectionGroup('offers')
                    .where('ownerId', isNotEqualTo: uid)
                    .orderBy('createdAt', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text("No offers available"));
                  }

                  final offers = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: offers.length,
                    itemBuilder: (context, index) {
                      var offer = offers[index].data()! as Map<String, dynamic>;
                      var images = offer['images'] ?? [];

                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (images.isNotEmpty)
                                SizedBox(
                                  height: 180,
                                  child: PageView(
                                    children: images
                                        .map<Widget>(
                                          (img) => ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            child: Image.network(
                                              img,
                                              fit: BoxFit.cover,
                                              width: double.infinity,
                                            ),
                                          ),
                                        )
                                        .toList(),
                                  ),
                                ),
                              const SizedBox(height: 8),
                              Text(
                                offer['itemName'] ?? "",
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "MRP: ₹${offer['mrp'] ?? ""}  |  Offer: ₹${offer['offerPrice'] ?? ""}",
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Branches: ${((offer['branches'] ?? []) as List).join(', ')}",
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Offer ends: ${offer['offerEndDate'] != null ? (offer['offerEndDate'] as Timestamp).toDate().toLocal().toString().split(' ')[0] : 'N/A'}",
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
