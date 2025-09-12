// // import 'package:card/card_Holders/widgets/best_deals_banner.dart';
// import 'package:flutter/material.dart';

// class DashboardHeader extends StatelessWidget {
//   final String? cardholderName;
//   final String activePin;
//   final TextEditingController searchController;
//   final Function(String) onSearchChanged;
//   final Function(String) onPinChanged;
//   final Function(String) onScopeChanged;
//   final VoidCallback onExplorePressed;

//   const DashboardHeader({
//     super.key,
//     required this.cardholderName,
//     required this.activePin,
//     required this.searchController,
//     required this.onSearchChanged,
//     required this.onPinChanged,
//     required this.onScopeChanged,
//     required this.onExplorePressed,
//   });

//   Future<void> _showPinDialog(BuildContext context) async {
//     final controller = TextEditingController(text: activePin);
//     final result = await showDialog<String>(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text("Enter Pincode"),
//         content: TextField(
//           controller: controller,
//           keyboardType: TextInputType.number,
//           decoration: const InputDecoration(hintText: "Pincode"),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context, null),
//             child: const Text("Cancel"),
//           ),
//           ElevatedButton(
//             onPressed: () => Navigator.pop(context, controller.text.trim()),
//             child: const Text("Save"),
//           ),
//         ],
//       ),
//     );
//     if (result != null && result.isNotEmpty) {
//       onPinChanged(result);
//     }
//   }

//   void _showLocationFilter(BuildContext context) {
//     final options = ["My Area", "My Pincode", "My City", "My District", "All"];
//     showModalBottomSheet(
//       context: context,
//       builder: (context) {
//         return Column(
//           mainAxisSize: MainAxisSize.min,
//           children: options.map((opt) {
//             return ListTile(
//               title: Text(opt),
//               subtitle: opt == "My Area"
//                   ? const Text(
//                       "PIN or City or District",
//                       style: TextStyle(fontSize: 12),
//                     )
//                   : null,
//               onTap: () {
//                 onScopeChanged(opt);
//                 Navigator.pop(context);
//               },
//             );
//           }).toList(),
//         );
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               // CircleAvatar(
//               //   backgroundColor: Colors.grey[300],
//               //   child: const Icon(Icons.person, color: Colors.black87),
//               // ),
//               // const SizedBox(width: 10),
//               // Expanded(
//               //   child: Text(
//               //     cardholderName ?? "User",
//               //     style: const TextStyle(
//               //       fontWeight: FontWeight.bold,
//               //       fontSize: 16,
//               //     ),
//               //   ),
//               // ),
//               // GestureDetector(
//               //   onTap: () => _showPinDialog(context),
//               //   child: Container(
//               //     padding: const EdgeInsets.symmetric(
//               //       horizontal: 12,
//               //       vertical: 6,
//               //     ),
//               //     decoration: BoxDecoration(
//               //       color: Colors.grey[200],
//               //       borderRadius: BorderRadius.circular(20),
//               //     ),
//               //     child: Row(
//               //       children: [
//               //         const Icon(
//               //           Icons.location_on,
//               //           size: 18,
//               //           color: Colors.black87,
//               //         ),
//               //         const SizedBox(width: 4),
//               //         Text(activePin.isNotEmpty ? activePin : "Set PIN"),
//               //       ],
//               //     ),
//               //   ),
//               // ),
//             ],
//           ),
//           const SizedBox(height: 12),
//           TextField(
//             controller: searchController,
//             decoration: InputDecoration(
//               hintText: "Search products, categories, places...",
//               prefixIcon: const Icon(Icons.search),
//               filled: true,
//               fillColor: Colors.grey[200],
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(25),
//                 borderSide: BorderSide.none,
//               ),
//               suffixIcon: IconButton(
//                 icon: const Icon(Icons.tune),
//                 onPressed: () => _showLocationFilter(context),
//               ),
//             ),
//             onChanged: onSearchChanged,
//           ),
//           const SizedBox(height: 14),
//           // Container(
//           //   width: double.infinity,
//           //   padding: const EdgeInsets.all(16),
//           //   decoration: BoxDecoration(
//           //     gradient: const LinearGradient(
//           //       colors: [Color(0xFFFFE0B2), Color(0xFFFFCC80)],
//           //       begin: Alignment.topLeft,
//           //       end: Alignment.bottomRight,
//           //     ),
//           //     borderRadius: BorderRadius.circular(16),
//           //   ),
//           //   // child: BestDealsBanner(onExplorePressed: onExplorePressed), remove this
//           //   //  Row(
//           //   //   children: [

//           //   // const Expanded(
//           //   //   child: Text(
//           //   //     "Best Deals • Up to 80% OFF",
//           //   //     style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
//           //   //   ),
//           //   // ),
//           //   // ElevatedButton(
//           //   //   onPressed: onExplorePressed,
//           //   //   style: ElevatedButton.styleFrom(
//           //   //     backgroundColor: Colors.black87,
//           //   //     foregroundColor: Colors.white,
//           //   //     shape: RoundedRectangleBorder(
//           //   //       borderRadius: BorderRadius.circular(24),
//           //   //     ),
//           //   //   ),
//           //   //   child: const Text("Explore"),
//           //   // ),
//           //   //   ],
//           //   // ),
//           // ),
//         ],
//       ),
//     );
//   }
// }

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
