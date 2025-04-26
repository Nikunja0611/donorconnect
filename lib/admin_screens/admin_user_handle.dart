// screens/admin_screens/admin_user_handle.dart
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
    
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(16),
          child: Row(
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
              SizedBox(width: 16),
              ElevatedButton.icon(
                icon: Icon(Icons.add),
                label: Text('Add User'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                ),
                onPressed: () => _showAddUserDialog(context),
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
                    child: ListTile(
                      contentPadding: EdgeInsets.all(16),
                      leading: CircleAvatar(
                        backgroundColor: isAdmin ? primaryColor : Colors.grey[300],
                        child: Icon(
                          isAdmin ? Icons.admin_panel_settings : Icons.person,
                          color: isAdmin ? Colors.white : Colors.grey[700],
                        ),
                      ),
                      title: Row(
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
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.email, size: 16, color: Colors.grey[600]),
                              SizedBox(width: 4),
                              Expanded(child: Text(email)),
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
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => _showEditUserDialog(context, doc.id, data),
                          ),
                          SizedBox(width: 8),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            // Continuing admin_user_handle.dart
                            onPressed: () => _showDeleteConfirmation(context, doc.id, name),
                          ),
                        ],
                      ),
                      onTap: () {
                        setState(() {
                          selectedUserId = doc.id;
                        });
                        _showUserDetails(context, doc.id, data);
                      },
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
    
    String name = userData['name'] ?? 'Unknown';
    String email = userData['email'] ?? 'No email';
    String phone = userData['phone'] ?? 'No phone';
    String address = userData['address'] ?? 'No address';
    bool isAdmin = userData['isAdmin'] ?? false;
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('User Details'),
          content: SingleChildScrollView(
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
                    int donationCount = donationSnapshot.hasData ? donationSnapshot.data!.docs.length : 0;
                    
                    return FutureBuilder<QuerySnapshot>(
                      future: FirebaseFirestore.instance.collection('medical_help')
                        .where('requesterId', isEqualTo: userId)
                        .get(),
                      builder: (context, medicalSnapshot) {
                        int medicalRequestCount = medicalSnapshot.hasData ? medicalSnapshot.data!.docs.length : 0;
                        
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
  
  void _showAddUserDialog(BuildContext context) {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();
    final addressController = TextEditingController();
    final passwordController = TextEditingController();
    bool isAdmin = false;
    
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Add New User'),
              content: SingleChildScrollView(
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
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: passwordController,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        border: OutlineInputBorder(),
                      ),
                      obscureText: true,
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
              actions: [
                TextButton(
                  child: Text('Cancel'),
                  onPressed: () => Navigator.pop(context),
                ),
                ElevatedButton(
                  child: Text('Add User'),
                  onPressed: () async {
                    if (nameController.text.isEmpty || 
                        emailController.text.isEmpty || 
                        passwordController.text.isEmpty ||
                        phoneController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Please fill all required fields')),
                      );
                      return;
                    }
                    
                    try {
                      // First create the user account in Firebase Auth
                      final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
                        email: emailController.text.trim(),
                        password: passwordController.text,
                      );
                      
                      // Then add the user data to Firestore
                      await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
                        'name': nameController.text,
                        'email': emailController.text.trim(),
                        'phone': phoneController.text,
                        'address': addressController.text,
                        'isAdmin': isAdmin,
                        'createdAt': FieldValue.serverTimestamp(),
                        'updatedAt': FieldValue.serverTimestamp(),
                      });
                      
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('User added successfully')),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error adding user: $e')),
                      );
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }
  
  void _showEditUserDialog(BuildContext context, String userId, Map<String, dynamic> userData) {
    final nameController = TextEditingController(text: userData['name'] ?? '');
    final emailController = TextEditingController(text: userData['email'] ?? '');
    final phoneController = TextEditingController(text: userData['phone'] ?? '');
    final addressController = TextEditingController(text: userData['address'] ?? '');
    bool isAdmin = userData['isAdmin'] ?? false;
    
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Edit User'),
              content: SingleChildScrollView(
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
              actions: [
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
            );
          },
        );
      },
    );
  }
  
  void _showResetPasswordDialog(BuildContext context, String email) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Reset Password'),
          content: Text('Send password reset email to $email?'),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.pop(context),
            ),
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
        );
      },
    );
  }
  
  void _showDeleteConfirmation(BuildContext context, String userId, String userName) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Delete User'),
          content: Text('Are you sure you want to delete $userName? This action cannot be undone.'),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.pop(context),
            ),
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
        );
      },
    );
  }
}
                          