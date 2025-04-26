// screens/admin_dashboard.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';

class AdminDashboard extends StatefulWidget {
  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String adminName = "Admin";
  bool isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadAdminData();
  }
  
  Future<void> _loadAdminData() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final userData = await authService.getCurrentUserData();
    
    if (userData != null && userData.containsKey('name')) {
      setState(() {
        adminName = userData['name'];
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacementNamed(context, '/admin_login');
  }

  
  @override
  Widget build(BuildContext context) {
    // Check if user is authenticated and is admin
    final User? currentUser = FirebaseAuth.instance.currentUser;
    
    if (currentUser == null) {
      // Not authenticated, redirect to login
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/admin_login');
      });
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    
    // Verify admin status
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('users').doc(currentUser.uid).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        
        if (!snapshot.hasData || snapshot.data == null || 
            !(snapshot.data!.data() as Map<String, dynamic>)['isAdmin']) {
          // Not an admin, redirect to login
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Admin access required')),
            );
            Navigator.pushReplacementNamed(context, '/admin_login');
          });
          return Scaffold(body: Center(child: Text('Admin access required')));
        }
        
        // User is authenticated and is admin - show original dashboard
        final primaryColor = Theme.of(context).primaryColor;
        
        return Scaffold(
          appBar: AppBar(
            backgroundColor: primaryColor,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Admin Dashboard'),
                if (!isLoading) Text(adminName, style: TextStyle(fontSize: 14)),
              ],
            ),
            actions: [
              IconButton(icon: Icon(Icons.logout), onPressed: _signOut),
            ],
            bottom: TabBar(
              controller: _tabController,
              indicatorColor: Colors.white,
              tabs: [
                Tab(text: 'Blood Donations', icon: Icon(Icons.favorite)),
                Tab(text: 'Medical Help', icon: Icon(Icons.medical_services)),
                Tab(text: 'Fundraising', icon: Icon(Icons.attach_money)),
                Tab(text: 'Users', icon: Icon(Icons.people)),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              BloodDonationsTab(),
              MedicalHelpTab(),
              FundraisingTab(),
              UsersTab(),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            backgroundColor: primaryColor,
            child: Icon(Icons.add),
            onPressed: () {
              // Show action based on current tab
              final currentTab = _tabController.index;
              String action = "";
              
              switch(currentTab) {
                case 0: action = "Add New Blood Donation"; break;
                case 1: action = "Add Medical Help Request"; break;
                case 2: action = "Create Fundraising Campaign"; break;
                case 3: action = "Add New User"; break;
              }
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Action: $action')),
              );
            },
          ),
        );
      },
    );
  }
}

class BloodDonationsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('blood_donations').snapshots(),
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
                  Icons.favorite_border,
                  size: 80,
                  color: Colors.grey,
                ),
                SizedBox(height: 16),
                Text(
                  'No blood donation records found',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(height: 24),
                ElevatedButton.icon(
                  icon: Icon(Icons.add),
                  label: Text('Add First Donation'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Add First Donation')),
                    );
                  },
                ),
              ],
            ),
          );
        }
        
        return ListView.builder(
          padding: EdgeInsets.all(12),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            var doc = snapshot.data!.docs[index];
            var data = doc.data() as Map<String, dynamic>;
            String donorName = data['donorName'] ?? 'Unknown Donor';
            String bloodType = data['bloodType'] ?? 'Unknown';
            String donationDate = data['donationDate'] ?? 'N/A';
            String status = data['status'] ?? 'Pending';
            
            Color statusColor;
            switch (status.toLowerCase()) {
              case 'completed':
                statusColor = Colors.green;
                break;
              case 'pending':
                statusColor = Colors.orange;
                break;
              case 'cancelled':
                statusColor = Colors.red;
                break;
              default:
                statusColor = Colors.grey;
            }
            
            return Card(
              margin: EdgeInsets.symmetric(vertical: 8),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                leading: CircleAvatar(
                  backgroundColor: primaryColor.withOpacity(0.2),
                  child: Text(
                    bloodType,
                    style: TextStyle(
                      color: primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(
                  donorName,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text('Date: $donationDate'),
                trailing: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                onTap: () {
                  // Show detailed view or edit options
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('Donation Details'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildDetailRow('Donor', donorName),
                          _buildDetailRow('Blood Type', bloodType),
                          _buildDetailRow('Date', donationDate),
                          _buildDetailRow('Status', status),
                          // Add more details here
                        ],
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
                            // Show edit screen
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            );
          },
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
}

class MedicalHelpTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('medical_help').snapshots(),
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
                  'No medical help records found',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          );
        }
        
        return ListView.builder(
          padding: EdgeInsets.all(12),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            var data = snapshot.data!.docs[index].data() as Map<String, dynamic>;
            return Card(
              margin: EdgeInsets.symmetric(vertical: 8),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                leading: CircleAvatar(
                  backgroundColor: primaryColor.withOpacity(0.2),
                  child: Icon(
                    Icons.medical_services,
                    color: primaryColor,
                  ),
                ),
                title: Text(
                  data['patientName'] ?? 'Unknown Patient',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text('Equipment: ${data['equipmentNeeded'] ?? 'N/A'} • Priority: ${data['priority'] ?? 'Normal'}'),
                trailing: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(data['status']).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    data['status'] ?? 'Pending',
                    style: TextStyle(
                      color: _getStatusColor(data['status']),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                onTap: () {
                  // Show detailed view or edit options
                },
              ),
            );
          },
        );
      },
    );
  }
  
  Color _getStatusColor(String? status) {
    if (status == null) return Colors.grey;
    
    switch (status.toLowerCase()) {
      case 'resolved':
        return Colors.green;
      case 'in progress':
        return Colors.blue;
      case 'pending':
        return Colors.orange;
      case 'critical':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

class FundraisingTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('fundraising_campaigns').snapshots(),
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
                  Icons.attach_money_outlined,
                  size: 80,
                  color: Colors.grey,
                ),
                SizedBox(height: 16),
                Text(
                  'No fundraising campaigns found',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(height: 24),
                ElevatedButton.icon(
                  icon: Icon(Icons.add),
                  label: Text('Create Campaign'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Create Fundraising Campaign')),
                    );
                  },
                ),
              ],
            ),
          );
        }
        
        return ListView.builder(
          padding: EdgeInsets.all(12),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            var doc = snapshot.data!.docs[index];
            var data = doc.data() as Map<String, dynamic>;
            
            String title = data['title'] ?? 'Untitled Campaign';
            double target = (data['targetAmount'] ?? 0).toDouble();
            double current = (data['currentAmount'] ?? 0).toDouble();
            String endDate = data['endDate'] ?? 'No end date';
            
            // Calculate progress percentage
            double progressPercentage = target > 0 ? (current / target * 100).clamp(0, 100) : 0;
            
            return Card(
              margin: EdgeInsets.symmetric(vertical: 8),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
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
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getCampaignStatusColor(data['status']).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            data['status'] ?? 'Active',
                            style: TextStyle(
                              color: _getCampaignStatusColor(data['status']),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Text('End Date: $endDate'),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: progressPercentage / 100,
                              backgroundColor: Colors.grey[200],
                              color: primaryColor,
                              minHeight: 10,
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
                        Text(
                          '${progressPercentage.toStringAsFixed(1)}%',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Rs. ${current.toStringAsFixed(2)} raised of Rs. ${target.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton.icon(
                          icon: Icon(Icons.edit, size: 18),
                          label: Text('Edit'),
                          onPressed: () {
                            // Edit campaign logic
                          },
                        ),
                        SizedBox(width: 8),
                        TextButton.icon(
                          icon: Icon(Icons.visibility, size: 18),
                          label: Text('View Details'),
                          onPressed: () {
                            // View campaign details
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
  
  Color _getCampaignStatusColor(String? status) {
    if (status == null) return Colors.blue;
    
    switch (status.toLowerCase()) {
      case 'active':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'expired':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

// Update the UsersTab class in screens/admin_dashboard.dart
class UsersTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('users').snapshots(),
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
                  Icons.people_outline,
                  size: 80,
                  color: Colors.grey,
                ),
                SizedBox(height: 16),
                Text(
                  'No users found',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(height: 24),
                ElevatedButton.icon(
                  icon: Icon(Icons.add),
                  label: Text('Add User'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    _showAddUserDialog(context);
                  },
                ),
              ],
            ),
          );
        }
        
        return ListView.builder(
          padding: EdgeInsets.all(12),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            var doc = snapshot.data!.docs[index];
            var data = doc.data() as Map<String, dynamic>;
            
            String name = data['name'] ?? 'Unknown User';
            String email = data['email'] ?? 'No email';
            String bloodType = data['bloodType'] ?? data['bloodGroup'] ?? 'Unknown';
            bool isAdmin = data['isAdmin'] == true;
            
            return Card(
              margin: EdgeInsets.symmetric(vertical: 8),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                leading: CircleAvatar(
                  backgroundColor: isAdmin ? Colors.amber[100] : primaryColor.withOpacity(0.2),
                  child: Text(
                    name.isNotEmpty ? name[0].toUpperCase() : '?',
                    style: TextStyle(
                      color: isAdmin ? Colors.amber[800] : primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Row(
                  children: [
                    Text(
                      name,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    if (isAdmin)
                      Container(
                        margin: EdgeInsets.only(left: 8),
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.amber[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Admin',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.amber[800],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(email),
                    SizedBox(height: 4),
                    Text('Blood Type: $bloodType'),
                  ],
                ),
                trailing: PopupMenuButton(
                  icon: Icon(Icons.more_vert),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'view',
                      child: Text('View Details'),
                    ),
                    PopupMenuItem(
                      value: 'edit',
                      child: Text('Edit User'),
                    ),
                    PopupMenuItem(
                      value: isAdmin ? 'removeAdmin' : 'makeAdmin',
                      child: Text(isAdmin ? 'Remove Admin' : 'Make Admin'),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Text('Delete User'),
                    ),
                  ],
                  onSelected: (value) {
                    switch (value) {
                      case 'view':
                        _showUserDetailsDialog(context, doc.id, data);
                        break;
                      case 'edit':
                        _showEditUserDialog(context, doc.id, data);
                        break;
                      case 'makeAdmin':
                        // Make user admin
                        FirebaseFirestore.instance
                            .collection('users')
                            .doc(doc.id)
                            .update({'isAdmin': true})
                            .then((_) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('$name is now an admin')),
                              );
                            });
                        break;
                      case 'removeAdmin':
                        // Remove admin status
                        FirebaseFirestore.instance
                            .collection('users')
                            .doc(doc.id)
                            .update({'isAdmin': false})
                            .then((_) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Admin status removed from $name')),
                              );
                            });
                        break;
                      case 'delete':
                        // Show confirmation dialog before deleting
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text('Delete User'),
                            content: Text('Are you sure you want to delete $name?'),
                            actions: [
                              TextButton(
                                child: Text('Cancel'),
                                onPressed: () => Navigator.pop(context),
                              ),
                              TextButton(
                                child: Text('Delete', style: TextStyle(color: Colors.red)),
                                onPressed: () {
                                  Navigator.pop(context);
                                  // Delete user logic here
                                  FirebaseFirestore.instance
                                      .collection('users')
                                      .doc(doc.id)
                                      .delete()
                                      .then((_) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text('User deleted successfully')),
                                        );
                                      });
                                },
                              ),
                            ],
                          ),
                        );
                        break;
                    }
                  },
                ),
                onTap: () {
                  // Show user details when tapping on the card
                  _showUserDetailsDialog(context, doc.id, data);
                },
              ),
            );
          },
        );
      },
    );
  }
  
  // Function to show user details dialog
  void _showUserDetailsDialog(BuildContext context, String userId, Map<String, dynamic> userData) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('User Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildUserDetailRow('Name', userData['name'] ?? 'N/A'),
              _buildUserDetailRow('Email', userData['email'] ?? 'N/A'),
              _buildUserDetailRow('Phone', userData['phone'] ?? 'N/A'),
              _buildUserDetailRow('Address', userData['address'] ?? 'N/A'),
              _buildUserDetailRow('Date of Birth', userData['dob'] ?? 'N/A'),
              _buildUserDetailRow('Blood Group', userData['bloodGroup'] ?? userData['bloodType'] ?? 'N/A'),
              _buildUserDetailRow('Admin Status', userData['isAdmin'] == true ? 'Admin' : 'Regular User'),
              _buildUserDetailRow('Donor Status', userData['isDonor'] == true ? 'Donor' : 'Not a Donor'),
              if (userData['createdAt'] != null)
                _buildUserDetailRow('Account Created', userData['createdAt'].toDate().toString()),
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
              _showEditUserDialog(context, userId, userData);
            },
          ),
        ],
      ),
    );
  }
  
  // Helper method to build detail rows
  Widget _buildUserDetailRow(String label, String value) {
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
  
  // Function to show edit user dialog
  void _showEditUserDialog(BuildContext context, String userId, Map<String, dynamic> userData) {
    final nameController = TextEditingController(text: userData['name'] ?? '');
    final emailController = TextEditingController(text: userData['email'] ?? '');
    final phoneController = TextEditingController(text: userData['phone'] ?? '');
    final addressController = TextEditingController(text: userData['address'] ?? '');
    final dobController = TextEditingController(text: userData['dob'] ?? '');
    final bloodGroupController = TextEditingController(text: userData['bloodGroup'] ?? userData['bloodType'] ?? '');
    
    bool isAdmin = userData['isAdmin'] == true;
    bool isDonor = userData['isDonor'] == true;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit User'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 12),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: 12),
              TextField(
                controller: phoneController,
                decoration: InputDecoration(
                  labelText: 'Phone',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
              ),
              SizedBox(height: 12),
              TextField(
                controller: addressController,
                decoration: InputDecoration(
                  labelText: 'Address',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              SizedBox(height: 12),
              TextField(
                controller: dobController,
                decoration: InputDecoration(
                  labelText: 'Date of Birth',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                readOnly: true,
                onTap: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) {
                    dobController.text = "${picked.day}/${picked.month}/${picked.year}";
                  }
                },
              ),
              SizedBox(height: 12),
              TextField(
                controller: bloodGroupController,
                decoration: InputDecoration(
                  labelText: 'Blood Group',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: CheckboxListTile(
                      title: Text('Admin'),
                      value: isAdmin,
                      onChanged: (value) {
                        isAdmin = value ?? false;
                      },
                    ),
                  ),
                  Expanded(
                    child: CheckboxListTile(
                      title: Text('Donor'),
                      value: isDonor,
                      onChanged: (value) {
                        isDonor = value ?? false;
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            child: Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: Text('Save'),
            onPressed: () {
              // Update user data in Firestore
              FirebaseFirestore.instance.collection('users').doc(userId).update({
                'name': nameController.text,
                'email': emailController.text,
                'phone': phoneController.text,
                'address': addressController.text,
                'dob': dobController.text,
                'bloodGroup': bloodGroupController.text,
                'isAdmin': isAdmin,
                'isDonor': isDonor,
              }).then((_) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('User updated successfully')),
                );
              }).catchError((error) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error updating user: $error')),
                );
              });
            },
          ),
        ],
      ),
    );
  }

  // Function to show add user dialog
  void _showAddUserDialog(BuildContext context) {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final phoneController = TextEditingController();
    final addressController = TextEditingController();
    final dobController = TextEditingController();
    final bloodGroupController = TextEditingController();
    
    bool isAdmin = false;
    bool isDonor = false;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add New User'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 12),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: 12),
              TextField(
                controller: passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              SizedBox(height: 12),
              TextField(
                controller: phoneController,
                decoration: InputDecoration(
                  labelText: 'Phone',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
              ),
              SizedBox(height: 12),
              TextField(
                controller: addressController,
                decoration: InputDecoration(
                  labelText: 'Address',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              SizedBox(height: 12),
              TextField(
                controller: dobController,
                decoration: InputDecoration(
                  labelText: 'Date of Birth',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                readOnly: true,
                onTap: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) {
                    dobController.text = "${picked.day}/${picked.month}/${picked.year}";
                  }
                },
              ),
              SizedBox(height: 12),
              TextField(
                controller: bloodGroupController,
                decoration: InputDecoration(
                  labelText: 'Blood Group',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: CheckboxListTile(
                      title: Text('Admin'),
                      value: isAdmin,
                      onChanged: (value) {
                        isAdmin = value ?? false;
                      },
                    ),
                  ),
                  Expanded(
                    child: CheckboxListTile(
                      title: Text('Donor'),
                      value: isDonor,
                      onChanged: (value) {
                        isDonor = value ?? false;
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            child: Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: Text('Add User'),
            onPressed: () async {
              try {
                // Create user with Firebase Authentication
                final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
                  email: emailController.text,
                  password: passwordController.text,
                );
                
                // Add user data to Firestore
                await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
                  'name': nameController.text,
                  'email': emailController.text,
                  'phone': phoneController.text,
                  'address': addressController.text,
                  'dob': dobController.text,
                  'bloodGroup': bloodGroupController.text,
                  'isAdmin': isAdmin,
                  'isDonor': isDonor,
                  'createdAt': FieldValue.serverTimestamp(),
                });
                
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('User added successfully')),
                );
              } catch (error) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error adding user: $error')),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}