import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DonationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user ID
  String? getUserId() {
    return _auth.currentUser?.uid;
  }

  // Reference to donations collection
  CollectionReference<Map<String, dynamic>> get _donationsRef {
    return _firestore.collection('donations');
  }

  // Reference to the user's donations sub-collection
  CollectionReference<Map<String, dynamic>> get _userDonationsRef {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        print('User not authenticated when accessing _userDonationsRef');
        throw Exception("User not authenticated");
      }
      return _firestore.collection('users').doc(userId).collection('donations');
    } catch (e) {
      print('Error getting _userDonationsRef: $e');
      throw Exception("Error accessing donations: $e");
    }
  }

  // Add a new donation record
  Future<void> addDonation({
    required String date,
    required String location,
    required String bloodBank,
    required double amount,
    String? notes,
    String?
        receiptData, // This could be base64 encoded string or a URL if stored elsewhere
  }) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        print('User not authenticated when adding donation');
        throw Exception("User not authenticated");
      }

      // Get user data for donor information
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(userId).get();
      Map<String, dynamic> userData = {};

      if (userDoc.exists) {
        userData = userDoc.data() as Map<String, dynamic>;
      } else {
        print('User document does not exist for user ID: $userId');
      }

      // Create donation document
      final donationData = {
        'userId': userId,
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

      print('Adding donation with data: $donationData');

      // Add to global donations collection
      DocumentReference globalDonationRef =
          await _donationsRef.add(donationData);
      String globalDonationId = globalDonationRef.id;

      // Add to user's donations sub-collection with the same ID for reference
      await _userDonationsRef.doc(globalDonationId).set(donationData);

      // Update user's total donation statistics
      await _updateUserDonationStats(amount);

      // Complete the addDonation method
      print('Donation added successfully with ID: $globalDonationId');
    } catch (e) {
      print('Error adding donation: $e');
      throw Exception('Failed to add donation: $e');
    }
  }

  // Update user's donation statistics
  Future<void> _updateUserDonationStats(double amount) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        throw Exception("User not authenticated");
      }

      DocumentReference userRef = _firestore.collection('users').doc(userId);
      DocumentSnapshot userDoc = await userRef.get();

      if (userDoc.exists) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;

        // Get current stats or initialize if they don't exist
        int totalDonations = (userData['totalDonations'] is int)
            ? userData['totalDonations']
            : 0;
        double totalAmount = (userData['totalAmountDonated'] is num)
            ? (userData['totalAmountDonated'] as num).toDouble()
            : 0.0;

        // Update stats
        await userRef.update({
          'totalDonations': totalDonations + 1,
          'totalAmountDonated': totalAmount + amount,
          'lastDonationDate': FieldValue.serverTimestamp(),
        });

        print('User donation stats updated successfully');
      } else {
        // Create user stats document if it doesn't exist
        await userRef.set({
          'totalDonations': 1,
          'totalAmountDonated': amount,
          'lastDonationDate': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        print('User donation stats created successfully');
      }
    } catch (e) {
      print('Error updating user donation stats: $e');
      // We don't throw here to prevent the main donation operation from failing
    }
  }

  // Get all donations for the current user
  Stream<QuerySnapshot> getUserDonations() {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        print('User not authenticated when getting donations');
        throw Exception("User not authenticated");
      }

      return _userDonationsRef
          .orderBy('timestamp', descending: true)
          .snapshots();
    } catch (e) {
      print('Error getting user donations: $e');
      throw Exception("Error getting donations: $e");
    }
  }

  // Get a specific donation by ID
  Future<DocumentSnapshot> getDonationById(String donationId) async {
    try {
      return await _userDonationsRef.doc(donationId).get();
    } catch (e) {
      print('Error getting donation by ID: $e');
      throw Exception("Error retrieving donation: $e");
    }
  }

  // Update an existing donation
  Future<void> updateDonation(
      String donationId, Map<String, dynamic> data) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        print('User not authenticated when updating donation');
        throw Exception("User not authenticated");
      }

      // Update in user's collection
      await _userDonationsRef.doc(donationId).update(data);

      // Update in global collection
      await _donationsRef.doc(donationId).update(data);

      print('Donation updated successfully');
    } catch (e) {
      print('Error updating donation: $e');
      throw Exception("Failed to update donation: $e");
    }
  }

  // Delete a donation
  Future<void> deleteDonation(String donationId) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        print('User not authenticated when deleting donation');
        throw Exception("User not authenticated");
      }

      // Get the donation amount before deleting to update user stats
      DocumentSnapshot donationDoc =
          await _userDonationsRef.doc(donationId).get();
      if (donationDoc.exists) {
        final data = donationDoc.data() as Map<String, dynamic>;
        final amount =
            (data['amount'] is num) ? (data['amount'] as num).toDouble() : 0.0;

        // Delete from user's collection
        await _userDonationsRef.doc(donationId).delete();

        // Delete from global collection
        await _donationsRef.doc(donationId).delete();

        // Update user stats
        await _updateUserDonationStatsAfterDelete(amount);

        print('Donation deleted successfully');
      } else {
        print('Donation not found with ID: $donationId');
        throw Exception("Donation not found");
      }
    } catch (e) {
      print('Error deleting donation: $e');
      throw Exception("Failed to delete donation: $e");
    }
  }

  // Update user stats after deletion
  // Update user stats after deletion
  Future<void> _updateUserDonationStatsAfterDelete(double amount) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        throw Exception("User not authenticated");
      }

      DocumentReference userRef = _firestore.collection('users').doc(userId);
      DocumentSnapshot userDoc = await userRef.get();

      if (userDoc.exists) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;

        // Get current stats
        int totalDonations = (userData['totalDonations'] is int)
            ? userData['totalDonations']
            : 0;
        double totalAmount = (userData['totalAmountDonated'] is num)
            ? (userData['totalAmountDonated'] as num).toDouble()
            : 0.0;

        // Calculate new total donations
        int newTotalDonations = (totalDonations > 0) ? totalDonations - 1 : 0;

        // Update data to write to Firestore
        Map<String, dynamic> updateData = {
          'totalDonations': newTotalDonations,
          'totalAmountDonated':
              (totalAmount >= amount) ? totalAmount - amount : 0,
        };

        // Check if this was their last donation
        if (newTotalDonations == 0) {
          // If no donations left, reset donation dates and set availability to true
          updateData['lastDonationDate'] = null;
          updateData['nextDonationDate'] = null;
          updateData['isAvailable'] = true;
        } else {
          // If they still have donations, find the new most recent one
          QuerySnapshot remainingDonations = await _userDonationsRef
              .orderBy('timestamp', descending: true)
              .limit(1)
              .get();

          if (remainingDonations.docs.isNotEmpty) {
            Map<String, dynamic> mostRecentDonation =
                remainingDonations.docs.first.data() as Map<String, dynamic>;

            if (mostRecentDonation['timestamp'] != null) {
              Timestamp donationTimestamp =
                  mostRecentDonation['timestamp'] as Timestamp;

              // Update lastDonationDate with the timestamp of the most recent donation
              updateData['lastDonationDate'] = donationTimestamp;

              // Calculate eligibility (100 days from last donation)
              DateTime donationDate = donationTimestamp.toDate();
              DateTime nextEligibleDate = donationDate.add(Duration(days: 100));

              // Check if user is eligible now
              bool isEligible = DateTime.now().isAfter(nextEligibleDate);
              updateData['isAvailable'] = isEligible;

              if (isEligible) {
                updateData['nextDonationDate'] = null;
              } else {
                // Store nextDonationDate as a string in format dd/MM/yyyy
                updateData['nextDonationDate'] =
                    '${nextEligibleDate.day.toString().padLeft(2, '0')}/${nextEligibleDate.month.toString().padLeft(2, '0')}/${nextEligibleDate.year}';
              }
            }
          }
        }

        // Update the user document
        await userRef.update(updateData);

        print(
            'User donation stats updated after deletion with data: $updateData');
      }
    } catch (e) {
      print('Error updating user stats after deletion: $e');
      // Don't throw to prevent the main deletion operation from failing
    }
  }
}
