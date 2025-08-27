import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:permission_handler/permission_handler.dart';

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
  DateTime? offerEndDate;
  bool _isLoading = false;
  bool _isPicking = false;

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
    // Request permission first
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
      if (pickedImages.isNotEmpty) setState(() => images = pickedImages);
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

    setState(() => _isLoading = true);

    try {
      List<String> imageUrls = [];

      if (images.isNotEmpty) {
        for (var img in images) {
          final ref = FirebaseStorage.instance.ref().child(
            'offers/${widget.uid}/${DateTime.now().millisecondsSinceEpoch}_${img.name}',
          );
          await ref.putFile(File(img.path));
          final url = await ref.getDownloadURL();
          imageUrls.add(url);
        }
      }

      await FirebaseFirestore.instance
          .collection("shop_owners")
          .doc(widget.uid)
          .collection("offers")
          .add({
            "itemName": itemNameController.text,
            "mrp": mrpController.text,
            "offerPrice": offerPriceController.text,
            "description": descriptionController.text,
            "images": imageUrls,
            "createdAt": Timestamp.now(),
            "offerEndDate": offerEndDate != null
                ? Timestamp.fromDate(offerEndDate!)
                : null,
            "branches": selectedBranches,
            "ownerId": widget.uid, // for Home & Discover filter
          });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Offer posted successfully!")),
      );

      // Go back to Home tab
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
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
      appBar: AppBar(title: const Text("Add New Offer")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Item Name
              TextFormField(
                controller: itemNameController,
                decoration: const InputDecoration(labelText: "Item Name"),
                validator: (v) => v!.isEmpty ? "Required" : null,
              ),
              // MRP
              TextFormField(
                controller: mrpController,
                decoration: const InputDecoration(labelText: "MRP"),
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? "Required" : null,
              ),
              // Offer Price
              TextFormField(
                controller: offerPriceController,
                decoration: const InputDecoration(labelText: "Offer Price"),
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? "Required" : null,
              ),
              // Description
              TextFormField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: "Description"),
                maxLines: 3,
              ),
              const SizedBox(height: 16),

              // Branch Selection
              if (branches.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Select Branches"),
                    Wrap(
                      spacing: 8,
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
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),

              // Image Picker
              Row(
                children: [
                  ElevatedButton(
                    onPressed: _pickImages,
                    child: const Text("Pick Images (Optional)"),
                  ),
                  const SizedBox(width: 12),
                  Text("${images.length} selected"),
                ],
              ),
              if (images.isNotEmpty)
                SizedBox(
                  height: 80,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: images.length,
                    itemBuilder: (_, i) => Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Image.file(
                        File(images[i].path),
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 16),

              // Offer End Date
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2100),
                      );
                      if (date != null && mounted) {
                        setState(() => offerEndDate = date);
                      }
                    },
                    child: const Text("Pick Offer End Date"),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    offerEndDate != null
                        ? "${offerEndDate!.toLocal()}".split(' ')[0]
                        : "No date selected",
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Submit Button
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _submitOffer,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: const Text("Post Offer"),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
