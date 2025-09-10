import 'package:card/card_Holders/product_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';


class SavedTab extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Future<void> Function(String, Map<String, dynamic>, bool) onToggleSave;

  SavedTab({super.key, required this.onToggleSave});

  @override
  Widget build(BuildContext context) {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      return const Center(child: Text("Please sign in."));
    }
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection("card_holders")
          .doc(uid)
          .collection("saved_offers")
          .orderBy("savedAt", descending: true)
          .snapshots(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snap.hasData || snap.data!.docs.isEmpty) {
          return const Center(child: Text("Nothing saved yet"));
        }
        final saved = snap.data!.docs
            .map((d) => d.data() as Map<String, dynamic>)
            .toList();

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.68,
          ),
          itemCount: saved.length,
          itemBuilder: (context, i) {
            final data = saved[i];
            final docPath = data["offerDocPath"] as String;

            return _SavedOfferCard(
              data: data,
              onRemove: () => onToggleSave(docPath, data, true),
            );
          },
        );
      },
    );
  }
}

// --- Small SavedCard widget (minimal reuse of _OfferCard) ---
class _SavedOfferCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final VoidCallback onRemove;

  const _SavedOfferCard({
    required this.data,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final images = List<String>.from(data["images"] ?? []);
    final img = images.isNotEmpty ? images[0] : null;

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailScreen(
              data: data,
              offerDocPath: data["offerDocPath"],
              initiallySaved: true,
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
        child: Column(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                child: img != null
                    ? Image.network(img, width: double.infinity, fit: BoxFit.cover)
                    : Container(
                        color: Colors.grey[200],
                        child: const Center(
                          child: Icon(Icons.shopping_bag_outlined, size: 40),
                        ),
                      ),
              ),
            ),
            ListTile(
              title: Text(data["itemName"] ?? "Untitled",
                  maxLines: 1, overflow: TextOverflow.ellipsis),
              subtitle: Text(
                data["description"] ?? "",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: onRemove,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
