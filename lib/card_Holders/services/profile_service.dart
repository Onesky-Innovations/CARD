import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileService {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  ProfileService(this._auth, this._firestore);

  Future<Map<String, dynamic>?> loadProfile() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return null;

    final profileSnap = await _firestore
        .collection("card_holders")
        .doc(uid)
        .collection("details")
        .doc("profile")
        .get();

    return profileSnap.exists ? profileSnap.data() : null;
  }
}
