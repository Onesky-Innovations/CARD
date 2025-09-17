import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';

class SubmitAdScreen extends StatefulWidget {
  @override
  _SubmitAdScreenState createState() => _SubmitAdScreenState();
}

class _SubmitAdScreenState extends State<SubmitAdScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _priceController = TextEditingController();
  final _locationController = TextEditingController();
  final _categoryController = TextEditingController();
  final _descriptionController = TextEditingController();

  // WhatsApp admin number (country code, no +)
  final String adminPhone = "917907708822";

  @override
  void dispose() {
    _titleController.dispose();
    _priceController.dispose();
    _locationController.dispose();
    _categoryController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submitAd() async {
    if (!_formKey.currentState!.validate()) return;

    // Encode the message
    final String message = Uri.encodeComponent(
      "📢 New Ad Submission\n"
      "📝 Title: ${_titleController.text}\n"
      "💰 Price: ₹${_priceController.text}\n"
      "📍 Location: ${_locationController.text}\n"
      "📂 Category: ${_categoryController.text}\n"
      "ℹ️ Description: ${_descriptionController.text}",
    );

    // WhatsApp app URL
    final String mobileUrl = "https://wa.me/$adminPhone?text=$message";

    // WhatsApp Web fallback URL
    final String webUrl =
        "https://web.whatsapp.com/send?phone=$adminPhone&text=$message";

    try {
      // Try to launch the WhatsApp app first
      if (await canLaunchUrlString(mobileUrl)) {
        await launchUrlString(mobileUrl, mode: LaunchMode.externalApplication);
      } else {
        // Fallback to WhatsApp Web
        await launchUrlString(webUrl, mode: LaunchMode.externalApplication);
      }

      // Clear all fields after submission
      _titleController.clear();
      _priceController.clear();
      _locationController.clear();
      _categoryController.clear();
      _descriptionController.clear();

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Opening WhatsApp...")));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Could not open WhatsApp: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Submit Ad")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: "Title"),
                  validator: (value) =>
                      value!.isEmpty ? "Please enter a title" : null,
                ),
                TextFormField(
                  controller: _priceController,
                  decoration: const InputDecoration(labelText: "Price"),
                  keyboardType: TextInputType.number,
                  validator: (value) =>
                      value!.isEmpty ? "Please enter a price" : null,
                ),
                TextFormField(
                  controller: _locationController,
                  decoration: const InputDecoration(labelText: "Location"),
                  validator: (value) =>
                      value!.isEmpty ? "Please enter a location" : null,
                ),
                TextFormField(
                  controller: _categoryController,
                  decoration: const InputDecoration(labelText: "Category"),
                  validator: (value) =>
                      value!.isEmpty ? "Please enter a category" : null,
                ),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(labelText: "Description"),
                  maxLines: 3,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _submitAd,
                  child: const Text("Submit via WhatsApp"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
