import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:card/shop owner/home_page.dart';

class AddOfferPage extends StatefulWidget {
  final String uid;
  const AddOfferPage({required this.uid, super.key});

  @override
  State<AddOfferPage> createState() => _AddOfferPageState();
}

class _AddOfferPageState extends State<AddOfferPage> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  List<XFile> images = [];
  List<String> selectedBranches = [];
  List<Map<String, dynamic>> branches = [];

  TextEditingController itemNameController = TextEditingController();
  TextEditingController mrpController = TextEditingController();
  TextEditingController offerPriceController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  DateTime? offerStartDate;
  DateTime? offerEndDate;

  bool _isLoading = false;
  bool _isPicking = false;

  final Color _primaryColor = const Color(0xFF1E212A);
  final Color _accentColor = const Color(0xFF61dafb);
  final Color _onPrimaryColor = const Color.fromARGB(255, 255, 255, 255);

  @override
  void initState() {
    super.initState();
    _loadBranches();
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
        setState(() => images.addAll(pickedImages));
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

    // ✅ Validate dates
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
      List<String> imageUrls = [];

      for (var img in images) {
        final ref = FirebaseStorage.instance.ref().child(
          'offers/${widget.uid}/${DateTime.now().millisecondsSinceEpoch}_${img.name}',
        );
        await ref.putFile(File(img.path));
        final url = await ref.getDownloadURL();
        imageUrls.add(url);
      }

      await FirebaseFirestore.instance
          .collection("shop_owners")
          .doc(widget.uid)
          .collection("offers")
          .add({
            "itemName": itemNameController.text,
            "mrp": mrp,
            "offerPrice": offer,
            "description": descriptionController.text,
            "images": imageUrls,
            "createdAt": Timestamp.now(),
            "offerStartDate": Timestamp.fromDate(offerStartDate!), // ✅ required
            "offerEndDate": Timestamp.fromDate(offerEndDate!), // ✅ required
            "branches": selectedBranches,
            "ownerId": widget.uid,
          });

      if (!mounted) return;
      Navigator.of(context, rootNavigator: true).pop(); // close progress
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Offer posted successfully!")),
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => HomePage(uid: widget.uid)),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context, rootNavigator: true).pop(); // close progress
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
        title: Text("Add New Offer", style: TextStyle(color: _onPrimaryColor)),
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
                        color: isSelected ? _primaryColor : Colors.amber,
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

              if (images.isNotEmpty)
                SizedBox(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: images.length,
                    itemBuilder: (_, i) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              File(images[i].path),
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
                                setState(() => images.removeAt(i));
                              },
                              child: CircleAvatar(
                                radius: 12,
                                backgroundColor: Colors.black.withOpacity(0.6),
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
                    ),
                  ),
                ),

              if (images.isNotEmpty) const SizedBox(height: 16),

              // ✅ Offer Start Date
              Container(
                decoration: BoxDecoration(
                  color: _onPrimaryColor.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _onPrimaryColor.withOpacity(0.2)),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      color: _onPrimaryColor.withOpacity(0.6),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      offerStartDate != null
                          ? "Starts on ${offerStartDate!.toLocal()}".split(
                              ' ',
                            )[0]
                          : "Pick start date",
                      style: TextStyle(color: _onPrimaryColor.withOpacity(0.8)),
                    ),
                    const Spacer(),
                    ElevatedButton(
                      onPressed: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2100),
                        );
                        if (date != null && mounted) {
                          setState(() => offerStartDate = date);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _accentColor,
                        foregroundColor: _primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                      child: const Text("Pick Date"),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ✅ Offer End Date
              Container(
                decoration: BoxDecoration(
                  color: _onPrimaryColor.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _onPrimaryColor.withOpacity(0.2)),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      color: _onPrimaryColor.withOpacity(0.6),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      offerEndDate != null
                          ? "Ends on ${offerEndDate!.toLocal()}".split(' ')[0]
                          : "Pick end date",
                      style: TextStyle(color: _onPrimaryColor.withOpacity(0.8)),
                    ),
                    const Spacer(),
                    ElevatedButton(
                      onPressed: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: offerStartDate ?? DateTime.now(),
                          firstDate: offerStartDate ?? DateTime.now(),
                          lastDate: DateTime(2100),
                        );
                        if (date != null && mounted) {
                          setState(() => offerEndDate = date);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _accentColor,
                        foregroundColor: _primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                      child: const Text("Pick Date"),
                    ),
                  ],
                ),
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
                child: const Text(
                  "Post Offer",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
}
