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
  final int _restPeriodDays = 100; // Standard rest period between donations
  String _motivationalQuote =
      "Your generosity flows through the veins of those you've never met.";

  @override
  void initState() {
    super.initState();
    // Initialize Intl
    Intl.defaultLocale = 'en_US';
    print('DonationHistoryPage initialized');
    _loadRandomQuote();
  }

  void _loadRandomQuote() {
    final List<String> quotes = [
      "Your generosity flows through the veins of those you've never met.",
      "Every drop you donate creates ripples of hope.",
      "Rest now, hero. Your blood is already saving lives.",
      "The best gift is the one that keeps someone alive.",
      "Your 100-day journey is preparing you for your next heroic act.",
    ];

    setState(() {
      _motivationalQuote = quotes[DateTime.now().millisecond % quotes.length];
    });
  }

  // Format date in display format
  String _formatDisplayDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  // Calculate next eligible donation date
  DateTime _calculateNextEligibleDate(DateTime donationDate) {
    return donationDate.add(Duration(days: _restPeriodDays));
  }

  // Check if user is currently eligible to donate
  bool _isEligibleToDonate(DateTime donationDate) {
    DateTime nextEligibleDate = _calculateNextEligibleDate(donationDate);
    return DateTime.now().isAfter(nextEligibleDate);
  }

  // Update user's availability status based on donation history
  Future<void> _updateUserAvailabilityStatus(DateTime mostRecentDate) async {
    try {
      bool isEligible = _isEligibleToDonate(mostRecentDate);
      DateTime nextDonationDate = _calculateNextEligibleDate(mostRecentDate);

      // Update user document in Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(_donationService.getUserId())
          .update({
        'isAvailable': isEligible,
        'nextDonationDate': nextDonationDate, // Store as Timestamp
        'lastDonationDate': mostRecentDate, // Store as Timestamp
      });

      print(
          'Updated availability status: $isEligible, next date: ${_formatDisplayDate(nextDonationDate)}');
    } catch (e) {
      print('Error updating availability status: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    print('Building DonationHistoryPage');
    print('User ID: ${_donationService.getUserId()}');

    // Authentication check
    if (_donationService.getUserId() == null) {
      return Scaffold(
        backgroundColor: Color(0xFFF8ECF1),
        appBar: AppBar(
          backgroundColor: Color(0xFFD95373),
          title: Text('Donation History',
              style: TextStyle(fontWeight: FontWeight.bold)),
          centerTitle: true,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 80, color: Colors.grey[400]),
              SizedBox(height: 20),
              Text(
                'You need to be logged in to view donations',
                style: TextStyle(fontSize: 18, color: Colors.grey[600]),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // Navigate to login screen
                  // Navigator.pushReplacementNamed(context, '/login');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFD95373),
                  foregroundColor: Colors.white,
                ),
                child: Text('Go to Login'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Color(0xFFF8ECF1),
      appBar: AppBar(
        backgroundColor: Color(0xFFD95373),
        title: Text('Donation History',
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _donationService.getUserDonations(),
        builder: (context, snapshot) {
          // Connection state handling
          if (snapshot.connectionState == ConnectionState.waiting) {
            print('Waiting for data...');
            return Center(
                child: CircularProgressIndicator(color: Color(0xFFC14465)));
          }

          // Error handling with more details
          if (snapshot.hasError) {
            print('Stream error: ${snapshot.error}');
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 60, color: Colors.red[300]),
                  SizedBox(height: 20),
                  Text(
                    'Error loading donations: ${snapshot.error}',
                    style: TextStyle(color: Colors.red[300]),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => setState(() {}),
                    child: Text('Retry'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFD95373),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            print('No donation data available');
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
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          print('Found ${snapshot.data!.docs.length} donation records');

          // Get the most recent donation to calculate availability
          var sortedDocs = snapshot.data!.docs.toList()
            ..sort((a, b) {
              var aData = a.data() as Map<String, dynamic>;
              var bData = b.data() as Map<String, dynamic>;

              // Get timestamp or date string from documents
              DateTime aDate = _getDonationDateTime(aData);
              DateTime bDate = _getDonationDateTime(bData);

              return bDate.compareTo(aDate); // Descending order
            });

          // Process most recent donation
          if (sortedDocs.isNotEmpty) {
            var mostRecentDonation =
                sortedDocs.first.data() as Map<String, dynamic>;
            DateTime mostRecentDate = _getDonationDateTime(mostRecentDonation);

            // Update user availability status
            _updateUserAvailabilityStatus(mostRecentDate);

            // Calculate if eligible and next donation date
            bool isEligible = _isEligibleToDonate(mostRecentDate);
            DateTime nextDonationDate =
                _calculateNextEligibleDate(mostRecentDate);

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildDonationSummary(snapshot.data!.docs),

                  // Show availability status and next donation date
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 16),
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isEligible
                          ? Colors.green.shade50
                          : Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: isEligible
                            ? Colors.green.shade300
                            : Colors.amber.shade300,
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Icon(
                              isEligible
                                  ? Icons.check_circle
                                  : Icons.hourglass_top,
                              color: isEligible
                                  ? Colors.green
                                  : Colors.amber.shade700,
                              size: 22,
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                isEligible
                                    ? 'You are eligible to donate blood!'
                                    : 'You need to wait until ${_formatDisplayDate(nextDonationDate)} to donate again',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: isEligible
                                      ? Colors.green.shade700
                                      : Colors.amber.shade900,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Text(
                          _motivationalQuote,
                          style: TextStyle(
                            fontStyle: FontStyle.italic,
                            fontSize: 12,
                            color: Colors.grey[700],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),

                  Expanded(
                    child: ListView.builder(
                      itemCount: sortedDocs.length,
                      itemBuilder: (context, index) {
                        return _buildDonationCard(sortedDocs[index]);
                      },
                    ),
                  ),
                ],
              ),
            );
          }

          // Default return if no date processing needed
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
                      return _buildDonationCard(snapshot.data!.docs[index]);
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

  // Get DateTime from donation data (handling both Timestamp and string formats)
  DateTime _getDonationDateTime(Map<String, dynamic> donationData) {
    // Check if timestamp field exists
    if (donationData['timestamp'] is Timestamp) {
      return (donationData['timestamp'] as Timestamp).toDate();
    }
    // Check if date field exists and is timestamp
    else if (donationData['date'] is Timestamp) {
      return (donationData['date'] as Timestamp).toDate();
    }
    // Check if date field exists and is string
    else if (donationData['date'] is String) {
      String dateStr = donationData['date'];
      try {
        // Parse date in format DD/MM/YYYY
        List<String> parts = dateStr.split('/');
        if (parts.length == 3) {
          return DateTime(
            int.parse(parts[2]), // Year
            int.parse(parts[1]), // Month
            int.parse(parts[0]), // Day
          );
        }
      } catch (e) {
        print('Error parsing date string: $e');
      }
    }
    // Default fallback
    return DateTime.now();
  }

  Widget _buildDonationSummary(List<QueryDocumentSnapshot> donations) {
    int totalDonations = donations.length;

    // Calculate total amount donated with safer conversion
    double totalAmount = 0;
    for (var donation in donations) {
      var data = donation.data() as Map<String, dynamic>;
      if (data['amount'] != null && data['amount'] is num) {
        totalAmount += (data['amount'] as num).toDouble();
      }
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
    try {
      final data = donation.data() as Map<String, dynamic>;
      
      // Get the date from the document
      DateTime donationDate = _getDonationDateTime(data);
      String displayDate = _formatDisplayDate(donationDate);
      
      final location = data['location'] as String? ?? 'Unknown location';
      final bloodBank = data['bloodBank'] as String? ?? 'Unknown blood bank';
      final amount =
          (data['amount'] is num) ? (data['amount'] as num).toDouble() : 0.0;
      final hasReceipt = data['receiptData'] != null &&
          data['receiptData'].toString().isNotEmpty;

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
                displayDate,
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 14,
                ),
              ),
              SizedBox(height: 5),
              GestureDetector(
                onTap: () =>
                    _showDonationOptions(context, donation.id, hasReceipt),
                child: Icon(
                  Icons.more_vert,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      print('Error building donation card: $e');
      return Container(
        margin: EdgeInsets.only(bottom: 16),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.red.shade300),
        ),
        child: Text('Error displaying donation data'),
      );
    }
  }

  void _showDonationOptions(
      BuildContext context, String donationId, bool hasReceipt) {
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
    try {
      final donation = await _donationService.getDonationById(donationId);

      if (!donation.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Receipt not found')),
        );
        return;
      }

      final data = donation.data() as Map<String, dynamic>;
      final receiptData = data['receiptData'];

      if (receiptData != null && receiptData.toString().isNotEmpty) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Donation Receipt'),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  Text(
                    'Receipt ID: ${donationId.substring(0, 8)}...',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Receipt data: $receiptData',
                    style: TextStyle(fontSize: 14),
                  ),
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
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No receipt data available')),
        );
      }
    } catch (e) {
      print('Error viewing receipt: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading receipt: $e')),
      );
    }
  }

  void _editDonation(String donationId) async {
    try {
      // Get donation data
      final donation = await _donationService.getDonationById(donationId);

      if (!donation.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Donation not found')),
        );
        return;
      }

      final data = donation.data() as Map<String, dynamic>;
      DateTime donationDate = _getDonationDateTime(data);

      // Create controllers with pre-filled data
      final _formKey = GlobalKey<FormState>();
      final dateController = TextEditingController(text: _formatDisplayDate(donationDate));
      final locationController =
          TextEditingController(text: data['location'] ?? '');
      final bloodBankController =
          TextEditingController(text: data['bloodBank'] ?? '');
      final amountController = TextEditingController(
          text: data['amount'] != null
              ? (data['amount'] as num).toString()
              : '0.0');
      final notesController = TextEditingController(text: data['notes'] ?? '');
      final receiptDataController =
          TextEditingController(text: data['receiptData'] ?? '');

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
                      helperText:
                          'Note: This will update your availability status',
                    ),
                    readOnly: true,
                    onTap: () async {
                      final pickedDate = await showDatePicker(
                        context: context,
                        initialDate: donationDate,
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
                        dateController.text = _formatDisplayDate(pickedDate);
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
                    // Parse the date string back to DateTime
                    DateTime selectedDate = _parseDateString(dateController.text);
                    
                    await _donationService.updateDonation(donationId, {
                      'date': selectedDate, // Store as timestamp
                      'timestamp': selectedDate, // Also add timestamp field
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

                    // Refresh the screen to recalculate eligibility
                    setState(() {});
                  } catch (e) {
                    print('Error updating donation: $e');
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
    } catch (e) {
      print('Error editing donation: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error editing donation: $e')),
      );
    }
  }

  // Parse date string in format DD/MM/YYYY back to DateTime
  DateTime _parseDateString(String dateStr) {
    try {
      List<String> parts = dateStr.split('/');
      if (parts.length == 3) {
        return DateTime(
          int.parse(parts[2]), // Year
          int.parse(parts[1]), // Month
          int.parse(parts[0]), // Day
        );
      }
    } catch (e) {
      print('Error parsing date string: $e');
    }
    return DateTime.now(); // Fallback
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
              try {
                Navigator.pop(context);
                await _donationService.deleteDonation(donationId);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Donation deleted successfully')),
                );
                // Refresh the screen to recalculate eligibility
                setState(() {});
              } catch (e) {
                print('Error deleting donation: $e');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error deleting donation: $e')),
                );
              }
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
                      dateController.text = _formatDisplayDate(pickedDate);
                    }
                  },
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Please enter date' : null,
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: locationController,
                  decoration: InputDecoration(
                    labelText: 'Location',
                    suffixIcon: Icon(Icons.location_on),
                  ),
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Please enter location' : null,
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: bloodBankController,
                  decoration: InputDecoration(
                    labelText: 'Blood Bank/Hospital',
                    suffixIcon: Icon(Icons.local_hospital),
                  ),
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Please enter blood bank name' : null,
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

                  // Refresh the screen to recalculate eligibility
                  setState(() {});
                } catch (e) {
                  print('Error adding donation: $e');
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