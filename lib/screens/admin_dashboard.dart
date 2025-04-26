// screens/admin_dashboard.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../admin_screens/admin_blood_bank.dart';
import '../admin_screens/admin_medical_help.dart';
import '../admin_screens/admin_fundraising.dart';
import '../admin_screens/admin_user_handle.dart';

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
              AdminBloodBank(),
              AdminMedicalHelp(),
              AdminFundraising(),
              AdminUserHandle(),
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