import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import 'donation_history_page.dart';

class ProfilePage extends StatefulWidget {
  @override
  ProfilePageState createState() => ProfilePageState();
}

class ProfilePageState extends State<ProfilePage> {
  bool _isLoading = true;
  Map<String, dynamic>? _userData;
  
  // Current index for bottom navigation - set to 4 for Profile
  int _currentIndex = 4;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final userData = await authService.getCurrentUserData();
    
    setState(() {
      _userData = userData;
      _isLoading = false;
    });
  }

  Future<void> _signOut() async {
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      await authService.signOut();
      Navigator.pushReplacementNamed(context, '/login');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error signing out")),
      );
    }
  }

  // Navigation bar tab handling
  void _onTabTapped(int index) {
    if (index == _currentIndex) return; // No need to navigate if already on the tab
    
    setState(() {
      _currentIndex = index;
    });
    
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/home_screen');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/medical_help_page');
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/blood_bank_page');
        break;
      case 3:
        Navigator.pushReplacementNamed(context, '/fundraising_page');
        break;
      case 4:
        // We're already on profile page, no need to navigate
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions for responsive layouts
    final Size screenSize = MediaQuery.of(context).size;
    final bool isTablet = screenSize.width > 600;
    
    return Scaffold(
      backgroundColor: Color(0xFFF8ECF1),
      appBar: AppBar(
        backgroundColor: Color(0xFFD95373),
        title: Text('Profile',  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    height: 1.1,),),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => _showSignOutDialog(),
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: Color(0xFFC14465)))
          : _userData == null
              ? Center(child: Text("No user data found"))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _buildProfileHeader(),
                      SizedBox(height: 20),
                      _buildProfileDetails(),
                      SizedBox(height: 30),
                      _buildActionButtons(),
                    ],
                  ),
                ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.pink[700],
        unselectedItemColor: Colors.pink[300],
        type: BottomNavigationBarType.fixed,
        onTap: _onTabTapped,
        items: [
          const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: const Icon(Icons.medical_services), 
              label: isTablet ? 'Medical Help' : 'Medical'),
          const BottomNavigationBarItem(
              icon: Icon(Icons.opacity), label: 'Blood Bank'),
          BottomNavigationBarItem(
              icon: const Icon(Icons.volunteer_activism), 
              label: isTablet ? 'Fundraising' : 'Fundraising'),
          const BottomNavigationBarItem(
              icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
  
  Widget _buildProfileHeader() {
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
      child: Row(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: Color(0xFFC14465),
            child: Text(
              _userData!['name'].substring(0, 1).toUpperCase(),
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _userData!['name'],
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  _userData!['email'],
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ),
                SizedBox(height: 5),
                Row(
                  children: [
                    Icon(Icons.water_drop, color: Color(0xFFC14465), size: 18),
                    SizedBox(width: 5),
                    Text(
                      'Blood Group: ${_userData!['bloodGroup']}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFFC14465),
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
  }

  Widget _buildProfileDetails() {
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
          _buildDetailItem(Icons.phone, 'Phone', _userData!['phone']),
          Divider(),
          _buildDetailItem(Icons.calendar_today, 'Date of Birth', _userData!['dob']),
          Divider(),
          _buildDetailItem(Icons.location_on, 'Address', _userData!['address']),
        ],
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Color(0xFFC14465), size: 22),
          SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        ElevatedButton.icon(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => DonationHistoryPage()),
            );
          },
          icon: Icon(Icons.history),
          label: Text('Donation History'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFFD95373),
            foregroundColor: Colors.white,
            minimumSize: Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
          ),
        ),
        SizedBox(height: 15),
        ElevatedButton.icon(
          onPressed: () => _showEditProfileDialog(),
          icon: Icon(Icons.edit),
          label: Text('Edit Profile'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Color(0xFFC14465),
            minimumSize: Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
              side: BorderSide(color: Color(0xFFC14465)),
            ),
          ),
        ),
      ],
    );
  }

  void _showEditProfileDialog() {
    // Create controllers with current values
    final nameController = TextEditingController(text: _userData!['name']);
    final phoneController = TextEditingController(text: _userData!['phone']);
    final addressController = TextEditingController(text: _userData!['address']);
    final dobController = TextEditingController(text: _userData!['dob']);
    final bloodGroupController = TextEditingController(text: _userData!['bloodGroup']);
    
    // Available blood group options
    final bloodGroups = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];
    String selectedBloodGroup = _userData!['bloodGroup'];
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text('Edit Profile', 
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFFC14465),
              ),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'Name',
                      prefixIcon: Icon(Icons.person, color: Color(0xFFC14465)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: Color(0xFFC14465),
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: phoneController,
                    decoration: InputDecoration(
                      labelText: 'Phone',
                      prefixIcon: Icon(Icons.phone, color: Color(0xFFC14465)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: Color(0xFFC14465),
                          width: 2,
                        ),
                      ),
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: addressController,
                    decoration: InputDecoration(
                      labelText: 'Address',
                      prefixIcon: Icon(Icons.location_on, color: Color(0xFFC14465)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: Color(0xFFC14465),
                          width: 2,
                        ),
                      ),
                    ),
                    maxLines: 2,
                  ),
                  SizedBox(height: 16),
                  GestureDetector(
                    onTap: () async {
                      final DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: _parseDate(_userData!['dob']),
                        firstDate: DateTime(1900),
                        lastDate: DateTime.now(),
                        builder: (context, child) {
                          return Theme(
                            data: ThemeData.light().copyWith(
                              colorScheme: ColorScheme.light(
                                primary: Color(0xFFC14465),
                              ),
                            ),
                            child: child!,
                          );
                        },
                      );
                      
                      if (pickedDate != null) {
                        setState(() {
                          dobController.text = '${pickedDate.day}/${pickedDate.month}/${pickedDate.year}';
                        });
                      }
                    },
                    child: AbsorbPointer(
                      child: TextField(
                        controller: dobController,
                        decoration: InputDecoration(
                          labelText: 'Date of Birth',
                          prefixIcon: Icon(Icons.calendar_today, color: Color(0xFFC14465)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: Color(0xFFC14465),
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedBloodGroup,
                    decoration: InputDecoration(
                      labelText: 'Blood Group',
                      prefixIcon: Icon(Icons.water_drop, color: Color(0xFFC14465)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: Color(0xFFC14465),
                          width: 2,
                        ),
                      ),
                    ),
                    items: bloodGroups.map((String bloodGroup) {
                      return DropdownMenuItem<String>(
                        value: bloodGroup,
                        child: Text(bloodGroup),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          selectedBloodGroup = newValue;
                          bloodGroupController.text = newValue;
                        });
                      }
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel', style: TextStyle(color: Colors.grey)),
              ),
              ElevatedButton(
                onPressed: () => _updateProfile(
                  nameController.text,
                  phoneController.text,
                  addressController.text,
                  dobController.text,
                  bloodGroupController.text,
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFC14465),
                ),
                child: Text('Save Changes'),
              ),
            ],
          );
        },
      ),
    );
  }

  DateTime _parseDate(String date) {
    try {
      final parts = date.split('/');
      if (parts.length == 3) {
        return DateTime(
          int.parse(parts[2]), // year
          int.parse(parts[1]), // month
          int.parse(parts[0]), // day
        );
      }
    } catch (e) {
      print('Error parsing date: $e');
    }
    return DateTime.now(); // Fallback to current date
  }

  Future<void> _updateProfile(
  String name,
  String phone,
  String address,  
  String dob,
  String bloodGroup,
) async {
  if (name.isEmpty || phone.isEmpty || address.isEmpty || dob.isEmpty || bloodGroup.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("All fields are required")),
    );
    return;
  }
  try {
    setState(() => _isLoading = true);
    
    final authService = Provider.of<AuthService>(context, listen: false);
    
    // Make sure phone is explicitly included in updatedData
    final updatedData = {
      'name': name,
      'phone': phone.trim(), // Trim to remove any accidental whitespace
      'address': address,
      'dob': dob,
      'bloodGroup': bloodGroup,
      'email': _userData!['email'], // Preserve the email
    };
    
    // Print debug information
    print('Before update - Phone: ${_userData!['phone']}');
    print('Updating with phone: $phone');
    
    await authService.updateUserProfile(updatedData);
    
    // Make sure to reload the user data from the backend
    final refreshedUserData = await authService.getCurrentUserData();
    
    // Update local data with the freshly loaded data
    setState(() {
      _userData = refreshedUserData;
      _isLoading = false;
    });
    
    print('After update - Phone: ${_userData!['phone']}');
    
    Navigator.pop(context); // Close the dialog
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Profile updated successfully"),
        backgroundColor: Colors.green,
      ),
    );
  } catch (e) {
    setState(() => _isLoading = false);
    print('Error updating profile: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Error updating profile: ${e.toString()}"),
        backgroundColor: Colors.red,
      ),
    );
  }
}

  void _showSignOutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Sign Out'),
        content: Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _signOut();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFC14465),
            ),
            child: Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}