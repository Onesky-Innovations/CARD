// lib/card/card_Holders/widgets/offer_card.dart
import 'package:flutter/material.dart';

class OfferCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final bool saved;
  final ValueChanged<bool> onToggleSave;
  final VoidCallback onTap;

  const OfferCard({
    super.key,
    required this.data,
    required this.saved,
    required this.onToggleSave,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final images = List<String>.from(data["images"] ?? []);
    final img = images.isNotEmpty ? images[0] : null;

    double? mrp = double.tryParse(data["mrp"]?.toString() ?? "");
    double? offerPrice = double.tryParse(data["offerPrice"]?.toString() ?? "");
    String discountText = "";
    if (mrp != null && offerPrice != null && mrp > 0) {
      discountText =
          "${(((mrp - offerPrice) / mrp) * 100).toStringAsFixed(0)}% OFF";
    }
    final rating = double.tryParse(data["rating"]?.toString() ?? "") ?? 4.5;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // image + top-right save button
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                  child: img != null
                      ? Image.network(
                          img,
                          width: double.infinity,
                          height: 140,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          height: 140,
                          color: Colors.grey[200],
                          child: const Center(
                            child: Icon(Icons.shopping_bag_outlined, size: 40),
                          ),
                        ),
                ),
                Positioned(
                  right: 8,
                  top: 8,
                  child: InkWell(
                    onTap: () => onToggleSave(saved),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        saved ? Icons.bookmark : Icons.bookmark_border,
                        size: 18,
                        color: saved ? Colors.blue : Colors.black87,
                      ),
                    ),
                  ),
                ),
                if (discountText.isNotEmpty)
                  Positioned(
                    left: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        discountText,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data["itemName"] ?? "Untitled",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    data["description"] ?? "",
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (offerPrice != null)
                        Text(
                          "₹${offerPrice.toStringAsFixed(0)}",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.black,
                          ),
                        ),
                      // Star Rating
                      Row(
                        children: List.generate(
                          5,
                          (starIndex) => Icon(
                            Icons.star,
                            size: 14,
                            color: starIndex < rating
                                ? Colors.orange
                                : Colors.grey.shade300,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
