import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class AdminBloodBank extends StatefulWidget {
  @override
  _AdminBloodBankState createState() => _AdminBloodBankState();
}

class _AdminBloodBankState extends State<AdminBloodBank> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Filter variables
  String _selectedBloodGroup = 'All';
  String _selectedStatus = 'All';
  DateTime? _startDate;
  DateTime? _endDate;
  String _searchQuery = '';

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

  Widget _buildDateRangePicker() {
    return AlertDialog(
      title: Text('Select Date Range'),
      content: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        height: MediaQuery.of(context).size.height * 0.5,
        child: SfDateRangePicker(
          selectionMode: DateRangePickerSelectionMode.range,
          initialSelectedRange: _startDate != null && _endDate != null
              ? PickerDateRange(_startDate, _endDate)
              : null,
          onSelectionChanged: (DateRangePickerSelectionChangedArgs args) {
            if (args.value is PickerDateRange) {
              setState(() {
                _startDate = args.value.startDate;
                _endDate = args.value.endDate ?? args.value.startDate;
              });
            }
          },
          showActionButtons: true,
          onSubmit: (value) {
            Navigator.pop(context);
          },
          onCancel: () {
            setState(() {
              _startDate = null;
              _endDate = null;
            });
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  Widget _buildFilterBar() {
    // Determine if we're on a small screen
    final isSmallScreen = MediaQuery.of(context).size.width < 600;
    
    return Card(
      margin: EdgeInsets.all(8),
      child: Padding(
        padding: EdgeInsets.all(8),
        child: Column(
          children: [
            // Use column instead of row for small screens
            isSmallScreen 
            ? Column(
                children: [
                  DropdownButtonFormField<String>(
                    value: _selectedBloodGroup,
                    items: ['All', 'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-']
                        .map((group) => DropdownMenuItem(
                              value: group,
                              child: Text(group),
                            ))
                        .toList(),
                    onChanged: (value) => setState(() => _selectedBloodGroup = value!),
                    decoration: InputDecoration(labelText: 'Blood Group'),
                  ),
                  SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: _selectedStatus,
                    items: ['All', 'Available', 'Not Available', 'Suspended']
                        .map((status) => DropdownMenuItem(
                              value: status,
                              child: Text(status),
                            ))
                        .toList(),
                    onChanged: (value) => setState(() => _selectedStatus = value!),
                    decoration: InputDecoration(labelText: 'Status'),
                  ),
                ],
              )
            : Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedBloodGroup,
                      items: ['All', 'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-']
                          .map((group) => DropdownMenuItem(
                                value: group,
                                child: Text(group),
                              ))
                          .toList(),
                      onChanged: (value) => setState(() => _selectedBloodGroup = value!),
                      decoration: InputDecoration(labelText: 'Blood Group'),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedStatus,
                      items: ['All', 'Available', 'Not Available', 'Suspended']
                          .map((status) => DropdownMenuItem(
                                value: status,
                                child: Text(status),
                              ))
                          .toList(),
                      onChanged: (value) => setState(() => _selectedStatus = value!),
                      decoration: InputDecoration(labelText: 'Status'),
                    ),
                  ),
                ],
              ),
            SizedBox(height: 8),
            // Make search and date filter responsive
            isSmallScreen 
            ? Column(
                children: [
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'Search',
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: (value) => setState(() => _searchQuery = value),
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      ElevatedButton.icon(
                        icon: Icon(Icons.calendar_today),
                        label: Text('Select Dates'),
                        onPressed: () => showDialog(
                          context: context,
                          builder: (context) => _buildDateRangePicker(),
                        ),
                      ),
                      SizedBox(width: 8),
                      if (_startDate != null || _endDate != null)
                        Expanded(
                          child: Chip(
                            label: Text(
                              '${_startDate != null ? DateFormat('MMM d').format(_startDate!) : ''}'
                              '${_endDate != null ? ' - ${DateFormat('MMM d').format(_endDate!)}' : ''}',
                              overflow: TextOverflow.ellipsis,
                            ),
                            onDeleted: () => setState(() {
                              _startDate = null;
                              _endDate = null;
                            }),
                          ),
                        ),
                    ],
                  ),
                ],
              )
            : Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        labelText: 'Search',
                        prefixIcon: Icon(Icons.search),
                      ),
                      onChanged: (value) => setState(() => _searchQuery = value),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.calendar_today),
                    onPressed: () => showDialog(
                      context: context,
                      builder: (context) => _buildDateRangePicker(),
                    ),
                  ),
                  if (_startDate != null || _endDate != null)
                    Chip(
                      label: Text(
                        '${_startDate != null ? DateFormat('MMM d').format(_startDate!) : ''}'
                        '${_endDate != null ? ' - ${DateFormat('MMM d').format(_endDate!)}' : ''}',
                      ),
                      onDeleted: () => setState(() {
                        _startDate = null;
                        _endDate = null;
                      }),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDonorsList() {
    Query query = _firestore.collection('users').where('isDonor', isEqualTo: true);

    if (_selectedBloodGroup != 'All') {
      query = query.where('bloodGroup', isEqualTo: _selectedBloodGroup);
    }

    if (_selectedStatus != 'All') {
      if (_selectedStatus == 'Available') {
        query = query.where('isAvailable', isEqualTo: true);
      } else if (_selectedStatus == 'Not Available') {
        query = query.where('isAvailable', isEqualTo: false);
      } else if (_selectedStatus == 'Suspended') {
        query = query.where('accountStatus', isEqualTo: 'suspended');
      }
    }

    return StreamBuilder<QuerySnapshot>(
      stream: query.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        final allDonors = snapshot.data!.docs;
        
        final donors = _searchQuery.isEmpty 
            ? allDonors 
            : allDonors.where((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final name = (data['name'] ?? '').toString().toLowerCase();
                return name.contains(_searchQuery.toLowerCase());
              }).toList();

        return Expanded(
          child: ListView.builder(
            itemCount: donors.length,
            itemBuilder: (context, index) {
              final donor = donors[index];
              final data = donor.data() as Map<String, dynamic>;
              
              final bool isAvailable = data['isAvailable'] ?? false;
              final String accountStatus = data['accountStatus'] ?? 'active';
              final isSmallScreen = MediaQuery.of(context).size.width < 600;
              
              return Card(
                margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: ExpansionTile(
                  leading: CircleAvatar(
                    child: Text(data['bloodGroup'] ?? '?'),
                    backgroundColor: Colors.purple.withOpacity(0.2),
                  ),
                  title: Text(data['name'] ?? 'No Name'),
                  subtitle: Text(data['email'] ?? 'No Email'),
                  trailing: isSmallScreen
                      ? Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Chip(
                              label: Text(
                                isAvailable ? 'Available' : 'Not Available',
                                style: TextStyle(fontSize: 10),
                              ),
                              backgroundColor: isAvailable 
                                  ? Colors.green.withOpacity(0.2) 
                                  : Colors.orange.withOpacity(0.2),
                              padding: EdgeInsets.zero,
                              labelPadding: EdgeInsets.symmetric(horizontal: 4),
                            ),
                            if (accountStatus == 'suspended')
                              Chip(
                                label: Text('Suspended', style: TextStyle(fontSize: 10)),
                                backgroundColor: Colors.red.withOpacity(0.2),
                                padding: EdgeInsets.zero,
                                labelPadding: EdgeInsets.symmetric(horizontal: 4),
                              ),
                          ],
                        )
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Chip(
                              label: Text(isAvailable ? 'Available' : 'Not Available'),
                              backgroundColor: isAvailable 
                                  ? Colors.green.withOpacity(0.2) 
                                  : Colors.orange.withOpacity(0.2),
                            ),
                            SizedBox(width: 4),
                            if (accountStatus == 'suspended')
                              Chip(
                                label: Text('Suspended'),
                                backgroundColor: Colors.red.withOpacity(0.2),
                              ),
                          ],
                        ),
                  children: [
                    Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildInfoRow('Phone', data['phone'] ?? 'Not provided'),
                          _buildInfoRow('Location', '${data['city'] ?? ''}, ${data['state'] ?? ''}'),
                          _buildInfoRow('Total Donations', data['totalDonations']?.toString() ?? '0'),
                          _buildInfoRow('Last Donation', 
                              data['lastDonationDate'] != null 
                                  ? DateFormat('MMM d, y').format((data['lastDonationDate'] as Timestamp).toDate())
                                  : 'Never'),
                          SizedBox(height: 10),
                          // Make buttons stack vertically on small screens
                          isSmallScreen
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    ElevatedButton(
                                      child: Text('View Donation History'),
                                      onPressed: () => _showDonationHistory(donor.id, data['name']),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.deepPurple,
                                        foregroundColor: Colors.white,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    ElevatedButton(
                                      child: Text(isAvailable ? 'Set Not Available' : 'Set Available'),
                                      onPressed: () => _toggleDonorAvailability(donor.id, !isAvailable),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: isAvailable ? Colors.orange : Colors.green,
                                      ),
                                    ),
                                  ],
                                )
                              : Row(
                                  children: [
                                    ElevatedButton(
                                      child: Text('View Donation History'),
                                      onPressed: () => _showDonationHistory(donor.id, data['name']),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.deepPurple,
                                        foregroundColor: Colors.white,
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    ElevatedButton(
                                      child: Text(isAvailable ? 'Set Not Available' : 'Set Available'),
                                      onPressed: () => _toggleDonorAvailability(donor.id, !isAvailable),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: isAvailable ? Colors.orange : Colors.green,
                                      ),
                                    ),
                                  ],
                                ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _toggleDonorAvailability(String donorId, bool isAvailable) async {
    try {
      await _firestore.collection('users').doc(donorId).update({
        'isAvailable': isAvailable,
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Donor status updated successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating donor status: $e')),
      );
    }
  }

  Widget _buildReportsList() {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;
    
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(8),
          child: TextField(
            decoration: InputDecoration(
              labelText: 'Search Reports',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onChanged: (value) => setState(() => _searchQuery = value),
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: _firestore.collection('reports').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              final allReports = snapshot.data!.docs;
              
              final reports = _searchQuery.isEmpty 
                  ? allReports 
                  : allReports.where((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      final donorName = (data['donorName'] ?? '').toString().toLowerCase();
                      final reporterName = (data['reporterName'] ?? '').toString().toLowerCase();
                      final reason = (data['reportReason'] ?? '').toString().toLowerCase();
                      final query = _searchQuery.toLowerCase();
                      return donorName.contains(query) || 
                             reporterName.contains(query) || 
                             reason.contains(query);
                    }).toList();
              
              return ListView.builder(
                itemCount: reports.length,
                itemBuilder: (context, index) {
                  final report = reports[index];
                  final data = report.data() as Map<String, dynamic>;
                  
                  // Use reporterName directly instead of showing "Unknown"
                  final reporterName = data['reporterName'] ?? '';
                  
                  return Card(
                    margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(color: Colors.deepPurple.withOpacity(0.5), width: 1),
                    ),
                    child: isSmallScreen
                        // Different layout for small screens
                        ? Padding(
                            padding: EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.report_problem, color: Colors.deepPurple),
                                    SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        data['donorName'] ?? 'Unknown Donor',
                                        style: TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 4),
                                Text('Reported by: $reporterName'),
                                Text(
                                  'Reason: ${(data['reportReason'] ?? '').length > 50 
                                      ? '${data['reportReason'].substring(0, 50)}...' 
                                      : data['reportReason'] ?? 'No reason provided'}',
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                ),
                                SizedBox(height: 4),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    TextButton(
                                      child: Text('View Details'),
                                      onPressed: () => _showReportDetails(report.id, data),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          )
                        // Original layout for larger screens
                        : ListTile(
                            leading: Icon(Icons.report_problem, color: Colors.deepPurple),
                            title: Text(data['donorName'] ?? 'Unknown Donor'),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Reported by: $reporterName'),
                                Text('Reason: ${(data['reportReason'] ?? '').length > 50 
                                    ? '${data['reportReason'].substring(0, 50)}...' 
                                    : data['reportReason'] ?? 'No reason provided'}'),
                              ],
                            ),
                            onTap: () => _showReportDetails(report.id, data),
                          ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label: ', style: TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Future<void> _showDonationHistory(String userId, String userName) async {
    final donations = await _firestore.collection('users').doc(userId).collection('donations')
        .orderBy('timestamp', descending: true)
        .get();

    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$userName\'s Donation History'),
        content: SizedBox(
          width: double.maxFinite,
          height: MediaQuery.of(context).size.height * (isSmallScreen ? 0.5 : 0.6),
          child: donations.docs.isEmpty
              ? Center(child: Text('No donation history found'))
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: donations.docs.length,
                  itemBuilder: (context, index) {
                    final donation = donations.docs[index];
                    final data = donation.data();
                    final date = (data['timestamp'] as Timestamp?)?.toDate();
                    
                    return isSmallScreen
                        ? Padding(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  data['bloodBank'] ?? 'Unknown Location', 
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text('${data['amount']} units'),
                                Text('${date != null ? DateFormat('MMM d, y').format(date) : 'unknown date'}'),
                                Text('Blood Group: ${data['bloodGroup'] ?? '?'}'),
                                Divider(),
                              ],
                            ),
                          )
                        : ListTile(
                            title: Text(data['bloodBank'] ?? 'Unknown Location'),
                            subtitle: Text('${data['amount']} units on ${date != null ? DateFormat('MMM d, y').format(date) : 'unknown date'}'),
                            trailing: Text(data['bloodGroup'] ?? '?'),
                          );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
            style: TextButton.styleFrom(
              foregroundColor: Colors.deepPurple,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showReportDetails(String reportId, Map<String, dynamic> data) async {
    String donorId = data['donorId'] ?? '';
    Map<String, dynamic> donorData = {};
    
    if (donorId.isNotEmpty) {
      try {
        final donorDoc = await _firestore.collection('users').doc(donorId).get();
        if (donorDoc.exists) {
          donorData = donorDoc.data() ?? {};
        }
      } catch (e) {
        print('Error fetching donor details: $e');
      }
    }

    String reporterId = data['reporterId'] ?? '';
    Map<String, dynamic> reporterData = {};
    
    if (reporterId.isNotEmpty) {
      try {
        final reporterDoc = await _firestore.collection('users').doc(reporterId).get();
        if (reporterDoc.exists) {
          reporterData = reporterDoc.data() ?? {};
        }
      } catch (e) {
        print('Error fetching reporter details: $e');
      }
    }

    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Report Details'),
        titleTextStyle: TextStyle(
          color: Colors.deepPurple,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoRow('Reported Donor', data['donorName'] ?? 'Unknown'),
              _buildInfoRow('Blood Group', donorData['bloodGroup'] ?? 'Unknown'),
              _buildInfoRow('Email', donorData['email'] ?? 'Unknown'),
              _buildInfoRow('Phone', donorData['phone'] ?? 'Not provided'),
              
              Divider(height: 20),
              
              _buildInfoRow('Reporter', data['reporterName'] ?? reporterData['name'] ?? ''),
              _buildInfoRow('Reporter Email', reporterData['email'] ?? 'Unknown'),
              _buildInfoRow('Reporter Phone', reporterData['phone'] ?? 'Not provided'),
              
              Divider(height: 20),
              
              _buildInfoRow('Report Reason', data['reportReason'] ?? 'No reason provided'),
            ],
          ),
        ),
        actions: isSmallScreen 
            ? <Widget>[
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Close'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.deepPurple,
                  ),
                ),
                if (data['status'] == 'pending')
                  TextButton(
                    child: Text('Dismiss Report'),
                    onPressed: () => _updateReportStatus(reportId, 'dismissed'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.grey,
                    ),
                  ),
              ]
            : <Widget>[
                if (data['status'] == 'pending')
                  TextButton(
                    child: Text('Dismiss Report'),
                    onPressed: () => _updateReportStatus(reportId, 'dismissed'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.grey,
                    ),
                  ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Close'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.deepPurple,
                  ),
                ),
              ],
      ),
    );
  }

  Future<void> _updateReportStatus(String reportId, String status) async {
    try {
      await _firestore.collection('reports').doc(reportId).update({
        'status': status,
        'resolvedAt': FieldValue.serverTimestamp(),
        'resolvedBy': FirebaseAuth.instance.currentUser?.uid,
      });
      
      Navigator.pop(context);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Report marked as $status')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating report: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Blood Bank Administration',
          style: TextStyle(color: Colors.deepPurple),
        ),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.deepPurple),
        elevation: 0,
        automaticallyImplyLeading: false,
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Donors'),
            Tab(text: 'Reports'),
          ],
          labelColor: Colors.deepPurple,
          indicatorColor: Colors.deepPurple,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          Column(
            children: [
              _buildFilterBar(),
              Expanded(child: _buildDonorsList()),
            ],
          ),
          _buildReportsList(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.refresh),
        onPressed: () => setState(() {}),
        tooltip: 'Refresh data',
        backgroundColor: Colors.deepPurple,
      ),
    );
  }
}