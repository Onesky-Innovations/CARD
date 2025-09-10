import 'package:flutter/material.dart';

// Assuming these are defined elsewhere in your file
// String? cardholderName;
// String activePin = "";
// final TextEditingController _searchController = TextEditingController();
// String _searchQuery = "";
// int _selectedIndex = 0;
// void _showPinDialog() {}
// void _showLocationFilter() {}



class MyHomeScreen extends StatefulWidget {
  const MyHomeScreen({super.key});

  @override
  State<MyHomeScreen> createState() => _MyHomeScreenState();
}




class _MyHomeScreenState extends State<MyHomeScreen> {
  // Mock implementations for the variables and methods used in the original code
  String? cardholderName;
  String activePin = "12345";
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";
  int _selectedIndex = 0;

  Future<String?> _showPinDialog() async {
    // A placeholder for your dialog logic
    return Future.value("New PIN");
  }

  void _showLocationFilter() {
    // A placeholder for your filter logic
  }

  @override
  Widget build(BuildContext context) {

  Widget _buildQuickActions() {
    final items = [
      {"icon": Icons.category, "label": "Category", "onTap": () {}},
      {
        "icon": Icons.local_offer,
        "label": "Specials",
        "onTap": () => setState(() => _selectedIndex = 2),
      },
      {
        "icon": Icons.bookmark,
        "label": "Saved",
        "onTap": () => setState(() => _selectedIndex = 1),
      },
      {"icon": Icons.settings, "label": "Settings", "onTap": () {}},
    ];


    return SizedBox(
      height: 92,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (context, i) {
          final it = items[i];
          return InkWell(
            onTap: it["onTap"] as void Function()?,
            borderRadius: BorderRadius.circular(16),
            child: Column(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    it["icon"] as IconData,
                    size: 28,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  it["label"] as String,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            // Use floating and snap to achieve the desired effect\
            pinned: true,
            floating: true,
            snap: true,
            toolbarHeight: 60,
            titleSpacing: 0,
            title: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: _buildAvatarAndName(),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(60.0), // height for the search bar
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                child: _buildSearchBar(),
              ),
            ),
          ),
          // Your promo banner and other content, now as regular slivers
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
              child:Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPromoBanner(),
                  const SizedBox(height: 20),
                  _buildQuickActions(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          // Additional content to make the page scrollable
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                return ListTile(
                  title: Text('Item #$index'),
                );
              },
              childCount: 50, // Create a long list to enable scrolling
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: "Specials"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }

  Widget _buildAvatarAndName() {
    return Row(
      children: [
        CircleAvatar(
          backgroundColor: Colors.grey[300],
          child: const Icon(Icons.person, color: Colors.black87),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            cardholderName ?? "User",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
        // location chip with PIN
        GestureDetector(
          onTap: () async {
            final newPin = await _showPinDialog();
            if (newPin != null && newPin.isNotEmpty) {
              setState(() => activePin = newPin);
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.location_on,
                  size: 18,
                  color: Colors.black87,
                ),
                const SizedBox(width: 4),
                Text(activePin.isNotEmpty ? activePin : "Set PIN"),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: "Search products, categories, places...",
        prefixIcon: const Icon(Icons.search),
        filled: true,
        fillColor: Colors.grey[200],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25),
          borderSide: BorderSide.none,
        ),
        suffixIcon: IconButton(
          icon: const Icon(Icons.tune),
          onPressed: _showLocationFilter,
          tooltip: "Location filter",
        ),
      ),
      onChanged: (val) {
        setState(() => _searchQuery = val.toLowerCase());
      },
    );
  }

  Widget _buildPromoBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFE0B2), Color(0xFFFFCC80)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              "Best Deals • Up to 80% OFF",
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() => _selectedIndex = 2); // jump to Specials
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black87,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            child: const Text("Explore"),
          ),
        ],
      ),
    );
  }
}