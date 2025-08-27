import 'home_page.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'ShopOwnerHome.dart';

class ShopOwnerSignupPage extends StatefulWidget {
  const ShopOwnerSignupPage({super.key});

  @override
  _ShopOwnerSignupPageState createState() => _ShopOwnerSignupPageState();
}

class _ShopOwnerSignupPageState extends State<ShopOwnerSignupPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  // Controllers
  TextEditingController nameController = TextEditingController();
  TextEditingController placeController = TextEditingController();
  TextEditingController pinController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController websiteController = TextEditingController();
  TextEditingController facebookController = TextEditingController();
  TextEditingController instagramController = TextEditingController();
  TextEditingController youtubeController = TextEditingController();

  List<Map<String, String>> branches = [];

  bool _isLoading = false;

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
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _addBranch() {
    TextEditingController branchPlace = TextEditingController();
    TextEditingController branchPhone = TextEditingController();
    TextEditingController branchPin = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _primaryColor,
        title: Text("Add Branch", style: TextStyle(color: _onPrimaryColor)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDialogTextField("Place", branchPlace),
            _buildDialogTextField("Phone", branchPhone),
            _buildDialogTextField("Pin Code", branchPin),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel", style: TextStyle(color: _accentColor)),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                branches.add({
                  "place": branchPlace.text,
                  "phone": branchPhone.text,
                  "pinCode": branchPin.text,
                });
              });
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _accentColor,
              foregroundColor: _primaryColor,
            ),
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }

  Widget _buildDialogTextField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      style: TextStyle(color: _onPrimaryColor),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: _onPrimaryColor.withOpacity(0.6)),
        filled: true,
        fillColor: _onPrimaryColor.withOpacity(0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: _onPrimaryColor.withOpacity(0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: _onPrimaryColor.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: _accentColor, width: 2),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Create Firebase Auth account
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(
            email: emailController.text.trim(),
            password:
                "123456", // default password, you can ask for password field
          );

      // Save shop owner data to Firestore
      await _firestore
          .collection("shop_owners")
          .doc(userCredential.user!.uid)
          .set({
            "name": nameController.text,
            "place": placeController.text,
            "pinCode": pinController.text,
            "email": emailController.text,
            "phone": phoneController.text,
            "website": websiteController.text,
            "socialLinks": {
              "facebook": facebookController.text,
              "instagram": instagramController.text,
              "youtube": youtubeController.text,
            },
            "branches": branches,
            "createdAt": DateTime.now(),
          });

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Account created!")));

        // Navigate to HomePage
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => HomePage(uid: userCredential.user!.uid),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      String message = "Error creating account";
      if (e.code == "email-already-in-use") message = "Email already in use";
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    TextInputType? keyboard,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboard,
        style: TextStyle(color: _onPrimaryColor),
        validator: (v) => v!.isEmpty ? "$label required" : null,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: _onPrimaryColor.withOpacity(0.6)),
          prefixIcon: Icon(icon, color: _onPrimaryColor.withOpacity(0.6)),
          filled: true,
          fillColor: _onPrimaryColor.withOpacity(0.05),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: _onPrimaryColor.withOpacity(0.3)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: _accentColor, width: 2),
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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
          "Shop Owner Sign Up",
          style: TextStyle(color: _onPrimaryColor, fontWeight: FontWeight.bold),
        ),
        iconTheme: IconThemeData(color: _onPrimaryColor),
      ),
      body: FadeTransition(
        opacity: _animation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildTextField(
                  "Shop Name",
                  nameController,
                  icon: Icons.store_outlined,
                ),
                _buildTextField(
                  "Place",
                  placeController,
                  icon: Icons.location_on_outlined,
                ),
                _buildTextField(
                  "Pin Code",
                  pinController,
                  keyboard: TextInputType.number,
                  icon: Icons.pin_drop_outlined,
                ),
                _buildTextField(
                  "Email",
                  emailController,
                  keyboard: TextInputType.emailAddress,
                  icon: Icons.email_outlined,
                ),
                _buildTextField(
                  "Phone",
                  phoneController,
                  keyboard: TextInputType.phone,
                  icon: Icons.phone_outlined,
                ),
                _buildTextField(
                  "Website",
                  websiteController,
                  icon: Icons.web_outlined,
                ),
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
                _buildTextField(
                  "Facebook",
                  facebookController,
                  icon: Icons.facebook,
                ),
                _buildTextField(
                  "Instagram",
                  instagramController,
                  icon: Icons.camera_alt_outlined,
                ),
                _buildTextField(
                  "YouTube",
                  youtubeController,
                  icon: Icons.ondemand_video_outlined,
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Branches: ${branches.length}",
                      style: TextStyle(color: _onPrimaryColor, fontSize: 16),
                    ),
                    ElevatedButton.icon(
                      icon: Icon(Icons.add, color: _primaryColor),
                      label: Text(
                        "Add Branch",
                        style: TextStyle(color: _primaryColor),
                      ),
                      onPressed: _addBranch,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _accentColor,
                      ),
                    ),
                  ],
                ),
                if (branches.isNotEmpty)
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: branches.length,
                    itemBuilder: (context, index) {
                      final branch = branches[index];
                      return Card(
                        color: _onPrimaryColor.withOpacity(0.05),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          title: Text(
                            branch["place"]!,
                            style: TextStyle(
                              color: _onPrimaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            "Phone: ${branch["phone"]!}\nPin: ${branch["pinCode"]!}",
                            style: TextStyle(
                              color: _onPrimaryColor.withOpacity(0.7),
                            ),
                          ),
                          trailing: IconButton(
                            icon: Icon(Icons.delete, color: Colors.redAccent),
                            onPressed: () {
                              setState(() {
                                branches.removeAt(index);
                              });
                            },
                          ),
                        ),
                      );
                    },
                  ),
                const SizedBox(height: 30),
                _isLoading
                    ? Center(
                        child: CircularProgressIndicator(color: _accentColor),
                      )
                    : ElevatedButton(
                        onPressed: _submit,
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
                          "Sign Up",
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
    );
  }
}

class CardHolderPage extends StatelessWidget {
  const CardHolderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Card Holder", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF1E212A),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: const Center(
        child: Text(
          "Card Holder Signup/Login here",
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
