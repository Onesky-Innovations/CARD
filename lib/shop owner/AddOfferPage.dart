import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:card/shop owner/home_page.dart';

class AddOfferPage extends StatefulWidget {
  final String uid;
  final Map<String, dynamic>? offerToEdit;
  final String? offerId;

  const AddOfferPage({
    required this.uid,
    super.key,
    this.offerToEdit,
    this.offerId,
  });

  @override
  State<AddOfferPage> createState() => _AddOfferPageState();
}

class _AddOfferPageState extends State<AddOfferPage> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  List<XFile> newImages = [];
  List<String> existingImages = [];
  List<String> selectedBranches = [];
  List<Map<String, dynamic>> branches = [];

  TextEditingController itemNameController = TextEditingController();
  TextEditingController mrpController = TextEditingController();
  TextEditingController offerPriceController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  DateTime? offerStartDate;
  DateTime? offerEndDate;

  // ✅ Category & Subcategory
  String? selectedCategory;
  String? selectedSubcategory;

  final Map<String, List<String>> categoryMap = {
    "Electronics": ["Mobiles", "Laptops", "TVs"],
    "Fashion": ["Men", "Women", "Kids"],
    "Groceries": ["Fruits", "Vegetables", "Snacks"],
    "Home": ["Furniture", "Decor", "Appliances"],
  };

  bool _isLoading = false;
  bool _isPicking = false;

  final Color _primaryColor = const Color(0xFF1E212A);
  final Color _accentColor = const Color(0xFF61dafb);
  final Color _onPrimaryColor = const Color.fromARGB(255, 255, 255, 255);

  @override
  void initState() {
    super.initState();
    _loadBranches();

    // ✅ If editing, prefill fields
    if (widget.offerToEdit != null) {
      final offer = widget.offerToEdit!;
      itemNameController.text = offer['itemName'] ?? '';
      mrpController.text = offer['mrp']?.toString() ?? '';
      offerPriceController.text = offer['offerPrice']?.toString() ?? '';
      descriptionController.text = offer['description'] ?? '';
      selectedBranches = List<String>.from(offer['branches'] ?? []);
      existingImages = List<String>.from(offer['images'] ?? []);
      selectedCategory = offer['category'];
      selectedSubcategory = offer['subcategory'];
      if (offer['offerStartDate'] != null) {
        offerStartDate = (offer['offerStartDate'] as Timestamp).toDate();
      }
      if (offer['offerEndDate'] != null) {
        offerEndDate = (offer['offerEndDate'] as Timestamp).toDate();
      }
    }
  }

  Future<void> _loadBranches() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection("shop_owners")
          .doc(widget.uid)
          .get();

      if (!mounted) return;

      if (snapshot.exists) {
        var data = snapshot.data()!;
        setState(() {
          branches = List<Map<String, dynamic>>.from(data['branches'] ?? []);
        });
      }
    } catch (e) {
      print("Error loading branches: $e");
    }
  }

  Future<void> _pickImages() async {
    var status = await Permission.photos.request();
    if (!status.isGranted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Photos permission denied")));
      return;
    }

    if (_isPicking) return;
    _isPicking = true;

    try {
      final pickedImages = await _picker.pickMultiImage();
      if (!mounted) return;
      if (pickedImages.isNotEmpty) {
        setState(() => newImages.addAll(pickedImages));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error picking images: $e")));
    } finally {
      _isPicking = false;
    }
  }

  Future<void> _submitOffer() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all required fields")),
      );
      return;
    }

    if (branches.isNotEmpty && selectedBranches.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select at least one branch")),
      );
      return;
    }

    if (offerStartDate == null || offerEndDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select both start and end dates")),
      );
      return;
    }

    if (offerEndDate!.isBefore(offerStartDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("End date must be after start date")),
      );
      return;
    }

    if (selectedCategory == null || selectedSubcategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select category & subcategory")),
      );
      return;
    }

    double? mrp = double.tryParse(mrpController.text);
    double? offer = double.tryParse(offerPriceController.text);

    if (mrp == null || offer == null || offer >= mrp) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Offer price must be less than MRP")),
      );
      return;
    }

    setState(() => _isLoading = true);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) =>
          Center(child: CircularProgressIndicator(color: _accentColor)),
    );

    try {
      List<String> imageUrls = [...existingImages]; // keep old ones

      for (var img in newImages) {
        final ref = FirebaseStorage.instance.ref().child(
          'offers/${widget.uid}/${DateTime.now().millisecondsSinceEpoch}_${img.name}',
        );
        await ref.putFile(File(img.path));
        final url = await ref.getDownloadURL();
        imageUrls.add(url);
      }

      final offerData = {
        "itemName": itemNameController.text,
        "mrp": mrp,
        "offerPrice": offer,
        "description": descriptionController.text,
        "images": imageUrls,
        "offerStartDate": Timestamp.fromDate(offerStartDate!),
        "offerEndDate": Timestamp.fromDate(offerEndDate!),
        "branches": selectedBranches,
        "ownerId": widget.uid,
        "category": selectedCategory,
        "subcategory": selectedSubcategory,
      };

      if (widget.offerId == null) {
        offerData["createdAt"] = Timestamp.now();
        await FirebaseFirestore.instance
            .collection("shop_owners")
            .doc(widget.uid)
            .collection("offers")
            .add(offerData);
      } else {
        await FirebaseFirestore.instance
            .collection("shop_owners")
            .doc(widget.uid)
            .collection("offers")
            .doc(widget.offerId)
            .update(offerData);
      }

      if (!mounted) return;
      Navigator.of(context, rootNavigator: true).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.offerId == null
                ? "Offer posted successfully!"
                : "Offer updated successfully!",
          ),
        ),
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => HomePage(uid: widget.uid)),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context, rootNavigator: true).pop();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _primaryColor,
      appBar: AppBar(
        title: Text(
          widget.offerId == null ? "Add New Offer" : "Edit Offer",
          style: TextStyle(color: _onPrimaryColor),
        ),
        backgroundColor: _primaryColor,
        iconTheme: IconThemeData(color: _onPrimaryColor),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildModernTextField(
                controller: itemNameController,
                label: "Item Name",
                validator: (v) => v!.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 16),

              // ✅ Category Dropdown
              DropdownButtonFormField<String>(
                value: selectedCategory,
                decoration: _dropdownDecoration("Category"),
                items: categoryMap.keys
                    .map(
                      (cat) => DropdownMenuItem<String>(
                        value: cat,
                        child: Text(cat),
                      ),
                    )
                    .toList(),
                onChanged: (val) {
                  setState(() {
                    selectedCategory = val;
                    selectedSubcategory = null;
                  });
                },
                validator: (v) => v == null ? "Select category" : null,
              ),
              const SizedBox(height: 16),

              // ✅ Subcategory Dropdown
              DropdownButtonFormField<String>(
                value: selectedSubcategory,
                decoration: _dropdownDecoration("Subcategory"),
                items:
                    (selectedCategory != null
                            ? categoryMap[selectedCategory]!
                            : [])
                        .map(
                          (sub) => DropdownMenuItem<String>(
                            value: sub,
                            child: Text(sub),
                          ),
                        )
                        .toList(),
                onChanged: (val) {
                  setState(() {
                    selectedSubcategory = val;
                  });
                },
                validator: (v) => v == null ? "Select subcategory" : null,
              ),
              const SizedBox(height: 16),

              _buildModernTextField(
                controller: mrpController,
                label: "MRP",
                keyboardType: TextInputType.number,
                validator: _validateNumber,
              ),
              const SizedBox(height: 16),
              _buildModernTextField(
                controller: offerPriceController,
                label: "Offer Price",
                keyboardType: TextInputType.number,
                validator: _validateNumber,
              ),
              const SizedBox(height: 16),
              _buildModernTextField(
                controller: descriptionController,
                label: "Description",
                maxLines: 3,
              ),
              const SizedBox(height: 16),

              // ✅ Branches
              if (branches.isNotEmpty) ...[
                Text(
                  "Select Branches",
                  style: TextStyle(
                    color: _onPrimaryColor.withOpacity(0.8),
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: branches.map((b) {
                    final name = b['place'] ?? '';
                    final isSelected = selectedBranches.contains(name);
                    return FilterChip(
                      label: Text(name),
                      selected: isSelected,
                      onSelected: (val) {
                        setState(() {
                          if (val) {
                            selectedBranches.add(name);
                          } else {
                            selectedBranches.remove(name);
                          }
                        });
                      },
                      labelStyle: TextStyle(
                        color: isSelected
                            ? _primaryColor
                            : const Color.fromARGB(255, 0, 0, 0),
                      ),
                      backgroundColor: _onPrimaryColor.withOpacity(0.1),
                      selectedColor: _accentColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: isSelected
                              ? _accentColor
                              : _onPrimaryColor.withOpacity(0.2),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
              ],

              // ✅ Image Picker
              GestureDetector(
                onTap: _pickImages,
                child: Container(
                  height: 150,
                  decoration: BoxDecoration(
                    color: _onPrimaryColor.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _onPrimaryColor.withOpacity(0.2)),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.camera_alt,
                          color: _onPrimaryColor,
                          size: 40,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Add Photos",
                          style: TextStyle(
                            color: _onPrimaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              if (existingImages.isNotEmpty || newImages.isNotEmpty)
                SizedBox(
                  height: 100,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      ...existingImages.asMap().entries.map((entry) {
                        int i = entry.key;
                        String url = entry.value;
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  url,
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned(
                                right: 0,
                                top: 0,
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() => existingImages.removeAt(i));
                                  },
                                  child: CircleAvatar(
                                    radius: 12,
                                    backgroundColor: Colors.black.withOpacity(
                                      0.6,
                                    ),
                                    child: const Icon(
                                      Icons.close,
                                      size: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                      ...newImages.asMap().entries.map((entry) {
                        int i = entry.key;
                        XFile img = entry.value;
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(
                                  File(img.path),
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned(
                                right: 0,
                                top: 0,
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() => newImages.removeAt(i));
                                  },
                                  child: CircleAvatar(
                                    radius: 12,
                                    backgroundColor: Colors.black.withOpacity(
                                      0.6,
                                    ),
                                    child: const Icon(
                                      Icons.close,
                                      size: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),

              const SizedBox(height: 16),

              _buildDatePickerRow(
                label: "Pick start date",
                selectedDate: offerStartDate,
                onPick: (date) => setState(() => offerStartDate = date),
              ),
              const SizedBox(height: 16),

              _buildDatePickerRow(
                label: "Pick end date",
                selectedDate: offerEndDate,
                onPick: (date) => setState(() => offerEndDate = date),
                firstDate: offerStartDate ?? DateTime.now(),
              ),
              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: _isLoading ? null : _submitOffer,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _accentColor,
                  foregroundColor: _primaryColor,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 5,
                ),
                child: Text(
                  widget.offerId == null ? "Post Offer" : "Update Offer",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String? _validateNumber(String? value) {
    if (value == null || value.isEmpty) return "Required";
    final number = double.tryParse(value);
    if (number == null || number <= 0) return "Enter a valid positive number";
    return null;
  }

  Widget _buildModernTextField({
    required TextEditingController controller,
    required String label,
    TextInputType keyboardType = TextInputType.text,
    int? maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      style: TextStyle(color: _onPrimaryColor),
      cursorColor: _accentColor,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: _onPrimaryColor.withOpacity(0.6)),
        filled: true,
        fillColor: _onPrimaryColor.withOpacity(0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _accentColor, width: 2),
        ),
      ),
    );
  }

  InputDecoration _dropdownDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: _onPrimaryColor.withOpacity(0.6)),
      filled: true,
      fillColor: _onPrimaryColor.withOpacity(0.05),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: _accentColor, width: 2),
      ),
    );
  }

  Widget _buildDatePickerRow({
    required String label,
    required DateTime? selectedDate,
    required Function(DateTime) onPick,
    DateTime? firstDate,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: _onPrimaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _onPrimaryColor.withOpacity(0.2)),
      ),
      child: ListTile(
        title: Text(
          selectedDate == null
              ? label
              : "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}",
          style: TextStyle(
            color: selectedDate == null
                ? _onPrimaryColor.withOpacity(0.6)
                : _onPrimaryColor,
          ),
        ),
        trailing: Icon(Icons.calendar_today, color: _onPrimaryColor),
        onTap: () async {
          final picked = await showDatePicker(
            context: context,
            initialDate: selectedDate ?? DateTime.now(),
            firstDate: firstDate ?? DateTime(2000),
            lastDate: DateTime(2100),
            builder: (context, child) {
              return Theme(
                data: Theme.of(context).copyWith(
                  colorScheme: ColorScheme.dark(
                    primary: _accentColor,
                    onPrimary: _primaryColor,
                    surface: _primaryColor,
                    onSurface: _onPrimaryColor,
                  ),
                  dialogTheme: DialogThemeData(backgroundColor: _primaryColor),
                ),
                child: child!,
              );
            },
          );
          if (picked != null) onPick(picked);
        },
      ),
    );
  }
}
