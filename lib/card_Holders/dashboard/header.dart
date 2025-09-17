import 'package:flutter/material.dart';

class DashboardHeader extends StatelessWidget {
  final String? cardholderName;
  final String activePin;
  final TextEditingController searchController;
  final Function(String) onSearchChanged;
  final Function(String) onPinChanged;
  final Function(String) onScopeChanged;
  final VoidCallback onExplorePressed;

  const DashboardHeader({
    super.key,
    required this.cardholderName,
    required this.activePin,
    required this.searchController,
    required this.onSearchChanged,
    required this.onPinChanged,
    required this.onScopeChanged,
    required this.onExplorePressed,
  });

  void _showLocationFilter(BuildContext context) {
    final options = ["My Area", "My Pincode", "My City", "My District", "All"];
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: options.map((opt) {
            return ListTile(
              title: Text(opt),
              subtitle: opt == "My Area"
                  ? const Text(
                      "PIN or City or District",
                      style: TextStyle(fontSize: 12),
                    )
                  : null,
              onTap: () {
                onScopeChanged(opt);
                Navigator.pop(context);
              },
            );
          }).toList(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: searchController,
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
                onPressed: () => _showLocationFilter(context),
              ),
              contentPadding: const EdgeInsets.symmetric(
                vertical: 0,
                horizontal: 16,
              ),
            ),
            onChanged: onSearchChanged,
          ),
          // ✅ Removed the big gap
        ],
      ),
    );
  }
}
