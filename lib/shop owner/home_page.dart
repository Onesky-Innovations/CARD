import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'AddOfferPage.dart'; // Assuming this page exists for editing

// Assuming these pages exist
import 'DiscoverPage.dart';
import 'ProfilePage.dart';

// Helper function to format the time since creation and the full date.
String _formatPostedDate(dynamic timestamp) {
  if (timestamp is! Timestamp) {
    return "Date not available";
  }
  final now = DateTime.now();
  final date = timestamp.toDate();
  final difference = now.difference(date);

  String timeAgo;
  if (difference.inDays > 0) {
    timeAgo = "${difference.inDays}d ago";
  } else if (difference.inHours > 0) {
    timeAgo = "${difference.inHours}h ago";
  } else if (difference.inMinutes > 0) {
    timeAgo = "${difference.inMinutes}m ago";
  } else {
    timeAgo = "Just now";
  }

  final fullDate = DateFormat('dd/MM/yyyy').format(date);
  return "$timeAgo ($fullDate)";
}

// Helper function to format the offer period
String _formatOfferPeriod(Timestamp startDate, Timestamp endDate) {
  final start = DateFormat('dd/MM/yyyy').format(startDate.toDate());
  final end = DateFormat('dd/MM/yyyy').format(endDate.toDate());
  return "$start → $end";
}

// Helper function to get the "ending soon" text
String? _getEndingSoonText(Timestamp endDate) {
  final now = DateTime.now();
  final remainingDays = endDate.toDate().difference(now).inDays;
  if (remainingDays <= 5 && remainingDays >= 0) {
    return "⚠️ Ending soon! Only $remainingDays days left";
  } else if (remainingDays < 0) {
    return "⚠️ Offer ended";
  }
  return null;
}

class HomePage extends StatefulWidget {
  final String uid;
  const HomePage({required this.uid, super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  late final List<Widget> _pages;

  final Color _primaryColor = const Color(0xFF1E212A);
  final Color _accentColor = const Color(0xFF61dafb);
  final Color _onPrimaryColor = Colors.white;

  @override
  void initState() {
    super.initState();
    _pages = [
      _HomeTab(uid: widget.uid),
      DiscoverPage(uid: widget.uid),
      AddOfferPage(uid: widget.uid), // This is for adding, not editing
      ProfilePage(uid: widget.uid),
    ];
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _primaryColor,
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: _primaryColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          backgroundColor: _primaryColor,
          type: BottomNavigationBarType.fixed,
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          elevation: 0,
          selectedItemColor: _accentColor,
          unselectedItemColor: _onPrimaryColor.withOpacity(0.6),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
            BottomNavigationBarItem(
              icon: Icon(Icons.search),
              label: "Discover",
            ),
            BottomNavigationBarItem(icon: Icon(Icons.add), label: "Add Offer"),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
          ],
        ),
      ),
    );
  }
}

// Home tab with search, filter, sort, and offer management
class _HomeTab extends StatefulWidget {
  final String uid;
  const _HomeTab({required this.uid});

  @override
  State<_HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<_HomeTab> {
  final Color _primaryColor = const Color(0xFF1E212A);
  final Color _accentColor = const Color(0xFF61dafb);
  final Color _onPrimaryColor = Colors.white;

  final TextEditingController _searchController = TextEditingController();
  String _effectiveSearchQuery = "";
  String filterMode = "all"; // all, active, hidden
  String sortMode = "date"; // date, price

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Widget _buildOfferPost(
    Map<String, dynamic> offer,
    String shopName,
    String uid,
    String docId,
  ) {
    var images = offer['images'] ?? [];
    var createdAt = offer['createdAt'] as Timestamp?;
    bool isHidden = offer['hidden'] ?? false;
    var startDate = offer['startDate'] as Timestamp?;
    var endDate = offer['endDate'] as Timestamp?;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OfferDetailsPage(
              offer: offer,
              shopName: shopName,
              uid: uid,
              docId: docId,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: _onPrimaryColor.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Item name + menu
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      offer['itemName'] ?? "Offer",
                      style: TextStyle(
                        color: _onPrimaryColor,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  PopupMenuButton<String>(
                    icon: Icon(Icons.more_vert, color: _onPrimaryColor),
                    onSelected: (value) async {
                      final docRef = FirebaseFirestore.instance
                          .collection("shop_owners")
                          .doc(uid)
                          .collection("offers")
                          .doc(docId);

                      if (value == "edit") {
                        // Pass the entire offer map to the AddOfferPage for editing.
                        // This allows the page to pre-fill the form with existing data.
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AddOfferPage(
                              uid: uid,
                              offerToEdit: offer,
                              offerId: docId,
                            ),
                          ),
                        );
                      } else if (value == "delete") {
                        // Delete the document from Firestore.
                        await docRef.delete();
                      } else if (value == "toggle") {
                        // Toggle the 'hidden' status. The UI will automatically update.
                        await docRef.update({
                          "hidden": !(offer['hidden'] ?? false),
                        });
                      } else if (value == "download") {
                        // TODO: Implement image download logic
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              "Download functionality coming soon!",
                            ),
                          ),
                        );
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: "edit", child: Text("Edit")),
                      const PopupMenuItem(
                        value: "delete",
                        child: Text("Delete"),
                      ),
                      PopupMenuItem(
                        value: "toggle",
                        child: Text(offer['hidden'] == true ? "Show" : "Hide"),
                      ),
                      const PopupMenuItem(
                        value: "download",
                        child: Text("Download"),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Image
            if (images.isNotEmpty)
              Container(
                height: 200,
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 12),
                child: Image.network(
                  images[0],
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: _onPrimaryColor.withOpacity(0.1),
                    child: Center(
                      child: Icon(
                        Icons.image_not_supported,
                        size: 50,
                        color: _onPrimaryColor.withOpacity(0.6),
                      ),
                    ),
                  ),
                ),
              )
            else
              Container(
                height: 200,
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: _onPrimaryColor.withOpacity(0.1),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.image,
                    size: 80,
                    color: _onPrimaryColor.withOpacity(0.5),
                  ),
                ),
              ),

            // Description
            if (offer['description'] != null &&
                (offer['description'] as String).isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 4.0,
                ),
                child: Text(
                  offer['description'],
                  style: TextStyle(
                    color: _onPrimaryColor.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
              ),

            // Branches
            if (offer['branches'] != null &&
                (offer['branches'] as List).isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 4.0,
                ),
                child: Text(
                  "Branches: ${(offer['branches'] as List).join(", ")}",
                  style: TextStyle(
                    color: _onPrimaryColor.withOpacity(0.8),
                    fontSize: 13,
                  ),
                ),
              ),

            // Price + MRP
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 4.0,
              ),
              child: Row(
                children: [
                  Text(
                    "Offer: ₹${offer['offerPrice'] ?? ""}",
                    style: TextStyle(
                      color: _accentColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(width: 10),
                  if (offer['mrp'] != null)
                    Text(
                      "MRP: ₹${offer['mrp']}",
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 14,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                ],
              ),
            ),

            // Offer Period, Ending Soon, and Created Date
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 4.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Offer Period
                  if (startDate != null && endDate != null)
                    Text(
                      "Offer Period: ${_formatOfferPeriod(startDate, endDate)}",
                      style: TextStyle(
                        color: _onPrimaryColor.withOpacity(0.8),
                        fontSize: 13,
                      ),
                    ),
                  // Ending Soon warning
                  if (endDate != null)
                    _getEndingSoonText(endDate) != null
                        ? Text(
                            _getEndingSoonText(endDate)!,
                            style: TextStyle(
                              color: Colors.orange,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          )
                        : const SizedBox.shrink(),
                  // Created date
                  Text(
                    _formatPostedDate(createdAt),
                    style: TextStyle(
                      color: _onPrimaryColor.withOpacity(0.6),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            // Actions
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Row(
                children: [
                  Icon(Icons.favorite_border, color: _onPrimaryColor),
                  const SizedBox(width: 16),
                  Icon(Icons.bookmark_border, color: _onPrimaryColor),
                  const SizedBox(width: 16),
                  Icon(Icons.share, color: _onPrimaryColor),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final firestore = FirebaseFirestore.instance;

    return FutureBuilder<DocumentSnapshot>(
      future: firestore.collection("shop_owners").doc(widget.uid).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator(color: _accentColor));
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return Center(
            child: Text(
              "No shop data found",
              style: TextStyle(color: _onPrimaryColor),
            ),
          );
        }

        var data = snapshot.data!.data() as Map<String, dynamic>;
        var shopName = data['name'] ?? 'Your Shop';
        var shopPlace = data['place'] ?? 'Unknown Place';

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Shop info + search bar
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: _onPrimaryColor.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.store, color: _accentColor, size: 28),
                      const SizedBox(width: 12),
                      // Shop info
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              shopName,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: _accentColor,
                              ),
                            ),
                            Text(
                              shopPlace,
                              style: TextStyle(
                                fontSize: 14,
                                color: _onPrimaryColor.withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Search field and button
                      Expanded(
                        flex: 3,
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: "Search offers...",
                            hintStyle: TextStyle(
                              color: _onPrimaryColor.withOpacity(0.6),
                            ),
                            filled: true,
                            fillColor: _onPrimaryColor.withOpacity(0.1),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                Icons.search,
                                color: _onPrimaryColor.withOpacity(0.8),
                              ),
                              onPressed: () {
                                setState(() {
                                  _effectiveSearchQuery = _searchController.text
                                      .toLowerCase();
                                });
                              },
                            ),
                          ),
                          style: TextStyle(color: _onPrimaryColor),
                          onSubmitted: (value) {
                            setState(() {
                              _effectiveSearchQuery = value.toLowerCase();
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // Clear search chip
                if (_effectiveSearchQuery.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Chip(
                        label: Text(
                          'Clear Search: "${_effectiveSearchQuery}"',
                          style: TextStyle(color: _primaryColor),
                        ),
                        backgroundColor: _accentColor,
                        deleteIcon: Icon(Icons.close, color: _primaryColor),
                        onDeleted: () {
                          setState(() {
                            _effectiveSearchQuery = "";
                            _searchController.clear();
                          });
                        },
                      ),
                    ),
                  ),

                // Filter + Sort
                Row(
                  children: [
                    DropdownButton<String>(
                      value: filterMode,
                      dropdownColor: _primaryColor,
                      style: TextStyle(color: _onPrimaryColor),
                      items: const [
                        DropdownMenuItem(
                          value: "all",
                          child: Text("All Offers"),
                        ),
                        DropdownMenuItem(
                          value: "active",
                          child: Text("Active"),
                        ),
                        DropdownMenuItem(
                          value: "hidden",
                          child: Text("Hidden"),
                        ),
                      ],
                      onChanged: (value) =>
                          setState(() => filterMode = value ?? "all"),
                    ),
                    const SizedBox(width: 20),
                    DropdownButton<String>(
                      value: sortMode,
                      dropdownColor: _primaryColor,
                      style: TextStyle(color: _onPrimaryColor),
                      items: const [
                        DropdownMenuItem(
                          value: "date",
                          child: Text("Sort by Date"),
                        ),
                        DropdownMenuItem(
                          value: "price",
                          child: Text("Sort by Price"),
                        ),
                      ],
                      onChanged: (value) =>
                          setState(() => sortMode = value ?? "date"),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: firestore
                        .collection("shop_owners")
                        .doc(widget.uid)
                        .collection("offers")
                        .snapshots(),
                    builder: (context, offerSnapshot) {
                      if (offerSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return Center(
                          child: CircularProgressIndicator(color: _accentColor),
                        );
                      }

                      if (!offerSnapshot.hasData ||
                          offerSnapshot.data!.docs.isEmpty) {
                        return Center(
                          child: Text(
                            "No offers posted yet",
                            style: TextStyle(
                              color: _onPrimaryColor.withOpacity(0.8),
                            ),
                          ),
                        );
                      }

                      var docs = offerSnapshot.data!.docs;

                      // Filtering
                      docs = docs.where((doc) {
                        var data = doc.data() as Map<String, dynamic>;
                        var name = (data['itemName'] ?? "")
                            .toString()
                            .toLowerCase();
                        var hidden = data['hidden'] ?? false;

                        if (filterMode == "active" && hidden) return false;
                        if (filterMode == "hidden" && !hidden) return false;
                        if (_effectiveSearchQuery.isNotEmpty &&
                            !name.contains(_effectiveSearchQuery))
                          return false;
                        return true;
                      }).toList();

                      // Sorting
                      docs.sort((a, b) {
                        var dataA = a.data() as Map<String, dynamic>;
                        var dataB = b.data() as Map<String, dynamic>;

                        if (sortMode == "price") {
                          num priceA = dataA['offerPrice'] ?? 0;
                          num priceB = dataB['offerPrice'] ?? 0;
                          return priceA.compareTo(priceB);
                        } else {
                          Timestamp tA = dataA['createdAt'] ?? Timestamp.now();
                          Timestamp tB = dataB['createdAt'] ?? Timestamp.now();
                          return tB.compareTo(tA);
                        }
                      });

                      if (docs.isEmpty && _effectiveSearchQuery.isNotEmpty) {
                        return Center(
                          child: Text(
                            "No offers found for '$_effectiveSearchQuery'",
                            style: TextStyle(
                              color: _onPrimaryColor.withOpacity(0.8),
                            ),
                          ),
                        );
                      } else if (docs.isEmpty) {
                        return Center(
                          child: Text(
                            "No offers posted yet",
                            style: TextStyle(
                              color: _onPrimaryColor.withOpacity(0.8),
                            ),
                          ),
                        );
                      }

                      return ListView.builder(
                        itemCount: docs.length,
                        itemBuilder: (context, index) {
                          var offer =
                              docs[index].data() as Map<String, dynamic>;
                          return _buildOfferPost(
                            offer,
                            shopName,
                            widget.uid,
                            docs[index].id,
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
      },
    );
  }
}

class OfferDetailsPage extends StatelessWidget {
  final Map<String, dynamic> offer;
  final String shopName;
  final String uid;
  final String docId;

  const OfferDetailsPage({
    super.key,
    required this.offer,
    required this.shopName,
    required this.uid,
    required this.docId,
  });

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = const Color(0xFF1E212A);
    final Color accentColor = const Color(0xFF61dafb);
    final Color onPrimaryColor = Colors.white;

    var images = offer['images'] ?? [];
    bool isHidden = offer['hidden'] ?? false;
    var createdAt = offer['createdAt'] as Timestamp?;
    var startDate = offer['startDate'] as Timestamp?;
    var endDate = offer['endDate'] as Timestamp?;

    return Scaffold(
      backgroundColor: primaryColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        title: Text(shopName, style: TextStyle(color: onPrimaryColor)),
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: onPrimaryColor),
            onSelected: (value) async {
              if (value == "edit") {
                Navigator.of(context).pop(); // Go back to the main page first
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AddOfferPage(
                      uid: uid,
                      offerToEdit: offer,
                      offerId: docId,
                    ),
                  ),
                );
              } else if (value == "delete") {
                Navigator.of(context).pop();
                final docRef = FirebaseFirestore.instance
                    .collection("shop_owners")
                    .doc(uid)
                    .collection("offers")
                    .doc(docId);
                await docRef.delete();
              } else if (value == "toggle") {
                Navigator.of(context).pop();
                final docRef = FirebaseFirestore.instance
                    .collection("shop_owners")
                    .doc(uid)
                    .collection("offers")
                    .doc(docId);
                await docRef.update({"hidden": !isHidden});
              } else if (value == "download") {
                Navigator.of(context).pop();
                // TODO: Implement image download logic here
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Download functionality coming soon!"),
                  ),
                );
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: "edit", child: Text("Edit")),
              const PopupMenuItem(value: "delete", child: Text("Delete")),
              PopupMenuItem(
                value: "toggle",
                child: Text(isHidden ? "Show" : "Hide"),
              ),
              const PopupMenuItem(value: "download", child: Text("Download")),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            if (images.isNotEmpty)
              Container(
                height: MediaQuery.of(context).size.height * 0.4,
                width: double.infinity,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(images[0]),
                    fit: BoxFit.cover,
                  ),
                ),
              )
            else
              Container(
                height: MediaQuery.of(context).size.height * 0.4,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: onPrimaryColor.withOpacity(0.1),
                ),
                child: Center(
                  child: Icon(
                    Icons.image,
                    size: 100,
                    color: onPrimaryColor.withOpacity(0.5),
                  ),
                ),
              ),

            // Title and Details
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    offer['itemName'] ?? "Offer",
                    style: TextStyle(
                      color: onPrimaryColor,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (offer['description'] != null &&
                      (offer['description'] as String).isNotEmpty)
                    Text(
                      offer['description'],
                      style: TextStyle(
                        color: onPrimaryColor.withOpacity(0.9),
                        fontSize: 16,
                      ),
                    ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        "Offer: ₹${offer['offerPrice'] ?? ""}",
                        style: TextStyle(
                          color: accentColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(width: 10),
                      if (offer['mrp'] != null)
                        Text(
                          "MRP: ₹${offer['mrp']}",
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 16,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (offer['branches'] != null &&
                      (offer['branches'] as List).isNotEmpty)
                    Text(
                      "Branches: ${(offer['branches'] as List).join(", ")}",
                      style: TextStyle(
                        color: onPrimaryColor.withOpacity(0.8),
                        fontSize: 14,
                      ),
                    ),
                  const SizedBox(height: 8),
                  if (startDate != null && endDate != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4.0),
                      child: Text(
                        "Offer Period: ${_formatOfferPeriod(startDate, endDate)}",
                        style: TextStyle(
                          color: onPrimaryColor.withOpacity(0.8),
                          fontSize: 14,
                        ),
                      ),
                    ),
                  if (endDate != null)
                    _getEndingSoonText(endDate) != null
                        ? Text(
                            _getEndingSoonText(endDate)!,
                            style: TextStyle(
                              color: Colors.orange,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          )
                        : const SizedBox.shrink(),
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      _formatPostedDate(createdAt),
                      style: TextStyle(
                        color: onPrimaryColor.withOpacity(0.6),
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Action Icons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Icon(
                        Icons.favorite_border,
                        color: onPrimaryColor,
                        size: 30,
                      ),
                      Icon(
                        Icons.bookmark_border,
                        color: onPrimaryColor,
                        size: 30,
                      ),
                      Icon(Icons.share, color: onPrimaryColor, size: 30),
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

// remember thuis - add - a confirmation before deleting a post
