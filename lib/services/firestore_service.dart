import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Get the active campaign for event page
  Stream<QuerySnapshot> getActiveCampaign() {
    return _firestore
        .collection('fundraising_campaigns')
        .where('status', isEqualTo: 'Active')
        .orderBy('createdAt', descending: true)
        .limit(1)
        .snapshots();
  }
  
  // Get all campaigns for admin
  Stream<QuerySnapshot> getAllCampaigns() {
    return _firestore
        .collection('fundraising_campaigns')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }
  
  // Create a new campaign
  Future<void> createCampaign({
    required String title,
    required String description,
    required double targetAmount,
    required DateTime? endDate,
  }) async {
    try {
      // When creating a new campaign, set status to Active
      await _firestore.collection('fundraising_campaigns').add({
        'title': title,
        'description': description,
        'targetAmount': targetAmount,
        'raisedAmount': 0.0,
        'endDate': endDate != null ? Timestamp.fromDate(endDate) : null,
        'status': 'Active',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'createdBy': _firestore.collection('users').doc(
          FirebaseAuth.instance.currentUser?.uid
        ),
      });
    } catch (e) {
      rethrow;
    }
  }
  
  // Update campaign
  Future<void> updateCampaign({
    required String campaignId,
    required Map<String, dynamic> data,
  }) async {
    try {
      data['updatedAt'] = FieldValue.serverTimestamp();
      await _firestore
          .collection('fundraising_campaigns')
          .doc(campaignId)
          .update(data);
    } catch (e) {
      rethrow;
    }
  }
  
  // Delete campaign
  Future<void> deleteCampaign(String campaignId) async {
    try {
      await _firestore
          .collection('fundraising_campaigns')
          .doc(campaignId)
          .delete();
    } catch (e) {
      rethrow;
    }
  }
  
  // Make a campaign active and others inactive
  Future<void> setActiveCampaign(String campaignId) async {
    try {
      // Start a batch write
      WriteBatch batch = _firestore.batch();
      
      // Get all active campaigns
      QuerySnapshot activeCampaigns = await _firestore
          .collection('fundraising_campaigns')
          .where('status', isEqualTo: 'Active')
          .get();
      
      // Set all active campaigns to inactive
      for (var doc in activeCampaigns.docs) {
        batch.update(doc.reference, {
          'status': 'Inactive',
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
      
      // Set the selected campaign to active
      batch.update(
        _firestore.collection('fundraising_campaigns').doc(campaignId), 
        {
          'status': 'Active',
          'updatedAt': FieldValue.serverTimestamp(),
        }
      );
      
      // Commit the batch
      await batch.commit();
    } catch (e) {
      rethrow;
    }
  }
}