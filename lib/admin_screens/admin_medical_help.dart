import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdminMedicalHelp extends StatefulWidget {
  @override
  _AdminMedicalHelpState createState() => _AdminMedicalHelpState();
}

class _AdminMedicalHelpState extends State<AdminMedicalHelp> {
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    final isWideScreen = MediaQuery.of(context).size.width > 600;

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('medical_help').orderBy('timestamp', descending: true).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator(
            color: primaryColor,
          ));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.medical_services_outlined,
                  size: 80,
                  color: Colors.grey,
                ),
                SizedBox(height: 16),
                Text(
                  'No medical help requests found',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(height: 24),
                ElevatedButton.icon(
                  icon: Icon(Icons.add),
                  label: Text('Create New Request'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    _showAddRequestDialog(context);
                  },
                ),
              ],
            ),
          );
        }

        return isWideScreen
            ? Row(
                children: [
                  _buildRequestList(snapshot),
                ],
              )
            : Column(
                children: [
                  Expanded(child: _buildRequestList(snapshot)),
                ],
              );
      },
    );
  }

  Widget _buildRequestList(AsyncSnapshot<QuerySnapshot> snapshot) {
    final primaryColor = Theme.of(context).primaryColor;

    return Expanded(
      child: ListView.builder(
        padding: EdgeInsets.all(12),
        itemCount: snapshot.data!.docs.length,
        itemBuilder: (context, index) {
          var doc = snapshot.data!.docs[index];
          var data = doc.data() as Map<String, dynamic>;

          String requesterName = data['requesterName'] ?? 'Unknown';
          List<dynamic> equipmentList = data['equipments'] ?? [];
          String equipment = equipmentList.isNotEmpty ? equipmentList.join(', ') : 'None';

          String requestedDate = 'N/A';
          if (data['requestedDate'] != null) {
            Timestamp timestamp = data['requestedDate'] as Timestamp;
            DateTime dateTime = timestamp.toDate();
            requestedDate = '${dateTime.day}-${dateTime.month}-${dateTime.year}';
          }

          String status = data['status'] ?? 'Pending';

          return Card(
            margin: EdgeInsets.symmetric(vertical: 8),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              leading: CircleAvatar(
                backgroundColor: _getStatusColor(status).withOpacity(0.2),
                child: Icon(
                  Icons.medical_services,
                  color: _getStatusColor(status),
                ),
              ),
              title: Text(
                requesterName,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Date Needed: $requestedDate'),
                  Text('Equipment: ${equipment.length > 30 ? equipment.substring(0, 30) + '...' : equipment}'),
                ],
              ),
              trailing: Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusColor(status).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: _getStatusColor(status),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              onTap: () {
                _showRequestDetailsDialog(doc.id);
              },
            ),
          );
        },
      ),
    );
  }

  void _showRequestDetailsDialog(String requestId) {
    final primaryColor = Theme.of(context).primaryColor;
    final isMobile = MediaQuery.of(context).size.width < 500;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        insetPadding: EdgeInsets.all(isMobile ? 12 : 20),
        child: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance.collection('medical_help').doc(requestId).snapshots(),
          builder: (context, requestSnapshot) {
            if (!requestSnapshot.hasData || requestSnapshot.hasError) {
              return Container(
                height: 300,
                child: Center(child: CircularProgressIndicator()),
              );
            }

            var requestData = requestSnapshot.data!.data() as Map<String, dynamic>?;
            if (requestData == null) {
              return Center(child: Text('Request not found'));
            }

            String requesterName = requestData['requesterName'] ?? 'Unknown';
            String requesterId = requestData['requesterId'] ?? '';
            List<dynamic> equipmentList = requestData['equipments'] ?? [];
            String status = requestData['status'] ?? 'Pending';

            String requestedDate = 'N/A';
            if (requestData['requestedDate'] != null) {
              Timestamp timestamp = requestData['requestedDate'] as Timestamp;
              DateTime dateTime = timestamp.toDate();
              requestedDate = '${dateTime.day}-${dateTime.month}-${dateTime.year}';
            }

            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance.collection('users').doc(requesterId).get(),
              builder: (context, userSnapshot) {
                String email = '';
                String phone = '';
                String address = '';

                if (userSnapshot.hasData && userSnapshot.data != null) {
                  var userData = userSnapshot.data!.data() as Map<String, dynamic>?;
                  if (userData != null) {
                    email = userData['email'] ?? '';
                    phone = userData['phone'] ?? '';
                    address = userData['address'] ?? '';
                  }
                }

                return Container(
                  width: isMobile ? null : 500,
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Request Details',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: primaryColor,
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.close),
                                onPressed: () => Navigator.pop(context),
                              ),
                            ],
                          ),
                          Divider(),
                          _buildDetailRow('Requester', requesterName),
                          _buildDetailRow('Email', email),
                          _buildDetailRow('Phone', phone),
                          _buildDetailRow('Address', address),
                          _buildDetailRow('Date Needed', requestedDate),
                          _buildDetailRow('Status', status),
                          SizedBox(height: 10),
                          Text(
                            'Requested Equipment:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[700],
                            ),
                          ),
                          SizedBox(height: 5),
                          Container(
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: equipmentList.map<Widget>((equipment) =>
                                Padding(
                                  padding: EdgeInsets.symmetric(vertical: 3),
                                  child: Row(
                                    children: [
                                      Icon(Icons.check_circle_outline, size: 16, color: primaryColor),
                                      SizedBox(width: 8),
                                      Expanded(child: Text(equipment)),
                                    ],
                                  ),
                                ),
                              ).toList(),
                            ),
                          ),
                          SizedBox(height: 20),
                          if (_isProcessing)
                            Center(child: Padding(
                              padding: EdgeInsets.all(16),
                              child: CircularProgressIndicator(),
                            )),
                          if (!_isProcessing && status.toLowerCase() != 'approved')
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    icon: Icon(Icons.check_circle),
                                    label: Text('Approve Request'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      foregroundColor: Colors.white,
                                    ),
                                    onPressed: () => _approveRequest(requestId, context),
                                  ),
                                ),
                              ],
                            ),
                          if (status.toLowerCase() == 'approved')
                            Container(
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.green.shade300),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.check_circle, color: Colors.green),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'This request has been approved',
                                      style: TextStyle(
                                        color: Colors.green.shade800,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Future<void> _approveRequest(String requestId, BuildContext context) async {
    try {
      setState(() {
        _isProcessing = true;
      });
      
      // Update the request status in Firestore
      await FirebaseFirestore.instance.collection('medical_help').doc(requestId).update({
        'status': 'Approved',
        'approvedBy': FirebaseAuth.instance.currentUser?.uid,
        'approvedDate': FieldValue.serverTimestamp(),
      });
      
      // Show success message
      Navigator.of(context).pop(); // Close the details dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Request approved successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (error) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error approving request: $error'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  Widget _buildDetailRow(String label, String value) {
    final isMobile = MediaQuery.of(context).size.width < 500;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: isMobile 
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$label:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
              SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 4),
            ],
          )
        : Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 100,
                child: Text(
                  '$label:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  value,
                  style: TextStyle(
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
    );
  }

  Color _getStatusColor(String? status) {
    if (status == null) return Colors.grey;

    switch (status.toLowerCase()) {
      case 'approved':
        return Colors.green;
      case 'in progress':
        return Colors.blue;
      case 'pending':
        return Colors.orange;
      case 'completed':
        return Colors.teal;
      case 'rejected':
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _showAddRequestDialog(BuildContext context) {
    final requestDateController = TextEditingController();
    final requesterController = TextEditingController();
    final List<String> equipments = [
      'Bipap Machines',
      'Cpap Machines',
      'Oxygen Concentrator',
      'Oxygen Cylinder',
      'Patient Beds',
      'Portable Suction Machines',
      'Air Mattress',
      'NIV Mask',
      'Wheel Chairs',
      'Patient Monitor',
      'Nebulizer',
      'BP Machine',
    ];
    List<String> selectedEquipments = [];
    final isSmallScreen = MediaQuery.of(context).size.width < 600;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text('Add New Medical Help Request'),
            content: Container(
              width: isSmallScreen ? null : 500,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: requesterController,
                      decoration: InputDecoration(
                        labelText: 'Requester Name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: requestDateController,
                      decoration: InputDecoration(
                        labelText: 'Required Date',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      readOnly: true,
                      onTap: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2030),
                        );
                        if (picked != null) {
                          requestDateController.text = "${picked.day}-${picked.month}-${picked.year}";
                        }
                      },
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Select Equipment:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Container(
                      height: 200,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ListView.builder(
                        itemCount: equipments.length,
                        itemBuilder: (context, index) {
                          final equipment = equipments[index];
                          final isSelected = selectedEquipments.contains(equipment);
                          
                          return CheckboxListTile(
                            title: Text(equipment),
                            value: isSelected,
                            onChanged: (bool? value) {
                              setState(() {
                                if (value == true) {
                                  selectedEquipments.add(equipment);
                                } else {
                                  selectedEquipments.remove(equipment);
                                }
                              });
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                child: Text('Cancel'),
                onPressed: () => Navigator.pop(context),
              ),
              ElevatedButton(
                child: Text('Add Request'),
                onPressed: () async {
                  if (requesterController.text.isEmpty || requestDateController.text.isEmpty || selectedEquipments.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Please fill all fields and select at least one equipment')),
                    );
                    return;
                  }
                  
                  // Parse the date
                  final dateParts = requestDateController.text.split('-');
                  final requestDate = DateTime(
                    int.parse(dateParts[2]),
                    int.parse(dateParts[1]),
                    int.parse(dateParts[0]),
                  );
                  
                  try {
                    await FirebaseFirestore.instance.collection('medical_help').add({
                      'requesterName': requesterController.text,
                      'requesterId': FirebaseAuth.instance.currentUser?.uid,
                      'requestedDate': Timestamp.fromDate(requestDate),
                      'equipments': selectedEquipments,
                      'status': 'Pending',
                      'timestamp': FieldValue.serverTimestamp(),
                    });
                    
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Request added successfully')),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error adding request: $e')),
                    );
                  }
                },
              ),
            ],
          );
        },
      ),
    );
  }
}