import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:card/card_Holders/widgets/offer_card.dart';
import 'package:card/card_Holders/product_detail_screen.dart';

class OffersGrid extends StatelessWidget {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;
  final String searchQuery;
  final String selectedCategory;
  final String locationScope;
  final String activePin;
  final String? cardholderPlace;
  final String? cardholderDistrict;
  final String sortOption;

  /// Callback provided from Dashboard
  /// (String docPath, Map<String,dynamic> data, bool currentlySaved)
  final Future<void> Function(String, Map<String, dynamic>, bool) onToggleSave;

  const OffersGrid({
    super.key,
    required this.firestore,
    required this.auth,
    required this.searchQuery,
    required this.selectedCategory,
    required this.locationScope,
    required this.activePin,
    required this.cardholderPlace,
    required this.cardholderDistrict,
    required this.sortOption,
    required this.onToggleSave,
    required bool shrinkWrap,
    required NeverScrollableScrollPhysics physics,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: firestore.collectionGroup("offers").snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("No offers available"));
        }

        // All offers
        final docs = snapshot.data!.docs;
        final allOffers = docs
            .map(
              (d) => {
                ...((d.data() as Map<String, dynamic>)),
                "_docPath": d.reference.path,
              },
            )
            .toList();

        // Apply filters
        List<Map<String, dynamic>> filtered = allOffers.where((data) {
          final name = (data["itemName"] ?? "").toString().toLowerCase();
          final desc = (data["description"] ?? "").toString().toLowerCase();
          final category = (data["category"] ?? "").toString().toLowerCase();
          final offerPinList = List<String>.from(data["pinCodes"] ?? []);
          final offerPlace = (data["place"] ?? "").toString().toLowerCase();
          final offerDistrict = (data["district"] ?? "")
              .toString()
              .toLowerCase();

          // 🔎 Search filter
          if (searchQuery.isNotEmpty &&
              !(name.contains(searchQuery) ||
                  desc.contains(searchQuery) ||
                  category.contains(searchQuery))) {
            return false;
          }

          // 🏷️ Category filter
          if (selectedCategory != "All" &&
              category != selectedCategory.toLowerCase()) {
            return false;
          }

          // 📍 Location filter
          bool match = true;
          switch (locationScope) {
            case "My Pincode":
              match = activePin.isNotEmpty && offerPinList.contains(activePin);
              break;
            case "My City":
              match =
                  cardholderPlace != null &&
                  offerPlace == cardholderPlace!.toLowerCase();
              break;
            case "My District":
              match =
                  cardholderDistrict != null &&
                  offerDistrict == cardholderDistrict!.toLowerCase();
              break;
            case "My Area":
              final byPin =
                  activePin.isNotEmpty && offerPinList.contains(activePin);
              final byCity =
                  cardholderPlace != null &&
                  offerPlace == cardholderPlace!.toLowerCase();
              final byDistrict =
                  cardholderDistrict != null &&
                  offerDistrict == cardholderDistrict!.toLowerCase();
              match = byPin || byCity || byDistrict;
              break;
            case "All":
            default:
              match = true;
          }
          return match;
        }).toList();

        // fallback to all offers if filter returned nothing
        final offers = filtered.isEmpty ? allOffers : filtered;

        // 🌀 Sorting
        if (sortOption.isNotEmpty) {
          offers.sort((a, b) {
            double discountA = 0, discountB = 0;
            double? mrpA = double.tryParse(a["mrp"]?.toString() ?? "");
            double? offerA = double.tryParse(a["offerPrice"]?.toString() ?? "");
            double? mrpB = double.tryParse(b["mrp"]?.toString() ?? "");
            double? offerB = double.tryParse(b["offerPrice"]?.toString() ?? "");

            if (mrpA != null && offerA != null && mrpA > 0) {
              discountA = ((mrpA - offerA) / mrpA) * 100;
            }
            if (mrpB != null && offerB != null && mrpB > 0) {
              discountB = ((mrpB - offerB) / mrpB) * 100;
            }

            switch (sortOption) {
              case "Biggest Discount":
                return discountB.compareTo(discountA);
              case "Ending Soon":
                DateTime? endA = DateTime.tryParse(
                  a["offerEndDate"]?.toString() ?? "",
                );
                DateTime? endB = DateTime.tryParse(
                  b["offerEndDate"]?.toString() ?? "",
                );
                if (endA != null && endB != null) {
                  return endA.compareTo(endB);
                }
                return 0;
              case "Most Popular":
                int viewsA = a["views"] ?? 0;
                int viewsB = b["views"] ?? 0;
                return viewsB.compareTo(viewsA);
              case "Trending":
                int clicksA = a["clicks"] ?? 0;
                int clicksB = b["clicks"] ?? 0;
                return clicksB.compareTo(clicksA);
              default:
                return 0;
            }
          });
        }

        // ✅ Saved overlay state stream
        final uid = auth.currentUser?.uid;
        if (uid == null) {
          return const Center(child: Text("Please sign in."));
        }

        return StreamBuilder<QuerySnapshot>(
          stream: firestore
              .collection("card_holders")
              .doc(uid)
              .collection("saved_offers")
              .snapshots(),
          builder: (context, savedSnapshot) {
            final savedPaths = savedSnapshot.hasData
                ? savedSnapshot.data!.docs
                      .map(
                        (d) =>
                            (d.data() as Map<String, dynamic>)["offerDocPath"]
                                as String,
                      )
                      .toSet()
                : <String>{};

            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.68,
              ),
              itemCount: offers.length,
              itemBuilder: (context, index) {
                final data = offers[index];
                final docPath = data["_docPath"] as String;
                final isSaved = savedPaths.contains(docPath);

                return OfferCard(
                  data: data,
                  saved: isSaved,
                  onToggleSave: (bool currentlySaved) =>
                      onToggleSave(docPath, data, currentlySaved),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProductDetailScreen(
                          data: data,
                          offerDocPath: docPath,
                          initiallySaved: isSaved,
                        ),
                      ),
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}
