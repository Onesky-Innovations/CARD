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

// Home tab showing shop info + own offers
class _HomeTab extends StatelessWidget {
  final String uid;
  const _HomeTab({required this.uid});

  final Color _primaryColor = const Color(0xFF1E212A);
  final Color _accentColor = const Color(0xFF61dafb);
  final Color _onPrimaryColor = Colors.white;

  @override
  Widget build(BuildContext context) {
    final firestore = FirebaseFirestore.instance;

    return FutureBuilder(
      future: firestore.collection("shop_owners").doc(uid).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator(color: _accentColor));
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return Center(
            child: Text(
              "No data found",
              style: TextStyle(color: _onPrimaryColor),
            ),
          );
        }

        var data = snapshot.data!.data() as Map<String, dynamic>;

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _onPrimaryColor.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: _accentColor.withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Shop: ${data['name']}",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: _accentColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Place: ${data['place']}",
                        style: TextStyle(
                          fontSize: 16,
                          color: _onPrimaryColor.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
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
                  child: StreamBuilder(
                    stream: firestore
                        .collection("shop_owners")
                        .doc(uid)
                        .collection("offers")
                        .orderBy("createdAt", descending: true)
                        .snapshots(),
                    builder: (context, offerSnapshot) {
                      if (!offerSnapshot.hasData) {
                        return Center(
                          child: CircularProgressIndicator(color: _accentColor),
                        );
                      }

                      var docs = offerSnapshot.data!.docs;
                      if (docs.isEmpty) {
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
                          var images = offer['images'] ?? [];
                          return Card(
                            color: _onPrimaryColor.withOpacity(0.05),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                color: _accentColor.withOpacity(0.1),
                              ),
                            ),
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            child: ListTile(
                              leading: images.isNotEmpty
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(
                                        images[0],
                                        width: 60,
                                        height: 60,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                Container(
                                                  width: 60,
                                                  height: 60,
                                                  color: Colors.grey,
                                                  child: Icon(
                                                    Icons.image,
                                                    color: _onPrimaryColor,
                                                  ),
                                                ),
                                      ),
                                    )
                                  : Container(
                                      width: 60,
                                      height: 60,
                                      decoration: BoxDecoration(
                                        color: _onPrimaryColor.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(
                                        Icons.local_offer,
                                        color: _onPrimaryColor,
                                      ),
                                    ),
                              title: Text(
                                offer['itemName'] ?? "",
                                style: TextStyle(
                                  color: _onPrimaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                "Offer: ₹${offer['offerPrice'] ?? ""}",
                                style: TextStyle(color: _accentColor),
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
      },
    );
  }
}
