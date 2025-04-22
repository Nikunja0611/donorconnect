import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DonationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // Get current user ID
  String? get _userId => _auth.currentUser?.uid;

  // Reference to donations collection
  CollectionReference<Map<String, dynamic>> get _donationsRef {
    return _firestore.collection('donations');
  }
  
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
    String? receiptData, // This could be base64 encoded string or a URL if stored elsewhere
  }) async {
    if (_userId == null) throw Exception("User not authenticated");
    
    // Get user data for donor information
    DocumentSnapshot userDoc = await _firestore.collection('users').doc(_userId).get();
    Map<String, dynamic> userData = {};
    
    if (userDoc.exists) {
      userData = userDoc.data() as Map<String, dynamic>;
    }
    
    // Create donation document
    final donationData = {
      'userId': _userId,
      'userName': userData['name'] ?? 'Anonymous',
      'bloodGroup': userData['bloodGroup'] ?? '',
      'date': date,
      'location': location,
      'bloodBank': bloodBank,
      'amount': amount,
      'notes': notes,
      'timestamp': FieldValue.serverTimestamp(),
      'donorContact': userData['phone'] ?? '',
      'state': userData['state'] ?? '',
      'district': userData['district'] ?? '',
      'city': userData['city'] ?? '',
      'isAvailable': userData['isAvailable'] ?? false,
      'receiptData': receiptData, // Store receipt data directly in Firestore
    };
    
    // Add to global donations collection
    DocumentReference globalDonationRef = await _donationsRef.add(donationData);
    String globalDonationId = globalDonationRef.id;
    
    // Add to user's donations sub-collection with the same ID for reference
    await _userDonationsRef.doc(globalDonationId).set(donationData);

    // Update user's total donation statistics
    await _updateUserDonationStats(amount);
  }
  
  // Update user's donation statistics
  Future<void> _updateUserDonationStats(double amount) async {
    if (_userId == null) return;
    
    DocumentReference userRef = _firestore.collection('users').doc(_userId);
    
    // Get current statistics
    DocumentSnapshot userDoc = await userRef.get();
    if (userDoc.exists) {
      Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
      
      int totalDonations = (userData['totalDonations'] as num?)?.toInt() ?? 0;
      double totalAmount = (userData['totalBloodDonated'] as num?)?.toDouble() ?? 0.0;
      
      // Update statistics
      await userRef.update({
        'totalDonations': totalDonations + 1,
        'totalBloodDonated': totalAmount + amount,
        'lastDonationDate': FieldValue.serverTimestamp(),
      });
    }
  }
  
  // Stream all donations for current user
  Stream<QuerySnapshot<Map<String, dynamic>>> getUserDonations() {
    return _userDonationsRef
        .orderBy('timestamp', descending: true)
        .snapshots();
  }
  
  // Get all public donations
  Stream<QuerySnapshot<Map<String, dynamic>>> getAllDonations() {
    return _donationsRef
        .orderBy('timestamp', descending: true)
        .snapshots();
  }
  
  // Filter donations by blood group
  Stream<QuerySnapshot<Map<String, dynamic>>> getDonationsByBloodGroup(String bloodGroup) {
    if (bloodGroup == 'All') {
      return getAllDonations();
    }
    
    return _donationsRef
        .where('bloodGroup', isEqualTo: bloodGroup)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }
  
  // Get donation by ID
  Future<DocumentSnapshot<Map<String, dynamic>>> getDonationById(String donationId) {
    return _userDonationsRef.doc(donationId).get();
  }
  
  // Update donation record
  Future<void> updateDonation(String donationId, Map<String, dynamic> data) async {
    // Get current donation to calculate difference in amount
    DocumentSnapshot<Map<String, dynamic>> currentDonation = 
        await _userDonationsRef.doc(donationId).get();
    
    double oldAmount = 0.0;
    if (currentDonation.exists) {
      oldAmount = (currentDonation.data()?['amount'] as num?)?.toDouble() ?? 0.0;
    }
    
    // Update donation record in both collections
    await _userDonationsRef.doc(donationId).update(data);
    await _donationsRef.doc(donationId).update(data);
    
    // If amount changed, update user statistics
    if (data.containsKey('amount')) {
      double newAmount = (data['amount'] as num).toDouble();
      double difference = newAmount - oldAmount;
      
      if (difference != 0) {
        // Update user stats with the difference
        await _updateUserDonationStatsAfterEdit(difference);
      }
    }
  }
  
  // Update user statistics after editing donation
  Future<void> _updateUserDonationStatsAfterEdit(double amountDifference) async {
    if (_userId == null) return;
    
    DocumentReference userRef = _firestore.collection('users').doc(_userId);
    
    // Get current statistics
    DocumentSnapshot userDoc = await userRef.get();
    if (userDoc.exists) {
      Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
      
      double totalAmount = (userData['totalBloodDonated'] as num?)?.toDouble() ?? 0.0;
      
      // Update total blood donated
      await userRef.update({
        'totalBloodDonated': totalAmount + amountDifference,
      });
    }
  }
  
  // Delete donation record
  Future<void> deleteDonation(String donationId) async {
    // Get current donation to adjust statistics
    DocumentSnapshot<Map<String, dynamic>> currentDonation = 
        await _userDonationsRef.doc(donationId).get();
    
    double amount = 0.0;
    if (currentDonation.exists) {
      amount = (currentDonation.data()?['amount'] as num?)?.toDouble() ?? 0.0;
    }
    
    // Delete the donation from both collections
    await _userDonationsRef.doc(donationId).delete();
    await _donationsRef.doc(donationId).delete();
    
    // Update user statistics
    await _updateUserDonationStatsAfterDelete(amount);
  }
  
  // Update user statistics after deleting donation
  Future<void> _updateUserDonationStatsAfterDelete(double amount) async {
    if (_userId == null) return;
    
    DocumentReference userRef = _firestore.collection('users').doc(_userId);
    
    // Get current statistics
    DocumentSnapshot userDoc = await userRef.get();
    if (userDoc.exists) {
      Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
      
      int totalDonations = (userData['totalDonations'] as num?)?.toInt() ?? 0;
      double totalAmount = (userData['totalBloodDonated'] as num?)?.toDouble() ?? 0.0;
      
      // Update statistics
      await userRef.update({
        'totalDonations': totalDonations > 0 ? totalDonations - 1 : 0,
        'totalBloodDonated': totalAmount - amount >= 0 ? totalAmount - amount : 0,
      });
    }
  }
  
  // Get user's total donation statistics
  Future<Map<String, dynamic>> getUserDonationStats() async {
    if (_userId == null) {
      return {
        'totalDonations': 0,
        'totalBloodDonated': 0.0,
        'lastDonationDate': null,
      };
    }
    
    DocumentSnapshot userDoc = await _firestore
        .collection('users')
        .doc(_userId)
        .get();
    
    if (userDoc.exists) {
      Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
      
      return {
        'totalDonations': userData['totalDonations'] ?? 0,
        'totalBloodDonated': userData['totalBloodDonated'] ?? 0.0,
        'lastDonationDate': userData['lastDonationDate'],
      };
    }
    
    return {
      'totalDonations': 0,
      'totalBloodDonated': 0.0,
      'lastDonationDate': null,
    };
  }
}