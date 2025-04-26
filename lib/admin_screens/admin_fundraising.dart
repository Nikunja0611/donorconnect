import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/firestore_service.dart';

class AdminFundraising extends StatefulWidget {
  @override
  _AdminFundraisingState createState() => _AdminFundraisingState();
}

class _AdminFundraisingState extends State<AdminFundraising> {
  String? selectedCampaignId;
  bool isLoading = false;
  final FirestoreService _firestoreService = FirestoreService();
  
  @override
  Widget build(BuildContext context) {
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
                  
                  String title = data['title'] ?? 'Untitled Campaign';
                  String description = data['description'] ?? 'No description';
                  double targetAmount = (data['targetAmount'] ?? 0).toDouble();
                  double raisedAmount = (data['raisedAmount'] ?? 0).toDouble();
                  Timestamp? endDate = data['endDate'] as Timestamp?;
                  String status = data['status'] ?? 'Active';
                  
                  // Calculate progress
                  double progress = targetAmount > 0 ? (raisedAmount / targetAmount) : 0;
                  
                  // Format dates
                  String formattedEndDate = 'No end date';
                  if (endDate != null) {
                    formattedEndDate = DateFormat('dd/MM/yyyy').format(endDate.toDate());
                  }
                  
                  // Format amounts with Rupee symbol instead of dollar
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
                },
              ),
            ),
          ],
        );
      },
    );
  }
  
  void _showCampaignDetails(BuildContext context, String campaignId, Map<String, dynamic> data) {
    final primaryColor = Theme.of(context).primaryColor;
    
    String title = data['title'] ?? 'Untitled Campaign';
    String description = data['description'] ?? 'No description';
    double targetAmount = (data['targetAmount'] ?? 0).toDouble();
    double raisedAmount = (data['raisedAmount'] ?? 0).toDouble();
    Timestamp? endDate = data['endDate'] as Timestamp?;
    String status = data['status'] ?? 'Active';
    
    // Format dates
    String formattedEndDate = 'No end date';
    if (endDate != null) {
      formattedEndDate = DateFormat('dd/MM/yyyy').format(endDate.toDate());
    }
    
    // Format amounts with Rupee symbol instead of dollar
    NumberFormat currencyFormat = NumberFormat.currency(symbol: '₹');
    String formattedTarget = currencyFormat.format(targetAmount);
    String formattedRaised = currencyFormat.format(raisedAmount);
    
    // Calculate progress
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
                    SnackBar(content: Text('Campaign created successfully')),
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
    final raisedAmountController = TextEditingController(text: (data['raisedAmount'] ?? 0).toString());
    
    final endDate = data['endDate'] as Timestamp?;
    final endDateController = TextEditingController(
      text: endDate != null ? DateFormat('dd/MM/yyyy').format(endDate.toDate()) : ''
    );
    
    DateTime? selectedEndDate = endDate?.toDate();
    
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
                  controller: raisedAmountController,
                  decoration: InputDecoration(
                    labelText: 'Raised Amount (₹)',
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
              child: Text('Save Changes'),
              onPressed: () async {
                if (titleController.text.isEmpty || 
                    descriptionController.text.isEmpty || 
                    targetAmountController.text.isEmpty ||
                    raisedAmountController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please fill all required fields')),
                  );
                  return;
                }
                
                double? targetAmount = double.tryParse(targetAmountController.text);
                double? raisedAmount = double.tryParse(raisedAmountController.text);
                if (targetAmount == null || targetAmount <= 0 || raisedAmount == null || raisedAmount < 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please enter valid amounts')),
                  );
                  return;
                }
                
                try {
                  await _firestoreService.updateCampaign(
                    campaignId: campaignId,
                    data: {
                      'title': titleController.text,
                      'description': descriptionController.text,
                      'targetAmount': targetAmount,
                      'raisedAmount': raisedAmount,
                      'endDate': selectedEndDate != null ? Timestamp.fromDate(selectedEndDate!) : null,
                    },
                  );
                  
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Campaign updated successfully')),
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
      case 'inactive':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }
}