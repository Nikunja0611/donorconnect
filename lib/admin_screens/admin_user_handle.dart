import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdminUserHandle extends StatefulWidget {
  @override
  _AdminUserHandleState createState() => _AdminUserHandleState();
}

class _AdminUserHandleState extends State<AdminUserHandle> {
  String? selectedUserId;
  bool isLoading = false;
  TextEditingController searchController = TextEditingController();
  String searchQuery = '';
  
  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;
    
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(16),
          child: isSmallScreen 
            ? Column(
                children: [
                  TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: 'Search by name or email',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value;
                      });
                    },
                  ),
                ],
              )
            : Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: searchController,
                      decoration: InputDecoration(
                        hintText: 'Search by name or email',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          searchQuery = value;
                        });
                      },
                    ),
                  ),
                ],
              ),
        ),
        Divider(),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('users').snapshots(),
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
                      Icon(Icons.people_outline, size: 80, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'No users found',
                        style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                      ),
                    ],
                  ),
                );
              }
              
              // Filter users based on search query
              var filteredDocs = snapshot.data!.docs.where((doc) {
                if (searchQuery.isEmpty) return true;
                
                var data = doc.data() as Map<String, dynamic>;
                String name = (data['name'] ?? '').toString().toLowerCase();
                String email = (data['email'] ?? '').toString().toLowerCase();
                
                return name.contains(searchQuery.toLowerCase()) || 
                       email.contains(searchQuery.toLowerCase());
              }).toList();
              
              if (filteredDocs.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search_off, size: 80, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'No users matching "$searchQuery"',
                        style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                      ),
                    ],
                  ),
                );
              }
              
              return ListView.builder(
                padding: EdgeInsets.all(12),
                itemCount: filteredDocs.length,
                itemBuilder: (context, index) {
                  var doc = filteredDocs[index];
                  var data = doc.data() as Map<String, dynamic>;
                  
                  String name = data['name'] ?? 'Unknown';
                  String email = data['email'] ?? 'No email';
                  String phone = data['phone'] ?? 'No phone';
                  bool isAdmin = data['isAdmin'] ?? false;
                  
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 8),
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        setState(() {
                          selectedUserId = doc.id;
                        });
                        _showUserDetails(context, doc.id, data);
                      },
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: isSmallScreen
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: isAdmin ? primaryColor : Colors.grey[300],
                                      child: Icon(
                                        isAdmin ? Icons.admin_panel_settings : Icons.person,
                                        color: isAdmin ? Colors.white : Colors.grey[700],
                                      ),
                                    ),
                                    SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  name,
                                                  style: TextStyle(fontWeight: FontWeight.bold),
                                                ),
                                              ),
                                              if (isAdmin)
                                                Container(
                                                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                                  decoration: BoxDecoration(
                                                    color: primaryColor.withOpacity(0.2),
                                                    borderRadius: BorderRadius.circular(12),
                                                  ),
                                                  child: Text(
                                                    'Admin',
                                                    style: TextStyle(
                                                      color: primaryColor,
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                          SizedBox(height: 4),
                                          Row(
                                            children: [
                                              Icon(Icons.email, size: 16, color: Colors.grey[600]),
                                              SizedBox(width: 4),
                                              Expanded(child: Text(email, overflow: TextOverflow.ellipsis)),
                                            ],
                                          ),
                                          SizedBox(height: 4),
                                          Row(
                                            children: [
                                              Icon(Icons.phone, size: 16, color: Colors.grey[600]),
                                              SizedBox(width: 4),
                                              Text(phone),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    TextButton.icon(
                                      icon: Icon(Icons.edit, size: 18),
                                      label: Text('Edit'),
                                      style: TextButton.styleFrom(
                                        foregroundColor: Colors.blue,
                                      ),
                                      onPressed: () => _showEditUserDialog(context, doc.id, data),
                                    ),
                                    SizedBox(width: 8),
                                    TextButton.icon(
                                      icon: Icon(Icons.delete, size: 18),
                                      label: Text('Delete'),
                                      style: TextButton.styleFrom(
                                        foregroundColor: Colors.red,
                                      ),
                                      onPressed: () => _showDeleteConfirmation(context, doc.id, name),
                                    ),
                                  ],
                                ),
                              ],
                            )
                          : Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: isAdmin ? primaryColor : Colors.grey[300],
                                  child: Icon(
                                    isAdmin ? Icons.admin_panel_settings : Icons.person,
                                    color: isAdmin ? Colors.white : Colors.grey[700],
                                  ),
                                ),
                                SizedBox(width: 16),
                                Expanded(
                                  flex: 3,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              name,
                                              style: TextStyle(fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                          if (isAdmin)
                                            Container(
                                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: primaryColor.withOpacity(0.2),
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              child: Text(
                                                'Admin',
                                                style: TextStyle(
                                                  color: primaryColor,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                      SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Icon(Icons.email, size: 16, color: Colors.grey[600]),
                                          SizedBox(width: 4),
                                          Expanded(child: Text(email)),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Row(
                                    children: [
                                      Icon(Icons.phone, size: 16, color: Colors.grey[600]),
                                      SizedBox(width: 4),
                                      Expanded(child: Text(phone)),
                                    ],
                                  ),
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.edit, color: Colors.blue),
                                      tooltip: 'Edit User',
                                      onPressed: () => _showEditUserDialog(context, doc.id, data),
                                    ),
                                    SizedBox(width: 8),
                                    IconButton(
                                      icon: Icon(Icons.delete, color: Colors.red),
                                      tooltip: 'Delete User',
                                      onPressed: () => _showDeleteConfirmation(context, doc.id, name),
                                    ),
                                  ],
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
      ],
    );
  }
  
  void _showUserDetails(BuildContext context, String userId, Map<String, dynamic> userData) {
    final primaryColor = Theme.of(context).primaryColor;
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 600;
    
    String name = userData['name'] ?? 'Unknown';
    String email = userData['email'] ?? 'No email';
    String phone = userData['phone'] ?? 'No phone';
    String address = userData['address'] ?? 'No address';
    bool isAdmin = userData['isAdmin'] ?? false;
    
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: isSmallScreen ? screenSize.width * 0.9 : 500,
              maxHeight: screenSize.height * 0.8,
            ),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'User Details',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Spacer(),
                      IconButton(
                        icon: Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  Divider(),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Center(
                            child: CircleAvatar(
                              radius: 40,
                              backgroundColor: isAdmin ? primaryColor : Colors.grey[300],
                              child: Icon(
                                isAdmin ? Icons.admin_panel_settings : Icons.person,
                                size: 40,
                                color: isAdmin ? Colors.white : Colors.grey[700],
                              ),
                            ),
                          ),
                          SizedBox(height: 16),
                          _buildDetailRow('Name', name),
                          _buildDetailRow('Email', email),
                          _buildDetailRow('Phone', phone),
                          _buildDetailRow('Address', address),
                          _buildDetailRow('Admin Status', isAdmin ? 'Admin' : 'Regular User'),
                          
                          // Activity summary
                          SizedBox(height: 16),
                          Text(
                            'Activity Summary',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: primaryColor,
                            ),
                          ),
                          SizedBox(height: 8),
                          FutureBuilder<QuerySnapshot>(
                            future: FirebaseFirestore.instance.collection('blood_donations')
                              .where('donorId', isEqualTo: userId)
                              .get(),
                            builder: (context, donationSnapshot) {
                              int donationCount = donationSnapshot.hasData 
                                ? donationSnapshot.data!.docs.length 
                                : 0;
                              
                              return FutureBuilder<QuerySnapshot>(
                                future: FirebaseFirestore.instance.collection('medical_help')
                                  .where('requesterId', isEqualTo: userId)
                                  .get(),
                                builder: (context, medicalSnapshot) {
                                  int medicalRequestCount = medicalSnapshot.hasData 
                                    ? medicalSnapshot.data!.docs.length 
                                    : 0;
                                  
                                  return Column(
                                    children: [
                                      _buildActivityItem('Blood Donations', donationCount, Icons.favorite),
                                      _buildActivityItem('Medical Help Requests', medicalRequestCount, Icons.medical_services),
                                    ],
                                  );
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  Divider(),
                  Wrap(
                    spacing: 8,
                    alignment: WrapAlignment.end,
                    children: [
                      TextButton(
                        child: Text('Edit'),
                        onPressed: () {
                          Navigator.pop(context);
                          _showEditUserDialog(context, userId, userData);
                        },
                      ),
                      TextButton(
                        child: Text(isAdmin ? 'Remove Admin' : 'Make Admin'),
                        style: TextButton.styleFrom(
                          foregroundColor: isAdmin ? Colors.red : Colors.green,
                        ),
                        onPressed: () async {
                          Navigator.pop(context);
                          await _toggleAdminStatus(userId, !isAdmin);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
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
  
  Widget _buildActivityItem(String label, int count, IconData icon) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          SizedBox(width: 8),
          Text(label, style: TextStyle(color: Colors.grey[700])),
          Spacer(),
          Text(
            count.toString(),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: count > 0 ? Colors.black : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
  
  Future<void> _toggleAdminStatus(String userId, bool makeAdmin) async {
    setState(() {
      isLoading = true;
    });
    
    try {
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'isAdmin': makeAdmin,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(makeAdmin 
            ? 'User has been given admin privileges' 
            : 'Admin privileges have been removed')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating admin status: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }
  
  void _showEditUserDialog(BuildContext context, String userId, Map<String, dynamic> userData) {
    final nameController = TextEditingController(text: userData['name'] ?? '');
    final emailController = TextEditingController(text: userData['email'] ?? '');
    final phoneController = TextEditingController(text: userData['phone'] ?? '');
    final addressController = TextEditingController(text: userData['address'] ?? '');
    bool isAdmin = userData['isAdmin'] ?? false;
    
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 600;
    
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: isSmallScreen ? screenSize.width * 0.9 : 500,
                  maxHeight: screenSize.height * 0.8,
                ),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Edit User',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Spacer(),
                          IconButton(
                            icon: Icon(Icons.close),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                      Divider(),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextField(
                                controller: nameController,
                                decoration: InputDecoration(
                                  labelText: 'Full Name',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                              SizedBox(height: 16),
                              TextField(
                                controller: emailController,
                                decoration: InputDecoration(
                                  labelText: 'Email',
                                  border: OutlineInputBorder(),
                                ),
                                keyboardType: TextInputType.emailAddress,
                                readOnly: true, // Email can't be changed once set
                              ),
                              SizedBox(height: 16),
                              TextField(
                                controller: phoneController,
                                decoration: InputDecoration(
                                  labelText: 'Phone Number',
                                  border: OutlineInputBorder(),
                                ),
                                keyboardType: TextInputType.phone,
                              ),
                              SizedBox(height: 16),
                              TextField(
                                controller: addressController,
                                decoration: InputDecoration(
                                  labelText: 'Address',
                                  border: OutlineInputBorder(),
                                ),
                                maxLines: 2,
                              ),
                              SizedBox(height: 16),
                              SwitchListTile(
                                title: Text('Admin User'),
                                value: isAdmin,
                                onChanged: (value) {
                                  setState(() {
                                    isAdmin = value;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      Divider(),
                      Wrap(
                        spacing: 8,
                        alignment: WrapAlignment.end,
                        children: [
                          TextButton(
                            child: Text('Cancel'),
                            onPressed: () => Navigator.pop(context),
                          ),
                          TextButton(
                            child: Text('Reset Password'),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.orange,
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                              _showResetPasswordDialog(context, userData['email'] ?? '');
                            },
                          ),
                          ElevatedButton(
                            child: Text('Save Changes'),
                            onPressed: () async {
                              if (nameController.text.isEmpty || 
                                  phoneController.text.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Please fill all required fields')),
                                );
                                return;
                              }
                              
                              try {
                                await FirebaseFirestore.instance.collection('users').doc(userId).update({
                                  'name': nameController.text,
                                  'phone': phoneController.text,
                                  'address': addressController.text,
                                  'isAdmin': isAdmin,
                                  'updatedAt': FieldValue.serverTimestamp(),
                                });
                                
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('User updated successfully')),
                                );
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Error updating user: $e')),
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
  
  void _showResetPasswordDialog(BuildContext context, String email) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 600;
    
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: isSmallScreen ? screenSize.width * 0.8 : 400,
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Reset Password',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text('Send password reset email to $email?'),
                  SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        child: Text('Cancel'),
                        onPressed: () => Navigator.pop(context),
                      ),
                      SizedBox(width: 8),
                      ElevatedButton(
                        child: Text('Send Email'),
                        onPressed: () async {
                          try {
                            await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Password reset email sent')),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error sending password reset: $e')),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
  
  void _showDeleteConfirmation(BuildContext context, String userId, String userName) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 600;
    
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: isSmallScreen ? screenSize.width * 0.8 : 400,
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Delete User',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Are you sure you want to delete $userName? This action cannot be undone.',
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        child: Text('Cancel'),
                        onPressed: () => Navigator.pop(context),
                      ),
                      SizedBox(width: 8),
                      ElevatedButton(
                        child: Text('Delete'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () async {
                          try {
                            // In a real app, you would need admin SDK or Cloud Functions to delete users from Auth
                            // For now, we'll just delete from Firestore
                            await FirebaseFirestore.instance.collection('users').doc(userId).delete();
                            
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('User deleted successfully')),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error deleting user: $e')),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}