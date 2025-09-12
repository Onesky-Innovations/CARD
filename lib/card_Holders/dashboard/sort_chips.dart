import 'package:flutter/material.dart';

class SortChips extends StatelessWidget {
  final String sortOption;
  final Function(String) onSortChanged;

  const SortChips({
    super.key,
    required this.sortOption,
    required this.onSortChanged,
  });

  @override
  Widget build(BuildContext context) {
    final sorts = [
      "Trending",
      "Biggest Discount",
      "Ending Soon",
      "Most Popular",
    ];
    final emojis = {
      "Trending": "🔥",
      "Biggest Discount": "🏷️",
      "Ending Soon": "🕒",
      "Most Popular": "⭐",
    };

    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: sorts.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final key = sorts[index];
          final isSelected = sortOption == key;
          final label = isSelected ? "${emojis[key]} $key" : emojis[key]!;

          return GestureDetector(
            onTap: () => onSortChanged(isSelected ? "" : key),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected ? Colors.deepOrange : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : Colors.black,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
