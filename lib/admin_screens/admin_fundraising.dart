import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/firestore_service.dart';

class AdminFundraising extends StatefulWidget {
  @override
  _AdminFundraisingState createState() => _AdminFundraisingState();
}

class _AdminFundraisingState extends State<AdminFundraising> with SingleTickerProviderStateMixin {
  String? selectedCampaignId;
  bool isLoading = false;
  final FirestoreService _firestoreService = FirestoreService();
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin - Fundraising & Requests'),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: [
            Tab(
              icon: Icon(Icons.attach_money),
              text: 'Campaigns',
            ),
            Tab(
              icon: Icon(Icons.favorite),
              text: 'Blood Camp Requests',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCampaignsTab(),
          _buildBloodRequestsTab(),
        ],
      ),
    );
  }
  
  Widget _buildCampaignsTab() {
    final primaryColor = Theme.of(context).primaryColor;
    
    return StreamBuilder<QuerySnapshot>(
      stream: _firestoreService.getAllCampaigns(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator(color: primaryColor));
        }
        
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.attach_money_outlined, size: 80, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No fundraising campaigns found',
                  style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                ),
                SizedBox(height: 24),
                ElevatedButton.icon(
                  icon: Icon(Icons.add),
                  label: Text('Create New Campaign'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () => _showAddCampaignDialog(context),
                ),
              ],
            ),
          );
        }
        
        return Column(
          children: [
            Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'All Campaigns',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  ElevatedButton.icon(
                    icon: Icon(Icons.add),
                    label: Text('New Campaign'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () => _showAddCampaignDialog(context),
                  ),
                ],
              ),
            ),
            Divider(),
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.all(12),
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  var doc = snapshot.data!.docs[index];
                  var data = doc.data() as Map<String, dynamic>;
                  return _buildCampaignCard(doc, data);
                },
              ),
            ),
          ],
        );
      },
    );
  }
  
  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
  return Expanded(
    child: Container(
      margin: EdgeInsets.symmetric(horizontal: 4),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );
}


  Widget _buildBloodRequestsTab() {
  return StreamBuilder<QuerySnapshot>(
    stream: FirebaseFirestore.instance
        .collection('blood_donation_requests')
        .orderBy('createdAt', descending: true)
        .snapshots(),
    builder: (context, snapshot) {
      if (snapshot.hasError) {
        return Center(child: Text('Error: ${snapshot.error}'));
      }
      
      if (snapshot.connectionState == ConnectionState.waiting) {
        return Center(child: CircularProgressIndicator());
      }
      
      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.favorite_outline, size: 80, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'No blood donation camp requests found',
                style: TextStyle(fontSize: 18, color: Colors.grey[700]),
              ),
              SizedBox(height: 8),
              Text(
                'Organizations can submit requests to host blood donation camps',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      }
      
      return Column(
        children: [
          // Header with stats
          Container(
            padding: EdgeInsets.all(16),
            color: Colors.grey[50],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatCard(
                  'Total Requests', 
                  snapshot.data!.docs.length.toString(),
                  Icons.receipt_long,
                  Colors.blue,
                ),
                _buildStatCard(
                  'Pending', 
                  snapshot.data!.docs.where((doc) => 
                    (doc.data() as Map<String, dynamic>)['status'] == 'pending'
                  ).length.toString(),
                  Icons.hourglass_empty,
                  Colors.orange,
                ),
                _buildStatCard(
                  'Approved', 
                  snapshot.data!.docs.where((doc) => 
                    (doc.data() as Map<String, dynamic>)['status'] == 'approved'
                  ).length.toString(),
                  Icons.check_circle,
                  Colors.green,
                ),
              ],
            ),
          ),
          Divider(),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(12),
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                var doc = snapshot.data!.docs[index];
                var data = doc.data() as Map<String, dynamic>;
                return _buildRequestCard(doc, data);
              },
            ),
          ),
        ],
      );
    },
  );
} 
// 1. Update _buildRequestCard method to show more fields
Widget _buildRequestCard(DocumentSnapshot doc, Map<String, dynamic> data) {
  String status = data['status'] ?? 'pending';
  Timestamp? createdAt = data['createdAt'] as Timestamp?;
  String userId = data['userId'] ?? 'Anonymous';
  String userEmail = data['userEmail'] ?? 'No email provided';
  String userPhone = data['phone'] ?? 'No phone provided';
  String organizationName = data['organizationName'] ?? 'No organization provided'; // NEW
  String address = data['address'] ?? 'No address provided'; // NEW
  String expectedParticipants = data['expectedParticipants']?.toString() ?? 'Not specified'; // NEW
  
  String formattedDate = 'Unknown date';
  if (createdAt != null) {
    formattedDate = DateFormat('dd/MM/yyyy HH:mm').format(createdAt.toDate());
  }
  
  return Card(
    margin: EdgeInsets.symmetric(vertical: 8),
    elevation: 2,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: InkWell(
      onTap: () => _showRequestDetails(context, doc.id, data),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded( // UPDATED - Added Expanded
                  child: Text(
                    organizationName, // UPDATED - Show organization name instead of generic title
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getRequestStatusColor(status).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    status.toUpperCase(),
                    style: TextStyle(
                      color: _getRequestStatusColor(status),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            // NEW - Show address
            Row(
              children: [
                Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                SizedBox(width: 4),
                Expanded(
                  child: Text(
                    address,
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            SizedBox(height: 4),
            // UPDATED - Show phone prominently
            Row(
              children: [
                Icon(Icons.phone, size: 16, color: Colors.grey[600]),
                SizedBox(width: 4),
                Text(
                  userPhone,
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 14,
                    fontWeight: FontWeight.w500, // Make phone number more prominent
                  ),
                ),
              ],
            ),
            SizedBox(height: 4),
            // NEW - Show expected participants if available
            if (expectedParticipants != 'Not specified')
              Row(
                children: [
                  Icon(Icons.people, size: 16, color: Colors.grey[600]),
                  SizedBox(width: 4),
                  Text(
                    'Expected: $expectedParticipants donors',
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            SizedBox(height: 8),
            Text(
              'Submitted: $formattedDate',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

// 2. Update _showRequestDetails method to show all fields
void _showRequestDetails(BuildContext context, String requestId, Map<String, dynamic> data) {
  String status = data['status'] ?? 'pending';
  Timestamp? createdAt = data['createdAt'] as Timestamp?;
  Timestamp? preferredDate = data['preferredDate'] as Timestamp?; // NEW
  String userId = data['userId'] ?? 'Anonymous';
  String userEmail = data['userEmail'] ?? 'No email provided';
  String userPhone = data['phone'] ?? 'No phone provided';
  String organizationName = data['organizationName'] ?? 'No organization provided'; // NEW
  String address = data['address'] ?? 'No address provided'; // NEW
  String expectedParticipants = data['expectedParticipants']?.toString() ?? 'Not specified'; // NEW
  String additionalNotes = data['additionalNotes'] ?? 'No additional notes'; // NEW
  
  String formattedDate = 'Unknown date';
  if (createdAt != null) {
    formattedDate = DateFormat('dd/MM/yyyy HH:mm').format(createdAt.toDate());
  }
  
  String formattedPreferredDate = 'Not specified'; // NEW
  if (preferredDate != null) {
    formattedPreferredDate = DateFormat('dd/MM/yyyy').format(preferredDate.toDate());
  }
  
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text('Blood Donation Camp Request'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Status Badge
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getRequestStatusColor(status).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status.toUpperCase(),
                  style: TextStyle(
                    color: _getRequestStatusColor(status),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              SizedBox(height: 16),
              
              // Organization Details Section
              Text(
                'Organization Details',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFD44C6D),
                ),
              ),
              SizedBox(height: 8),
              _buildDetailRow('Organization Name:', organizationName),
              SizedBox(height: 8),
              _buildDetailRow('Address:', address),
              SizedBox(height: 16),
              
              // Contact Information Section
              Text(
                'Contact Information',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFD44C6D),
                ),
              ),
              SizedBox(height: 8),
              _buildDetailRow('Phone:', userPhone),
              SizedBox(height: 8),
              _buildDetailRow('Email:', userEmail),
              SizedBox(height: 16),
              
              // Event Details Section
              Text(
                'Event Details',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFD44C6D),
                ),
              ),
              SizedBox(height: 8),
              _buildDetailRow('Expected Participants:', expectedParticipants),
              SizedBox(height: 8),
              _buildDetailRow('Preferred Date:', formattedPreferredDate),
              SizedBox(height: 16),
              
              // Additional Information Section
              if (additionalNotes != 'No additional notes') ...[
                Text(
                  'Additional Notes',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFD44C6D),
                  ),
                ),
                SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    additionalNotes,
                    style: TextStyle(fontSize: 14),
                  ),
                ),
                SizedBox(height: 16),
              ],
              
              // System Information Section
              Text(
                'System Information',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFD44C6D),
                ),
              ),
              SizedBox(height: 8),
              _buildDetailRow('User ID:', userId),
              SizedBox(height: 8),
              _buildDetailRow('Submitted:', formattedDate),
              SizedBox(height: 16),
              
              // Information Box
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue[800], size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'This organization has requested to host a blood donation camp in partnership with Raktpurak Charitable Foundation.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.blue[800],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            child: Text('Close'),
            onPressed: () => Navigator.pop(context),
          ),
          if (status == 'pending') ...[
            TextButton(
              child: Text('Reject'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              onPressed: () async {
                Navigator.pop(context);
                await _updateRequestStatus(requestId, 'rejected');
              },
            ),
            TextButton(
              child: Text('Approve'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.green,
              ),
              onPressed: () async {
                Navigator.pop(context);
                await _updateRequestStatus(requestId, 'approved');
              },
            ),
          ],
          if (status == 'approved')
            TextButton(
              child: Text('Mark as Pending'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.orange,
              ),
              onPressed: () async {
                Navigator.pop(context);
                await _updateRequestStatus(requestId, 'pending');
              },
            ),
          if (status == 'rejected')
            TextButton(
              child: Text('Approve'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.green,
              ),
              onPressed: () async {
                Navigator.pop(context);
                await _updateRequestStatus(requestId, 'approved');
              },
            ),
        ],
      );
    },
  );
} 
  
  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        SizedBox(width: 8),
        Expanded(
          child: Text(value),
        ),
      ],
    );
  }
  
  Future<void> _updateRequestStatus(String requestId, String newStatus) async {
    setState(() {
      isLoading = true;
    });
    
    try {
      await FirebaseFirestore.instance
          .collection('blood_donation_requests')
          .doc(requestId)
          .update({
        'status': newStatus,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Request status updated to $newStatus')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating request: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }
  
  Color _getRequestStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
  
  // [Keep all existing campaign-related methods unchanged]
  Widget _buildCampaignCard(DocumentSnapshot doc, Map<String, dynamic> data) {
    final primaryColor = Theme.of(context).primaryColor;
    
    String title = data['title'] ?? 'Untitled Campaign';
    String description = data['description'] ?? 'No description';
    double targetAmount = (data['targetAmount'] ?? 0).toDouble();
    double raisedAmount = (data['raisedAmount'] ?? 0).toDouble();
    Timestamp? endDate = data['endDate'] as Timestamp?;
    String status = data['status'] ?? 'Active';
    
    double progress = targetAmount > 0 ? (raisedAmount / targetAmount) : 0;
    
    String formattedEndDate = 'No end date';
    if (endDate != null) {
      formattedEndDate = DateFormat('dd/MM/yyyy').format(endDate.toDate());
    }
    
    NumberFormat currencyFormat = NumberFormat.currency(symbol: '₹');
    String formattedTarget = currencyFormat.format(targetAmount);
    String formattedRaised = currencyFormat.format(raisedAmount);
    
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          setState(() {
            selectedCampaignId = doc.id;
          });
          _showCampaignDetails(context, doc.id, data);
        },
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(status).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        color: _getStatusColor(status),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Text(
                description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 14,
                ),
              ),
              SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'End Date: $formattedEndDate',
                    style: TextStyle(fontSize: 12),
                  ),
                  Text(
                    '$formattedRaised of $formattedTarget',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(
                  progress >= 1.0 ? Colors.green : primaryColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  // [Keep all existing methods: _showCampaignDetails, _setActiveCampaign, 
  // _confirmDeleteCampaign, _deleteCampaign, _updateCampaignStatus, 
  // _showAddCampaignDialog, _showEditCampaignDialog, _getStatusColor]
  
  void _showCampaignDetails(BuildContext context, String campaignId, Map<String, dynamic> data) {
    final primaryColor = Theme.of(context).primaryColor;
    
    String title = data['title'] ?? 'Untitled Campaign';
    String description = data['description'] ?? 'No description';
    double targetAmount = (data['targetAmount'] ?? 0).toDouble();
    double raisedAmount = (data['raisedAmount'] ?? 0).toDouble();
    Timestamp? endDate = data['endDate'] as Timestamp?;
    String status = data['status'] ?? 'Active';
    
    String formattedEndDate = 'No end date';
    if (endDate != null) {
      formattedEndDate = DateFormat('dd/MM/yyyy').format(endDate.toDate());
    }
    
    NumberFormat currencyFormat = NumberFormat.currency(symbol: '₹');
    String formattedTarget = currencyFormat.format(targetAmount);
    String formattedRaised = currencyFormat.format(raisedAmount);
    
    double progress = targetAmount > 0 ? (raisedAmount / targetAmount) : 0;
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Campaign Details'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(status).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      color: _getStatusColor(status),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'Description:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
                Text(description),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'End Date:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(formattedEndDate),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Target Amount:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(formattedTarget),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Raised Amount:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(formattedRaised),
                  ],
                ),
                SizedBox(height: 16),
                Text(
                  'Progress:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    progress >= 1.0 ? Colors.green : primaryColor,
                  ),
                  minHeight: 10,
                ),
                SizedBox(height: 4),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    '${(progress * 100).toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: progress >= 1.0 ? Colors.green : primaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text('Close'),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              child: Text('Edit'),
              onPressed: () {
                Navigator.pop(context);
                _showEditCampaignDialog(context, campaignId, data);
              },
            ),
            TextButton(
              child: Text('Delete'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              onPressed: () async {
                Navigator.pop(context);
                await _confirmDeleteCampaign(context, campaignId);
              },
            ),
            if (status != 'Active')
              TextButton(
                child: Text('Set as Active'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.green,
                ),
                onPressed: () async {
                  Navigator.pop(context);
                  await _setActiveCampaign(context, campaignId);
                },
              ),
            if (status == 'Active')
              TextButton(
                child: Text('Pause'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.orange,
                ),
                onPressed: () async {
                  Navigator.pop(context);
                  await _updateCampaignStatus(campaignId, 'Paused');
                },
              ),
            if (status == 'Paused')
              TextButton(
                child: Text('Resume'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.green,
                ),
                onPressed: () async {
                  Navigator.pop(context);
                  await _updateCampaignStatus(campaignId, 'Active');
                },
              ),
          ],
        );
      },
    );
  }
  
  Future<void> _setActiveCampaign(BuildContext context, String campaignId) async {
    setState(() {
      isLoading = true;
    });
    
    try {
      await _firestoreService.setActiveCampaign(campaignId);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Campaign set as active. It will now appear on the event page.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating campaign: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }
  
  Future<void> _confirmDeleteCampaign(BuildContext context, String campaignId) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Delete'),
          content: Text('Are you sure you want to delete this campaign? This action cannot be undone.'),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              child: Text('Delete'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              onPressed: () async {
                Navigator.pop(context);
                await _deleteCampaign(context, campaignId);
              },
            ),
          ],
        );
      },
    );
  }
  
  Future<void> _deleteCampaign(BuildContext context, String campaignId) async {
    setState(() {
      isLoading = true;
    });
    
    try {
      await _firestoreService.deleteCampaign(campaignId);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Campaign deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting campaign: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }
  
  Future<void> _updateCampaignStatus(String campaignId, String newStatus) async {
    setState(() {
      isLoading = true;
    });
    
    try {
      await _firestoreService.updateCampaign(
        campaignId: campaignId,
        data: {
          'status': newStatus,
        },
      );
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Campaign status updated to $newStatus')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating campaign: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }
  
  void _showAddCampaignDialog(BuildContext context) {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final targetAmountController = TextEditingController();
    final endDateController = TextEditingController();
    DateTime? selectedEndDate;
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Create New Fundraising Campaign'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: 'Campaign Title',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                SizedBox(height: 16),
                TextField(
                  controller: targetAmountController,
                  decoration: InputDecoration(
                    labelText: 'Target Amount (₹)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: endDateController,
                  decoration: InputDecoration(
                    labelText: 'End Date',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  readOnly: true,
                  onTap: () async {
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now().add(Duration(days: 30)),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2030),
                    );
                    if (picked != null) {
                      selectedEndDate = picked;
                      endDateController.text = DateFormat('dd/MM/yyyy').format(picked);
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              child: Text('Create'),
              onPressed: () async {
                if (titleController.text.isEmpty || 
                    descriptionController.text.isEmpty || 
                    targetAmountController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please fill all required fields')),
                  );
                  return;
                }
                
                double? targetAmount = double.tryParse(targetAmountController.text);
                if (targetAmount == null || targetAmount <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please enter a valid target amount')),
                  );
                  return;
                }
                
                try {
                  await _firestoreService.createCampaign(
                    title: titleController.text,
                    description: descriptionController.text,
                    targetAmount: targetAmount,
                    endDate: selectedEndDate,
                  );
                  
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Campaign created successfully!')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error creating campaign: $e')),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }
  
  void _showEditCampaignDialog(BuildContext context, String campaignId, Map<String, dynamic> data) {
    final titleController = TextEditingController(text: data['title'] ?? '');
    final descriptionController = TextEditingController(text: data['description'] ?? '');
    final targetAmountController = TextEditingController(text: (data['targetAmount'] ?? 0).toString());
    final endDateController = TextEditingController();
    DateTime? selectedEndDate;
    
    // Initialize end date if it exists
    if (data['endDate'] != null) {
      selectedEndDate = (data['endDate'] as Timestamp).toDate();
      endDateController.text = DateFormat('dd/MM/yyyy').format(selectedEndDate!);
    }
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Campaign'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: 'Campaign Title',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                SizedBox(height: 16),
                TextField(
                  controller: targetAmountController,
                  decoration: InputDecoration(
                    labelText: 'Target Amount (₹)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: endDateController,
                  decoration: InputDecoration(
                    labelText: 'End Date',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  readOnly: true,
                  onTap: () async {
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: selectedEndDate ?? DateTime.now().add(Duration(days: 30)),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2030),
                    );
                    if (picked != null) {
                      selectedEndDate = picked;
                      endDateController.text = DateFormat('dd/MM/yyyy').format(picked);
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              child: Text('Update'),
              onPressed: () async {
                if (titleController.text.isEmpty || 
                    descriptionController.text.isEmpty || 
                    targetAmountController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please fill all required fields')),
                  );
                  return;
                }
                
                double? targetAmount = double.tryParse(targetAmountController.text);
                if (targetAmount == null || targetAmount <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please enter a valid target amount')),
                  );
                  return;
                }
                
                try {
                  Map<String, dynamic> updateData = {
                    'title': titleController.text,
                    'description': descriptionController.text,
                    'targetAmount': targetAmount,
                  };
                  
                  if (selectedEndDate != null) {
                    updateData['endDate'] = Timestamp.fromDate(selectedEndDate!);
                  }
                  
                  await _firestoreService.updateCampaign(
                    campaignId: campaignId,
                    data: updateData,
                  );
                  
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Campaign updated successfully!')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error updating campaign: $e')),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }
  
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return Colors.green;
      case 'paused':
        return Colors.orange;
      case 'completed':
        return Colors.blue;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}