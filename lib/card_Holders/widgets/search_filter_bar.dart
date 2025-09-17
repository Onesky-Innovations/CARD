import 'package:card/card_Holders/dashboard/header.dart';
import 'package:flutter/material.dart';
// import 'header.dart';
// import 'sort_chips.dart';

class SearchFilterBar extends StatelessWidget {
  final String? cardholderName;
  final String activePin;
  final TextEditingController searchController;
  final String sortOption;
  final void Function(String) onSearchChanged;
  final void Function(String) onPinChanged;
  final void Function(String) onScopeChanged;
  final void Function() onExplorePressed;
  final void Function(String) onSortChanged;

  const SearchFilterBar({
    super.key,
    required this.cardholderName,
    required this.activePin,
    required this.searchController,
    required this.sortOption,
    required this.onSearchChanged,
    required this.onPinChanged,
    required this.onScopeChanged,
    required this.onExplorePressed,
    required this.onSortChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DashboardHeader(
          cardholderName: cardholderName,
          activePin: activePin,
          searchController: searchController,
          onSearchChanged: onSearchChanged,
          onPinChanged: onPinChanged,
          onScopeChanged: onScopeChanged,
          onExplorePressed: onExplorePressed,
        ),
        // const SizedBox(height: 8),
      ],
    );
  }
}
