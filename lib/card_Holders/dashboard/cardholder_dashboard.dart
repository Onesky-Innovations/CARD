import 'package:card/card_Holders/services/profile_service.dart';
import 'package:card/card_Holders/services/saved_offers_service.dart';
import 'package:card/card_Holders/widgets/best_deals_banner.dart';
import 'package:card/card_Holders/widgets/cardholder_info.dart';
import 'package:card/card_Holders/widgets/search_filter_bar.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../tabs/saved_tab.dart';
import '../tabs/specials_tab.dart';
import '../tabs/profile_tab.dart';
import 'quick_actions.dart';
import 'offers_grid.dart';
import 'sort_chips.dart';

class CardholderDashboard extends StatefulWidget {
  const CardholderDashboard({super.key});

  @override
  State<CardholderDashboard> createState() => _CardholderDashboardState();
}

class _CardholderDashboardState extends State<CardholderDashboard> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  late final ProfileService _profileService;
  late final SavedOffersService _savedOffersService;

  String? cardholderName;
  String? defaultPin;
  String? cardholderPlace;
  String? cardholderDistrict;

  String activePin = "";
  String _locationScope = "My Area";
  String _sortOption = "";
  int _selectedIndex = 0;

  String _searchQuery = "";
  final String _selectedCategory = "All";

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _profileService = ProfileService(_auth, _firestore);
    _savedOffersService = SavedOffersService(_auth, _firestore);

    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final data = await _profileService.loadProfile();
    if (data == null) return;

    setState(() {
      cardholderName = data["name"] ?? "";
      defaultPin = data["pin"]?.toString() ?? "";
      cardholderPlace = data["place"]?.toString() ?? "";
      cardholderDistrict = data["district"]?.toString() ?? "";
      activePin = defaultPin ?? "";
    });
  }

  Widget _buildHomeTab() {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
          ),
          expandedHeight: 250.0,
          flexibleSpace: FlexibleSpaceBar(
            background: Stack(
              children: [
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                    child: Image.network(
                      "https://img.freepik.com/free-vector/flat-sale-banner-with-photo_23-2149026968.jpg",
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: CardholderInfo(
                      cardholderName: cardholderName ?? "",
                      activePin: activePin,
                      onPinChanged: (pin) => setState(() => activePin = pin),
                    ),
                  ),
                ),
              ],
            ),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(20.0),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: SearchFilterBar(
                cardholderName: cardholderName,
                activePin: activePin,
                searchController: _searchController,
                onSearchChanged: (val) =>
                    setState(() => _searchQuery = val.toLowerCase()),
                onPinChanged: (pin) => setState(() => activePin = pin),
                onScopeChanged: (scope) =>
                    setState(() => _locationScope = scope),
                onExplorePressed: () => setState(() => _selectedIndex = 2),
                sortOption: _sortOption,
                onSortChanged: (s) => setState(() => _sortOption = s),
              ),
            ),
          ),
          pinned: true,
          backgroundColor: const Color.fromARGB(255, 253, 187, 64),
        ),
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: BestDealsBanner(
                  onExplorePressed: () => setState(() => _selectedIndex = 2),
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SortChips(
                  sortOption: _sortOption,
                  onSortChanged: (s) => setState(() => _sortOption = s),
                ),
              ),
              const SizedBox(height: 12),
              QuickActions(
                onCategoryTap: () {},
                onSpecialsTap: () => setState(() => _selectedIndex = 2),
                onSavedTap: () => setState(() => _selectedIndex = 1),
                onSettingsTap: () {},
              ),
              const SizedBox(height: 8),
              OffersGrid(
                firestore: _firestore,
                auth: _auth,
                searchQuery: _searchQuery,
                selectedCategory: _selectedCategory,
                locationScope: _locationScope,
                activePin: activePin,
                cardholderPlace: cardholderPlace,
                cardholderDistrict: cardholderDistrict,
                sortOption: _sortOption,
                onToggleSave: _savedOffersService.toggleSaveForOffer,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    late final Widget currentTab;
    if (_selectedIndex == 0) {
      currentTab = _buildHomeTab();
    } else if (_selectedIndex == 1) {
      currentTab = SavedTab(
        savedOffersService: _savedOffersService,
        onToggleSave: _savedOffersService.toggleSaveForOffer,
      );
    } else if (_selectedIndex == 2) {
      currentTab = const SpecialsTab();
    } else {
      currentTab = SubmitAdScreen();
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(child: currentTab),
      // START of the updated minimalist bottom navigation bar (reduced size)
      bottomNavigationBar: Container(
        height: 55, // Reduced height
        margin: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 10,
        ), // Adjusted margins
        padding: const EdgeInsets.symmetric(horizontal: 8), // Adjusted padding
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(
            40,
          ), // Slightly smaller border radius
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 15, // Reduced blur
              offset: const Offset(0, 8), // Reduced offset
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildMinimalistNavItem(Icons.home, 0),
            _buildMinimalistNavItem(Icons.bookmark, 1),
            _buildMinimalistNavItem(Icons.local_offer, 2),
            _buildMinimalistNavItem(Icons.person, 3),
          ],
        ),
      ),
      // END of the updated minimalist bottom navigation bar (reduced size)
    );
  }

  // Helper function to build each navigation item for the minimalist bar
  Widget _buildMinimalistNavItem(IconData icon, int index) {
    final bool isSelected = index == _selectedIndex;
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? const Color(0xFF1E212A) : Colors.grey[600],
            size: isSelected ? 26 : 22, // Reduced icon sizes
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 2.5, // Reduced line height
            width: isSelected ? 20 : 0, // Reduced line width
            margin: const EdgeInsets.only(top: 3), // Reduced margin
            decoration: BoxDecoration(
              color: const Color(0xFF1E212A),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }
}
