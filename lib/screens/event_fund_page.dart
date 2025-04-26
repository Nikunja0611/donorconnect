import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../services/firestore_service.dart';

class EventFundPage extends StatelessWidget {
  final FirestoreService _firestoreService = FirestoreService();
  
  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFD44C6D),
        title: Text('Fundraising Campaign',
                          textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    height: 1.1,),
                    
        )
      ),
      body: StreamBuilder<QuerySnapshot>(
        // Changed 'campaigns' to 'fundraising_campaigns' to match your security rules
        stream: FirebaseFirestore.instance.collection('fundraising_campaigns')
            .where('status', isEqualTo: 'Active')
            .orderBy('createdAt', descending: true)
            .limit(1)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            // Add better error handling for permission errors
            if (snapshot.error.toString().contains('permission-denied')) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.lock, size: 80, color: Colors.red[300]),
                    SizedBox(height: 16),
                    Text(
                      'Permission denied. Please log in to view campaigns.',
                      style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: primaryColor));
          }
          
          // No active campaigns or data
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.campaign_outlined, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No active fundraising campaign',
                    style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                  ),
                ],
              ),
            );
          }
          
          // Get the active campaign data
          var doc = snapshot.data!.docs.first;
          var data = doc.data() as Map<String, dynamic>;
          
          String title = data['title'] ?? 'Untitled Campaign';
          String description = data['description'] ?? 'No description';
          double targetAmount = data['targetAmount'] is double 
              ? data['targetAmount'] 
              : (data['targetAmount'] is int ? data['targetAmount'].toDouble() : 0.0);
          double raisedAmount = data['raisedAmount'] is double 
              ? data['raisedAmount'] 
              : (data['raisedAmount'] is int ? data['raisedAmount'].toDouble() : 0.0);
          Timestamp? endDate = data['endDate'] as Timestamp?;
          
          // Calculate progress
          double progress = targetAmount > 0 ? (raisedAmount / targetAmount) : 0;
          if (progress > 1.0) progress = 1.0; // Cap progress at 100%
          
          // Format dates
          String formattedEndDate = 'No end date';
          if (endDate != null) {
            formattedEndDate = DateFormat('MMMM dd, yyyy').format(endDate.toDate());
          }
          
          // Format amounts with Rupee symbol instead of dollar
          NumberFormat currencyFormat = NumberFormat.currency(symbol: '₹');
          String formattedTarget = currencyFormat.format(targetAmount);
          String formattedRaised = currencyFormat.format(raisedAmount);
          
          // Payment QR code with campaign ID
          String qrData = "https://donation.example.com/donate?campaign=${doc.id}";
          
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Campaign Header
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Color(0xFFD44C6D),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                    ),
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Ends on $formattedEndDate',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Campaign Details
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(16),
                        bottomRight: Radius.circular(16),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Progress section
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              formattedRaised,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: primaryColor,
                              ),
                            ),
                            Text(
                              'of $formattedTarget',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        
                        // Progress bar
                        LinearProgressIndicator(
                          value: progress,
                          backgroundColor: Colors.grey[300],
                          minHeight: 10,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            progress >= 1.0 ? Colors.green : primaryColor,
                          ),
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
                        SizedBox(height: 16),
                        
                        // Description section
                        Text(
                          'About this campaign',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          description,
                          style: TextStyle(
                            fontSize: 16,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  SizedBox(height: 24),
                  
                  // Donation QR Section
                  Center(
                    child: Column(
                      children: [
                        Text(
                          'Scan to Donate',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 16),
                        Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: QrImageView(
                            data: qrData,
                            version: QrVersions.auto,
                            size: 200.0,
                            embeddedImage: AssetImage('assets/qr_code.png'), // Make sure this asset exists
                            embeddedImageStyle: QrEmbeddedImageStyle(
                              size: Size(40, 40),
                            ),
                          ),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Thank you for your support!',
                          style: TextStyle(
                            fontSize: 16,
                            fontStyle: FontStyle.italic,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}