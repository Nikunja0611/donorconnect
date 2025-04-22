import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../services/donation_service.dart';

class DonationHistoryPage extends StatefulWidget {
  @override
  _DonationHistoryPageState createState() => _DonationHistoryPageState();
}

class _DonationHistoryPageState extends State<DonationHistoryPage> {
  final DonationService _donationService = DonationService();
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8ECF1),
      appBar: AppBar(
        backgroundColor: Color(0xFFD95373),
        title: Text('Donation History', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _donationService.getUserDonations(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: Color(0xFFC14465)));
          }
          
          if (snapshot.hasError) {
            return Center(child: Text('Error loading donations'));
          }
          
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.volunteer_activism,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  SizedBox(height: 20),
                  Text(
                    'No donation records yet',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 30),
                  ElevatedButton.icon(
                    onPressed: () => _showAddDonationDialog(context),
                    icon: Icon(Icons.add),
                    label: Text('Add First Donation'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFD95373),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
          
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildDonationSummary(snapshot.data!.docs),
                SizedBox(height: 20),
                Expanded(
                  child: ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      var donation = snapshot.data!.docs[index];
                      return _buildDonationCard(donation);
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDonationDialog(context),
        backgroundColor: Color(0xFFD95373),
        child: Icon(Icons.add),
      ),
    );
  }
  
  Widget _buildDonationSummary(List<QueryDocumentSnapshot> donations) {
    int totalDonations = donations.length;
    
    // Calculate total amount donated
    double totalAmount = 0;
    for (var donation in donations) {
      totalAmount += (donation['amount'] as num).toDouble();
    }
    
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Your Contribution',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFFC14465),
            ),
          ),
          SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSummaryItem(
                'Total Donations',
                totalDonations.toString(),
                Icons.volunteer_activism,
              ),
              _buildSummaryItem(
                'Blood Donated',
                '${totalAmount.toStringAsFixed(1)} units',
                Icons.water_drop,
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildSummaryItem(String title, String value, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          color: Color(0xFFC14465),
          size: 32,
        ),
        SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 4),
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            color: Colors.black54,
          ),
        ),
      ],
    );
  }
  
  Widget _buildDonationCard(QueryDocumentSnapshot donation) {
    final data = donation.data() as Map<String, dynamic>;
    final date = data['date'] ?? '';
    final location = data['location'] ?? '';
    final bloodBank = data['bloodBank'] ?? '';
    final amount = data['amount'] ?? 0.0;
    final hasReceipt = data['receiptData'] != null && data['receiptData'].toString().isNotEmpty;
    
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 3,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.all(16),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Color(0xFFF8ECF1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.water_drop,
            color: Color(0xFFC14465),
            size: 28,
          ),
        ),
        title: Text(
          bloodBank,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 5),
            Text(
              location,
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 5),
            Text(
              'Amount: ${amount.toString()} units',
              style: TextStyle(fontSize: 14),
            ),
            if (hasReceipt)
              Padding(
                padding: const EdgeInsets.only(top: 5),
                child: Row(
                  children: [
                    Icon(Icons.receipt, size: 14, color: Colors.green),
                    SizedBox(width: 4),
                    Text(
                      'Receipt Available',
                      style: TextStyle(fontSize: 12, color: Colors.green),
                    ),
                  ],
                ),
              ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              date,
              style: TextStyle(
                color: Colors.black54,
                fontSize: 14,
              ),
            ),
            SizedBox(height: 5),
            GestureDetector(
              onTap: () => _showDonationOptions(context, donation.id, hasReceipt),
              child: Icon(
                Icons.more_vert,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  void _showDonationOptions(BuildContext context, String donationId, bool hasReceipt) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (hasReceipt)
                ListTile(
                  leading: Icon(Icons.visibility, color: Colors.blue),
                  title: Text('View Receipt'),
                  onTap: () {
                    Navigator.pop(context);
                    _viewReceipt(donationId);
                  },
                ),
              ListTile(
                leading: Icon(Icons.edit, color: Colors.blue),
                title: Text('Edit Donation'),
                onTap: () {
                  Navigator.pop(context);
                  _editDonation(donationId);
                },
              ),
              ListTile(
                leading: Icon(Icons.delete, color: Colors.red),
                title: Text('Delete Donation'),
                onTap: () {
                  Navigator.pop(context);
                  _confirmDeleteDonation(donationId);
                },
              ),
            ],
          ),
        );
      },
    );
  }
  
  void _viewReceipt(String donationId) async {
    final donation = await _donationService.getDonationById(donationId);
    final data = donation.data() as Map<String, dynamic>;
    final receiptData = data['receiptData'];
    
    if (receiptData != null && receiptData.toString().isNotEmpty) {
      // This would depend on how you're storing the receipt data
      // If it's a base64 string, you could display it as an image
      // If it's a URL or other data, handle accordingly
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Donation Receipt'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                // This implementation depends on how you store receipt data
                // For example, if it's a string URL:
                Text(
                  'Receipt ID: ${donationId.substring(0, 8)}...',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Text(
                  'Receipt data is stored in the database.',
                  style: TextStyle(fontSize: 14),
                ),
                // If it's base64 encoded image data:
                // Image.memory(base64Decode(receiptData)),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Close'),
            ),
          ],
        ),
      );
    }
  }
  
  void _editDonation(String donationId) async {
    // Get donation data
    final donation = await _donationService.getDonationById(donationId);
    final data = donation.data() as Map<String, dynamic>;
    
    // Create controllers with pre-filled data
    final _formKey = GlobalKey<FormState>();
    final dateController = TextEditingController(text: data['date'] ?? '');
    final locationController = TextEditingController(text: data['location'] ?? '');
    final bloodBankController = TextEditingController(text: data['bloodBank'] ?? '');
    final amountController = TextEditingController(text: (data['amount'] ?? 0.0).toString());
    final notesController = TextEditingController(text: data['notes'] ?? '');
    final receiptDataController = TextEditingController(text: data['receiptData'] ?? '');
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Donation'),
        content: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: dateController,
                  decoration: InputDecoration(
                    labelText: 'Date',
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  readOnly: true,
                  onTap: () async {
                    final pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now(),
                      builder: (context, child) {
                        return Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: ColorScheme.light(
                              primary: Color(0xFFC14465),
                            ),
                          ),
                          child: child!,
                        );
                      },
                    );
                    
                    if (pickedDate != null) {
                      dateController.text = DateFormat('dd/MM/yyyy').format(pickedDate);
                    }
                  },
                  validator: (value) => value == null || value.isEmpty
                      ? 'Please enter date'
                      : null,
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: locationController,
                  decoration: InputDecoration(
                    labelText: 'Location',
                    suffixIcon: Icon(Icons.location_on),
                  ),
                  validator: (value) => value == null || value.isEmpty
                      ? 'Please enter location'
                      : null,
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: bloodBankController,
                  decoration: InputDecoration(
                    labelText: 'Blood Bank/Hospital',
                    suffixIcon: Icon(Icons.local_hospital),
                  ),
                  validator: (value) => value == null || value.isEmpty
                      ? 'Please enter blood bank name'
                      : null,
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: amountController,
                  decoration: InputDecoration(
                    labelText: 'Amount (units)',
                    suffixIcon: Icon(Icons.water_drop),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter amount';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: notesController,
                  decoration: InputDecoration(
                    labelText: 'Notes (Optional)',
                    suffixIcon: Icon(Icons.note),
                  ),
                  maxLines: 3,
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: receiptDataController,
                  decoration: InputDecoration(
                    labelText: 'Receipt Info (Optional)',
                    suffixIcon: Icon(Icons.receipt),
                  ),
                  maxLines: 1,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                try {
                  await _donationService.updateDonation(donationId, {
                    'date': dateController.text,
                    'location': locationController.text,
                    'bloodBank': bloodBankController.text,
                    'amount': double.parse(amountController.text),
                    'notes': notesController.text,
                    'receiptData': receiptDataController.text,
                  });
                  
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Donation updated successfully')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error updating donation: $e')),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFD95373),
            ),
            child: Text('Update'),
          ),
        ],
      ),
    );
  }
  
  void _confirmDeleteDonation(String donationId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Donation'),
        content: Text('Are you sure you want to delete this donation record?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _donationService.deleteDonation(donationId);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Donation deleted successfully')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }
  
  void _showAddDonationDialog(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    final dateController = TextEditingController();
    final locationController = TextEditingController();
    final bloodBankController = TextEditingController();
    final amountController = TextEditingController();
    final notesController = TextEditingController();
    final receiptDataController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Donation'),
        content: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: dateController,
                  decoration: InputDecoration(
                    labelText: 'Date',
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  readOnly: true,
                  onTap: () async {
                    final pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now(),
                      builder: (context, child) {
                        return Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: ColorScheme.light(
                              primary: Color(0xFFC14465),
                            ),
                          ),
                          child: child!,
                        );
                      },
                    );
                    
                    if (pickedDate != null) {
                      dateController.text = DateFormat('dd/MM/yyyy').format(pickedDate);
                    }
                  },
                  validator: (value) => value == null || value.isEmpty
                      ? 'Please enter date'
                      : null,
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: locationController,
                  decoration: InputDecoration(
                    labelText: 'Location',
                    suffixIcon: Icon(Icons.location_on),
                  ),
                  validator: (value) => value == null || value.isEmpty
                      ? 'Please enter location'
                      : null,
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: bloodBankController,
                  decoration: InputDecoration(
                    labelText: 'Blood Bank/Hospital',
                    suffixIcon: Icon(Icons.local_hospital),
                  ),
                  validator: (value) => value == null || value.isEmpty
                      ? 'Please enter blood bank name'
                      : null,
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: amountController,
                  decoration: InputDecoration(
                    labelText: 'Amount (units)',
                    suffixIcon: Icon(Icons.water_drop),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter amount';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: notesController,
                  decoration: InputDecoration(
                    labelText: 'Notes (Optional)',
                    suffixIcon: Icon(Icons.note),
                  ),
                  maxLines: 3,
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: receiptDataController,
                  decoration: InputDecoration(
                    labelText: 'Receipt Info (Optional)',
                    suffixIcon: Icon(Icons.receipt),
                  ),
                  maxLines: 1,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                try {
                  await _donationService.addDonation(
                    date: dateController.text,
                    location: locationController.text,
                    bloodBank: bloodBankController.text,
                    amount: double.parse(amountController.text),
                    notes: notesController.text,
                    receiptData: receiptDataController.text.isNotEmpty ? receiptDataController.text : null,
                  );
                  
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Donation added successfully')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error adding donation: $e')),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFD95373),
            ),
            child: Text('Add'),
          ),
        ],
      ),
    );
  }
}