import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SavedOffersService {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  SavedOffersService(this._auth, this._firestore);

  String _savedDocIdForPath(String offerDocPath) =>
      offerDocPath.replaceAll("/", "__");

  Stream<List<String>> savedOfferPathsStream() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return const Stream.empty();

    return _firestore
        .collection("card_holders")
        .doc(uid)
        .collection("saved_offers")
        .snapshots()
        .map(
          (snap) =>
              snap.docs.map((doc) => doc["offerDocPath"] as String).toList(),
        );
  }

  Stream<List<Map<String, dynamic>>> savedOffersStream() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return const Stream.empty();

    return _firestore
        .collection("card_holders")
        .doc(uid)
        .collection("saved_offers")
        .orderBy("savedAt", descending: true)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((doc) => doc.data() as Map<String, dynamic>)
              .toList(),
        );
  }

  Future<void> toggleSaveForOffer(
    String offerDocPath,
    Map<String, dynamic> data,
    bool currentlySaved,
  ) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    final savedRef = _firestore
        .collection("card_holders")
        .doc(uid)
        .collection("saved_offers")
        .doc(_savedDocIdForPath(offerDocPath));

    if (currentlySaved) {
      await savedRef.delete();
    } else {
      await savedRef.set({
        ...data,
        "offerDocPath": offerDocPath,
        "savedAt": FieldValue.serverTimestamp(),
      });
    }
  }
}
