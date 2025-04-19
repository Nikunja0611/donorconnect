import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DonationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // Get current user ID
  String? get _userId => _auth.currentUser?.uid;

  // Reference to the user's donations sub-collection
  CollectionReference<Map<String, dynamic>> get _userDonationsRef {
    if (_userId == null) {
      throw Exception("User not authenticated");
    }
    return _firestore
        .collection('users')
        .doc(_userId)
        .collection('donations');
  }
  
  // Add a new donation record
  Future<void> addDonation({
    required String date,
    required String location,
    required String bloodBank,
    required double amount,
    String? notes,
  }) async {
    await _userDonationsRef.add({
      'date': date,
      'location': location,
      'bloodBank': bloodBank,
      'amount': amount,
      'notes': notes,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
  
  // Stream all donations for current user
  Stream<QuerySnapshot<Map<String, dynamic>>> getUserDonations() {
    return _userDonationsRef
        .orderBy('timestamp', descending: true)
        .snapshots();
  }
  
  // Get donation by ID
  Future<DocumentSnapshot<Map<String, dynamic>>> getDonationById(String donationId) {
    return _userDonationsRef.doc(donationId).get();
  }
  
  // Update donation record
  Future<void> updateDonation(String donationId, Map<String, dynamic> data) async {
    await _userDonationsRef.doc(donationId).update(data);
  }
  
  // Delete donation record
  Future<void> deleteDonation(String donationId) async {
    await _userDonationsRef.doc(donationId).delete();
  }
}
