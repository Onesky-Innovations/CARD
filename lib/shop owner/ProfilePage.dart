import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfilePage extends StatefulWidget {
  final String uid;
  const ProfilePage({required this.uid, super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool darkMode = false;
  bool _isEditing = false;

  // Controllers
  TextEditingController nameController = TextEditingController();
  TextEditingController placeController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController websiteController = TextEditingController();
  TextEditingController facebookController = TextEditingController();
  TextEditingController instagramController = TextEditingController();
  TextEditingController youtubeController = TextEditingController();

  final Color _primaryColor = const Color(0xFF1E212A);
  final Color _accentColor = const Color(0xFF61dafb);
  final Color _onPrimaryColor = Colors.white;

  late final AnimationController _animationController;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );
    _animationController.forward();
    _loadProfile();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    final doc = await FirebaseFirestore.instance
        .collection("shop_owners")
        .doc(widget.uid)
        .get();
    if (!doc.exists) return;
    final data = doc.data()!;
    nameController.text = data['name'] ?? '';
    placeController.text = data['place'] ?? '';
    phoneController.text = data['phone'] ?? '';
    websiteController.text = data['website'] ?? '';
    facebookController.text = data['socialLinks']?['facebook'] ?? '';
    instagramController.text = data['socialLinks']?['instagram'] ?? '';
    youtubeController.text = data['socialLinks']?['youtube'] ?? '';
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      await FirebaseFirestore.instance
          .collection("shop_owners")
          .doc(widget.uid)
          .update({
            "name": nameController.text,
            "place": placeController.text,
            "phone": phoneController.text,
            "website": websiteController.text,
            "socialLinks": {
              "facebook": facebookController.text,
              "instagram": instagramController.text,
              "youtube": youtubeController.text,
            },
          });

      if (!mounted) return;
      setState(() => _isEditing = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Profile updated!")));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _logout() async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    TextInputType? keyboard,
    bool enabled = true,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboard,
        enabled: enabled,
        style: TextStyle(
          color: enabled ? _onPrimaryColor : _onPrimaryColor.withOpacity(0.5),
        ),
        validator: (v) => v!.isEmpty && enabled ? "$label required" : null,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: _onPrimaryColor.withOpacity(0.6)),
          prefixIcon: Icon(icon, color: _onPrimaryColor.withOpacity(0.6)),
          filled: true,
          fillColor: enabled
              ? _onPrimaryColor.withOpacity(0.05)
              : _onPrimaryColor.withOpacity(0.02),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: _onPrimaryColor.withOpacity(0.3)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: _accentColor, width: 2),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: _onPrimaryColor.withOpacity(0.1)),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _primaryColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "Profile",
          style: TextStyle(color: _onPrimaryColor, fontWeight: FontWeight.bold),
        ),
        iconTheme: IconThemeData(color: _onPrimaryColor),
        actions: [
          IconButton(
            icon: Icon(
              _isEditing ? Icons.cancel : Icons.edit,
              color: _onPrimaryColor,
            ),
            onPressed: () {
              setState(() {
                _isEditing = !_isEditing;
              });
            },
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _animation,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildTextField(
                    label: "Shop Name",
                    controller: nameController,
                    icon: Icons.store_outlined,
                    enabled: _isEditing,
                  ),
                  _buildTextField(
                    label: "Place",
                    controller: placeController,
                    icon: Icons.location_on_outlined,
                    enabled: _isEditing,
                  ),
                  _buildTextField(
                    label: "Phone",
                    controller: phoneController,
                    icon: Icons.phone_outlined,
                    keyboard: TextInputType.phone,
                    enabled: _isEditing,
                  ),
                  _buildTextField(
                    label: "Website",
                    controller: websiteController,
                    icon: Icons.web_outlined,
                    keyboard: TextInputType.url,
                    enabled: _isEditing,
                  ),
                  const SizedBox(height: 20),
                  const Divider(height: 30, thickness: 1, color: Colors.grey),
                  Text(
                    "Social Links",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _onPrimaryColor,
                      fontSize: 18,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    label: "Facebook",
                    controller: facebookController,
                    icon: Icons.facebook,
                    keyboard: TextInputType.url,
                    enabled: _isEditing,
                  ),
                  _buildTextField(
                    label: "Instagram",
                    controller: instagramController,
                    icon: Icons.camera_alt_outlined,
                    keyboard: TextInputType.url,
                    enabled: _isEditing,
                  ),
                  _buildTextField(
                    label: "YouTube",
                    controller: youtubeController,
                    icon: Icons.ondemand_video_outlined,
                    keyboard: TextInputType.url,
                    enabled: _isEditing,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Dark Mode",
                        style: TextStyle(color: _onPrimaryColor, fontSize: 16),
                      ),
                      Switch(
                        value: darkMode,
                        onChanged: (v) {
                          setState(() => darkMode = v);
                        },
                        activeColor: _accentColor,
                        inactiveThumbColor: _onPrimaryColor.withOpacity(0.5),
                        inactiveTrackColor: _onPrimaryColor.withOpacity(0.2),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  if (_isEditing)
                    _isLoading
                        ? Center(
                            child: CircularProgressIndicator(
                              color: _accentColor,
                            ),
                          )
                        : ElevatedButton(
                            onPressed: _saveProfile,
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 50),
                              backgroundColor: _accentColor,
                              foregroundColor: _primaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: const Text(
                              "Save Profile",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _logout,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      backgroundColor: Colors.redAccent,
                      foregroundColor: _onPrimaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      "Logout",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
