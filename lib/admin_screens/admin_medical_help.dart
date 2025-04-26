// screens/admin_screens/admin_medical_help.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdminMedicalHelp extends StatefulWidget {
  @override
  _AdminMedicalHelpState createState() => _AdminMedicalHelpState();
}

class _AdminMedicalHelpState extends State<AdminMedicalHelp> {
  String? _selectedRequestId;
  bool _isProcessing = false;
  
  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    
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
        
        return Row(
          children: [
            // Left side - List of requests
            Expanded(
              flex: 3,
              child: ListView.builder(
                padding: EdgeInsets.all(12),
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  var doc = snapshot.data!.docs[index];
                  var data = doc.data() as Map<String, dynamic>;
                  
                  String requesterName = data['requesterName'] ?? 'Unknown';
                  List<dynamic> equipmentList = data['equipments'] ?? [];
                  String equipment = equipmentList.isNotEmpty ? equipmentList.join(', ') : 'None';
                  
                  // Format the requested date
                  String requestedDate = 'N/A';
                  if (data['requestedDate'] != null) {
                    Timestamp timestamp = data['requestedDate'] as Timestamp;
                    DateTime dateTime = timestamp.toDate();
                    requestedDate = '${dateTime.day}-${dateTime.month}-${dateTime.year}';
                  }
                  
                  String status = data['status'] ?? 'Pending';
                  
                  bool isSelected = _selectedRequestId == doc.id;
                  
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 8),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    color: isSelected ? primaryColor.withOpacity(0.1) : null,
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
                        setState(() {
                          _selectedRequestId = doc.id;
                        });
                      },
                    ),
                  );
                },
              ),
            ),
            
            // Right side - Details and actions for selected request
            if (_selectedRequestId != null)
              Expanded(
                flex: 2,
                child: StreamBuilder<DocumentSnapshot>(
                  stream: FirebaseFirestore.instance.collection('medical_help').doc(_selectedRequestId).snapshots(),
                  builder: (context, requestSnapshot) {
                    if (!requestSnapshot.hasData || requestSnapshot.hasError) {
                      return Center(child: CircularProgressIndicator());
                    }
                    
                    var requestData = requestSnapshot.data!.data() as Map<String, dynamic>?;
                    if (requestData == null) {
                      return Center(child: Text('Request not found'));
                    }
                    
                    String requesterName = requestData['requesterName'] ?? 'Unknown';
                    String requesterId = requestData['requesterId'] ?? '';
                    List<dynamic> equipmentList = requestData['equipments'] ?? [];
                    String status = requestData['status'] ?? 'Pending';
                    
                    // Format the requested date
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
                        
                        return Card(
                          margin: EdgeInsets.all(16),
                          elevation: 3,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Request Details',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: primaryColor,
                                  ),
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
                                      )
                                    ).toList(),
                                  ),
                                ),
                                Spacer(),
                                Divider(),
                                if (status == 'Pending')
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: ElevatedButton.icon(
                                          icon: Icon(Icons.check_circle),
                                          label: Text('Approve'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.green,
                                            foregroundColor: Colors.white,
                                          ),
                                          onPressed: _isProcessing ? null : () => _processRequest(context, 'Approved', requestData, email, phone, requesterName),
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      Expanded(
                                        child: ElevatedButton.icon(
                                          icon: Icon(Icons.cancel),
                                          label: Text('Reject'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.red,
                                            foregroundColor: Colors.white,
                                          ),
                                          onPressed: _isProcessing ? null : () => _processRequest(context, 'Rejected', requestData, email, phone, requesterName),
                                        ),
                                      ),
                                    ],
                                  ),
                                if (status == 'Approved' || status == 'In Progress')
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: ElevatedButton.icon(
                                          icon: Icon(Icons.done_all),
                                          label: Text('Mark Complete'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.blue,
                                            foregroundColor: Colors.white,
                                          ),
                                          onPressed: _isProcessing ? null : () => _processRequest(context, 'Completed', requestData, email, phone, requesterName),
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      Expanded(
                                        child: ElevatedButton.icon(
                                          icon: Icon(Icons.cancel),
                                          label: Text('Cancel'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.red,
                                            foregroundColor: Colors.white,
                                          ),
                                          onPressed: _isProcessing ? null : () => _processRequest(context, 'Cancelled', requestData, email, phone, requesterName),
                                        ),
                                      ),
                                    ],
                                  ),
                                if (_isProcessing)
                                  Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(16),
                                      child: CircularProgressIndicator(),
                                    ),
                                  )
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              )
            else
              Expanded(
                flex: 2,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.touch_app,
                        size: 64,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Select a request to view details',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
  
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
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
    // Implement the add request dialog similar to the one in the MedicalHelpPage
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
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text('Add New Medical Help Request'),
            content: SingleChildScrollView(
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
  
  Future<void> _processRequest(BuildContext context, String newStatus, Map<String, dynamic> requestData, String email, String phone, String requesterName) async {
    setState(() {
      _isProcessing = true;
    });
    
    try {
      // Update the status in Firestore
      await FirebaseFirestore.instance.collection('medical_help').doc(_selectedRequestId).update({
        'status': newStatus,
        'processedAt': FieldValue.serverTimestamp(),
        'processedBy': FirebaseAuth.instance.currentUser?.uid,
      });
      // For demonstration, simply show a success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Request $newStatus successfully')),
      );
      
      // In a real application, you would send notifications, emails, etc. here
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating request: $e')),
      );
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }
}