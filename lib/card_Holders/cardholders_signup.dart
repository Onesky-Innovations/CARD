import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class CardholderSignupPage extends StatefulWidget {
  const CardholderSignupPage({super.key});

  @override
  State<CardholderSignupPage> createState() => _CardholderSignupPageState();
}

class _CardholderSignupPageState extends State<CardholderSignupPage> {
  final _formKey = GlobalKey<FormState>();
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  // Controllers
  final nameController = TextEditingController();
  final whatsappController = TextEditingController();
  final placeController = TextEditingController();
  final districtController = TextEditingController();
  final stateController = TextEditingController();
  final pinController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final rePasswordController = TextEditingController();
  DateTime? dob;
  String gender = "Male";
  bool notifyWhatsApp = false;
  bool _isLoading = false;

  @override
  void dispose() {
    nameController.dispose();
    whatsappController.dispose();
    placeController.dispose();
    districtController.dispose();
    stateController.dispose();
    pinController.dispose();
    emailController.dispose();
    passwordController.dispose();
    rePasswordController.dispose();
    super.dispose();
  }

  Future<void> _pickDOB() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 18, now.month, now.day),
      firstDate: DateTime(1900),
      lastDate: now,
    );
    if (picked != null) setState(() => dob = picked);
  }

  Future<void> _signup() async {
    if (!_formKey.currentState!.validate()) return;
    if (dob == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select Date of Birth")),
      );
      return;
    }
    setState(() => _isLoading = true);
    try {
      // Create Firebase Auth user
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      final uid = userCredential.user!.uid;

      // Save main profile in card_holders collection
      await _firestore.collection('card_holders').doc(uid).set({
        'name': nameController.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Save detailed profile in subcollection
      await _firestore
          .collection('card_holders')
          .doc(uid)
          .collection('details')
          .doc('profile')
          .set({
            'whatsapp': whatsappController.text.trim(),
            'notifyWhatsApp': notifyWhatsApp,
            'gender': gender,
            'dob': Timestamp.fromDate(dob!),
            'place': placeController.text.trim(),
            'district': districtController.text.trim(),
            'state': stateController.text.trim(),
            'pin': pinController.text.trim(),
            'email': emailController.text.trim(),
            'createdAt': FieldValue.serverTimestamp(),
          });

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Signup Successful!")));
      Navigator.of(context).pop();
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: ${e.message}")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final inputDecoration = InputDecoration(
      filled: true,
      fillColor: Colors.grey[200],
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );

    return Scaffold(
      appBar: AppBar(title: const Text("Cardholder Signup")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: nameController,
                decoration: inputDecoration.copyWith(labelText: "Name"),
                validator: (v) => v!.isEmpty ? "Name required" : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: whatsappController,
                decoration: inputDecoration.copyWith(
                  labelText: "WhatsApp (optional)",
                  helperText: "Get notifications about new offers",
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: gender,
                      items: const [
                        DropdownMenuItem(value: "Male", child: Text("Male")),
                        DropdownMenuItem(
                          value: "Female",
                          child: Text("Female"),
                        ),
                        DropdownMenuItem(value: "Other", child: Text("Other")),
                      ],
                      onChanged: (v) => setState(() => gender = v!),
                      decoration: inputDecoration.copyWith(labelText: "Gender"),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: InkWell(
                      onTap: _pickDOB,
                      child: InputDecorator(
                        decoration: inputDecoration.copyWith(labelText: "DOB"),
                        child: Text(
                          dob != null
                              ? DateFormat('dd/MM/yyyy').format(dob!)
                              : "Select DOB",
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: placeController,
                      decoration: inputDecoration.copyWith(labelText: "Place"),
                      validator: (v) => v!.isEmpty ? "Place required" : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: districtController,
                      decoration: inputDecoration.copyWith(
                        labelText: "District",
                      ),
                      validator: (v) => v!.isEmpty ? "District required" : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: stateController,
                      decoration: inputDecoration.copyWith(labelText: "State"),
                      validator: (v) => v!.isEmpty ? "State required" : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: pinController,
                decoration: inputDecoration.copyWith(labelText: "Pin Code"),
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? "Pin code required" : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: emailController,
                decoration: inputDecoration.copyWith(labelText: "Email"),
                keyboardType: TextInputType.emailAddress,
                validator: (v) => v!.isEmpty ? "Email required" : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: passwordController,
                decoration: inputDecoration.copyWith(labelText: "Password"),
                obscureText: true,
                validator: (v) => v!.isEmpty ? "Password required" : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: rePasswordController,
                decoration: inputDecoration.copyWith(
                  labelText: "Re-enter Password",
                ),
                obscureText: true,
                validator: (v) => v != passwordController.text
                    ? "Passwords do not match"
                    : null,
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                title: const Text("Get WhatsApp notifications"),
                value: notifyWhatsApp,
                onChanged: (v) => setState(() => notifyWhatsApp = v),
              ),
              const SizedBox(height: 20),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _signup,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text("Sign Up"),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
