// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:card/card_Holders/widgets/offer_card.dart';
// import 'package:card/card_Holders/product_detail_screen.dart';

// class SavedTab extends StatelessWidget {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final Future<void> Function(String, Map<String, dynamic>, bool) onToggleSave;

//   SavedTab({super.key, required this.onToggleSave});

//   @override
//   Widget build(BuildContext context) {
//     final uid = _auth.currentUser?.uid;
//     if (uid == null) return const Center(child: Text("Please sign in."));

//     return StreamBuilder<QuerySnapshot>(
//       stream: _firestore
//           .collection("card_holders")
//           .doc(uid)
//           .collection("saved_offers")
//           .orderBy("savedAt", descending: true)
//           .snapshots(),
//       builder: (context, snap) {
//         if (snap.connectionState == ConnectionState.waiting) {
//           return const Center(child: CircularProgressIndicator());
//         }
//         if (!snap.hasData || snap.data!.docs.isEmpty) {
//           return const Center(child: Text("Nothing saved yet"));
//         }

//         final savedOffers = snap.data!.docs
//             .map((d) => d.data() as Map<String, dynamic>)
//             .toList();

//         return GridView.builder(
//           padding: const EdgeInsets.all(16),
//           gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//             crossAxisCount: 2,
//             crossAxisSpacing: 12,
//             mainAxisSpacing: 12,
//             childAspectRatio: 0.68,
//           ),
//           itemCount: savedOffers.length,
//           itemBuilder: (context, i) {
//             final data = savedOffers[i];
//             final docPath = data["offerDocPath"] as String;

//             return OfferCard(
//               data: data,
//               saved: true,
//               onToggleSave: (currentlySaved) =>
//                   onToggleSave(docPath, data, currentlySaved),
//               onTap: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (_) => ProductDetailScreen(
//                       data: data,
//                       offerDocPath: docPath,
//                       initiallySaved: true,
//                     ),
//                   ),
//                 );
//               },
//             );
//           },
//         );
//       },
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:card/card_Holders/widgets/offer_card.dart';
import 'package:card/card_Holders/product_detail_screen.dart';
import 'package:card/card_Holders/services/saved_offers_service.dart';

class SavedTab extends StatelessWidget {
  final SavedOffersService savedOffersService;
  final Future<void> Function(String, Map<String, dynamic>, bool) onToggleSave;

  const SavedTab({
    super.key,
    required this.savedOffersService,
    required this.onToggleSave,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: savedOffersService.savedOffersStream(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final savedOffers = snap.data ?? [];
        if (savedOffers.isEmpty) {
          return const Center(child: Text("Nothing saved yet"));
        }

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.68,
          ),
          itemCount: savedOffers.length,
          itemBuilder: (context, i) {
            final data = savedOffers[i];
            final docPath = data["offerDocPath"] as String;

            return OfferCard(
              data: data,
              saved: true,
              onToggleSave: (currentlySaved) =>
                  onToggleSave(docPath, data, currentlySaved),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProductDetailScreen(
                      data: data,
                      offerDocPath: docPath,
                      initiallySaved: true,
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
