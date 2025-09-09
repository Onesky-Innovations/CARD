import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProductDetailScreen extends StatefulWidget {
  final Map<String, dynamic> data;
  final String? offerDocPath;
  final bool initiallySaved;

  const ProductDetailScreen({
    super.key,
    required this.data,
    this.offerDocPath,
    this.initiallySaved = false,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  bool _saved = false;

  @override
  void initState() {
    super.initState();
    _saved = widget.initiallySaved;
  }

  String _savedDocIdForPath(String offerDocPath) =>
      offerDocPath.replaceAll("/", "__");

  Future<void> _toggleSave() async {
    final path = widget.offerDocPath;
    if (path == null) return;
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    final savedRef = _firestore
        .collection("card_holders")
        .doc(uid)
        .collection("saved_offers")
        .doc(_savedDocIdForPath(path));

    if (_saved) {
      await savedRef.delete();
      setState(() => _saved = false);
    } else {
      await savedRef.set({
        "offerDocPath": path,
        "savedAt": FieldValue.serverTimestamp(),
        "itemName": widget.data["itemName"],
        "description": widget.data["description"],
        "images": widget.data["images"],
        "mrp": widget.data["mrp"],
        "offerPrice": widget.data["offerPrice"],
        "category": widget.data["category"],
        "place": widget.data["place"],
        "district": widget.data["district"],
        "pinCodes": widget.data["pinCodes"],
        "clicks": widget.data["clicks"],
        "views": widget.data["views"],
        "offerEndDate": widget.data["offerEndDate"],
        "rating": widget.data["rating"],
      }, SetOptions(merge: true));
      setState(() => _saved = true);
    }
  }

  void _dummyCallShop() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Call Shop button clicked")));
  }

  void _dummyMapShop() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Map to Shop button clicked")));
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.data;
    final images = List<String>.from(data["images"] ?? []);
    final img = images.isNotEmpty ? images[0] : null;
    double? mrp = double.tryParse(data["mrp"]?.toString() ?? "");
    double? offerPrice = double.tryParse(data["offerPrice"]?.toString() ?? "");
    final rating = double.tryParse(data["rating"]?.toString() ?? "") ?? 4.5;

    return Scaffold(
      appBar: AppBar(
        title: Text(data["itemName"] ?? "Details"),
        actions: [
          IconButton(
            icon: Icon(
              _saved ? Icons.bookmark : Icons.bookmark_border,
              color: _saved ? Colors.blue : Colors.black87,
            ),
            onPressed: _toggleSave,
          ),
        ],
      ),
      body: ListView(
        children: [
          // image
          AspectRatio(
            aspectRatio: 1.2,
            child: img != null
                ? Image.network(img, fit: BoxFit.cover)
                : Container(
                    color: Colors.grey[200],
                    child: const Center(child: Icon(Icons.image, size: 60)),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // title + rating
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        data["itemName"] ?? "Untitled",
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    const Icon(Icons.star, size: 16, color: Colors.amber),
                    const SizedBox(width: 4),
                    Text(
                      rating.toStringAsFixed(1),
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // price
                Row(
                  children: [
                    if (offerPrice != null)
                      Text(
                        "₹${offerPrice.toStringAsFixed(0)}",
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 20,
                        ),
                      ),
                    const SizedBox(width: 8),
                    if (mrp != null)
                      Text(
                        "₹${mrp.toStringAsFixed(0)}",
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  data["description"] ?? "",
                  style: const TextStyle(fontSize: 14, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _dummyCallShop,
                  icon: const Icon(Icons.call),
                  label: const Text("Call Shop"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _dummyMapShop,
                  icon: const Icon(Icons.map),
                  label: const Text("Map to Shop"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
