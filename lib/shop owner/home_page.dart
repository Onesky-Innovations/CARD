import 'package:flutter/material.dart';
import 'AddOfferPage.dart';
import 'DiscoverPage.dart';
import 'ProfilePage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
      AddOfferPage(uid: widget.uid),
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
            BottomNavigationBarItem(icon: Icon(Icons.search), label: "Discover"),
            BottomNavigationBarItem(icon: Icon(Icons.add), label: "Add Offer"),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
          ],
        ),
      ),
    );
  }
}

// Home tab showing shop info + own offers
class _HomeTab extends StatelessWidget {
  final String uid;
  const _HomeTab({required this.uid});

  final Color _primaryColor = const Color(0xFF1E212A);
  final Color _accentColor = const Color(0xFF61dafb);
  final Color _onPrimaryColor = Colors.white;

  String _formatTimestamp(Timestamp timestamp) {
    final now = DateTime.now();
    final date = timestamp.toDate();
    final difference = now.difference(date);
    if (difference.inMinutes < 60) {
      return "${difference.inMinutes}m ago";
    } else if (difference.inHours < 24) {
      return "${difference.inHours}h ago";
    } else if (difference.inDays < 30) {
      return "${difference.inDays}d ago";
    } else {
      return "${date.day}/${date.month}/${date.year}";
    }
  }

  Widget _buildOfferPost(
      Map<String, dynamic> offer, String shopName, String uid) {
    var images = offer['images'] ?? [];
    var createdAt = offer['createdAt'] as Timestamp?;
    final formattedTime = createdAt != null ? _formatTimestamp(createdAt) : "";

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: _onPrimaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Item name + time row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  offer['itemName'] ?? "Offer",
                  style: TextStyle(
                    color: _onPrimaryColor,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (formattedTime.isNotEmpty)
                  Text(
                    formattedTime,
                    style: TextStyle(
                      color: _onPrimaryColor.withOpacity(0.6),
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
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
            ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
            child: Text(
              "Offer: ₹${offer['offerPrice'] ?? ""}",
              style: TextStyle(
                color: _accentColor,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: [
                Icon(Icons.favorite_border, color: _onPrimaryColor),
                const SizedBox(width: 16),
                Icon(Icons.share, color: _onPrimaryColor),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final firestore = FirebaseFirestore.instance;

    return FutureBuilder<DocumentSnapshot>(
      future: firestore.collection("shop_owners").doc(uid).get(),
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
                // Shop info header
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: _onPrimaryColor.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: _accentColor.withOpacity(0.2),
                            child: Icon(Icons.store, color: _accentColor),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            shopName,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: _accentColor,
                            ),
                          ),
                        ],
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
                const SizedBox(height: 20),
                Text(
                  "Your Offers",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: _onPrimaryColor,
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: firestore
                        .collection("shop_owners")
                        .doc(uid)
                        .collection("offers")
                        .orderBy("createdAt", descending: true)
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

                      return ListView.builder(
                        itemCount: docs.length,
                        itemBuilder: (context, index) {
                          var offer =
                              docs[index].data() as Map<String, dynamic>;
                          return _buildOfferPost(offer, shopName, uid);
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
