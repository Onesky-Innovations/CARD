import 'package:flutter/material.dart';

class QuickActions extends StatelessWidget {
  final VoidCallback onCategoryTap;
  final VoidCallback onSpecialsTap;
  final VoidCallback onSavedTap;
  final VoidCallback onSettingsTap;

  const QuickActions({
    super.key,
    required this.onCategoryTap,
    required this.onSpecialsTap,
    required this.onSavedTap,
    required this.onSettingsTap,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      {"icon": Icons.category, "label": "Category", "onTap": onCategoryTap},
      {"icon": Icons.local_offer, "label": "Specials", "onTap": onSpecialsTap},
      {"icon": Icons.bookmark, "label": "Saved", "onTap": onSavedTap},
      {"icon": Icons.settings, "label": "Settings", "onTap": onSettingsTap},
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
}
