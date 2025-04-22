import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'donation_history_page.dart';
import 'donor_connect.dart'; // Import the DonorConnectPage

class WelcomeUserPage extends StatefulWidget {
  @override
  _WelcomeUserPageState createState() => _WelcomeUserPageState();
}

class _WelcomeUserPageState extends State<WelcomeUserPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = true;
  String _userName = "User";
  bool _isDonor = false; // Track if user is a donor

  @override
  void initState() {
    super.initState();
    _getUserData();
  }

  void _getUserData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Get current user ID
      User? currentUser = _auth.currentUser;

      if (currentUser != null) {
        // Fetch user data from Firestore
        DocumentSnapshot userDoc =
            await _firestore.collection('users').doc(currentUser.uid).get();

        if (userDoc.exists && userDoc.data() != null) {
          var userData = userDoc.data() as Map<String, dynamic>;
          setState(() {
            _userName = userData['name'] ?? "User";
            _isDonor = userData['isDonor'] ?? false; // Get isDonor status
          });
        } else {
          // This is a new user - document doesn't exist yet
          // Just keep isDonor as false
        }
      }
    } catch (e) {
      print("Error fetching user data: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFCF3F9),
      appBar: AppBar(
        backgroundColor: Color(0xFFC14465),
        title: Text('Donor Portal', style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: Color(0xFFC14465)))
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.volunteer_activism,
                    size: 80,
                    color: Color(0xFFC14465),
                  ),
                  SizedBox(height: 20),
                  Text(
                    _isDonor
                        ? 'Welcome back, $_userName!'
                        : 'Welcome, $_userName!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFC14465),
                    ),
                  ),
                  SizedBox(height: 10),
                  if (!_isDonor)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Text(
                        'Complete your donor profile to join our blood donation community.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF3D3366),
                        ),
                      ),
                    ),
                  SizedBox(height: 20),
                  if (_isDonor)
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => DonationHistoryPage()));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFC14465),
                        padding:
                            EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                      ),
                      child: Text(
                        'View Donation History',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  SizedBox(height: 15),
                  ElevatedButton(
                    onPressed: () {
                      _updateDonorProfile(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          _isDonor ? Color(0xFF3D3366) : Color(0xFFC14465),
                      padding:
                          EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    ),
                    child: Text(
                      _isDonor
                          ? 'Update Donor Profile'
                          : 'Complete Donor Profile',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                  if (_isDonor) SizedBox(height: 15),
                  if (_isDonor)
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => DonorConnectPage()));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF3D3366),
                        padding:
                            EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                      ),
                      child: Text(
                        'Find Blood Donors',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                ],
              ),
            ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Color(0xfffff0f4),
        selectedItemColor: Colors.pink[700],
        unselectedItemColor: Colors.pink[300],
        selectedLabelStyle:
            TextStyle(fontWeight: FontWeight.w600, color: Colors.pink[300]),
        unselectedLabelStyle:
            TextStyle(fontWeight: FontWeight.w400, color: Colors.pink[300]),
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Find Donors',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.volunteer_activism),
            label: 'Donate',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: 0,
        onTap: (index) {
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => DonorConnectPage()),
            );
          }
          // Add other navigation options as needed
        },
      ),
    );
  }

  void _updateDonorProfile(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    final availabilityController = TextEditingController(text: 'Available');

    // Initial values for dropdowns
    String selectedState = '';
    String selectedDistrict = '';
    bool isAvailable = true;

    // Lists for dropdown options - without "All" option
    final List<String> states = [
      'Andhra Pradesh',
      'Arunachal Pradesh',
      'Assam',
      'Bihar',
      'Chhattisgarh',
      'Goa',
      'Gujarat',
      'Haryana',
      'Himachal Pradesh',
      'Jharkhand',
      'Karnataka',
      'Kerala',
      'Madhya Pradesh',
      'Maharashtra',
      'Manipur',
      'Meghalaya',
      'Mizoram',
      'Nagaland',
      'Odisha',
      'Punjab',
      'Rajasthan',
      'Sikkim',
      'Tamil Nadu',
      'Telangana',
      'Tripura',
      'Uttar Pradesh',
      'Uttarakhand',
      'West Bengal',
      'Delhi'
    ];

    Map<String, List<String>> districts = {
      'Maharashtra': [
        'Mumbai',
        'Pune',
        'Nagpur',
        'Thane',
        'Nashik',
        'Aurangabad',
        'Solapur',
        'Kolhapur',
        'Ratnagiri'
      ],
      'Karnataka': [
        'Bangalore',
        'Mysore',
        'Hubli',
        'Mangalore',
        'Belgaum',
        'Gulbarga',
        'Shimoga'
      ],
      'Gujarat': [
        'Ahmedabad',
        'Surat',
        'Vadodara',
        'Rajkot',
        'Gandhinagar',
        'Bhavnagar'
      ],
      'Tamil Nadu': [
        'Chennai',
        'Coimbatore',
        'Madurai',
        'Trichy',
        'Salem',
        'Tirunelveli'
      ],
      'Delhi': [
        'New Delhi',
        'North Delhi',
        'South Delhi',
        'East Delhi',
        'West Delhi'
      ],
      'Uttar Pradesh': [
        'Lucknow',
        'Kanpur',
        'Agra',
        'Varanasi',
        'Meerut',
        'Allahabad',
        'Ghaziabad'
      ],
      'West Bengal': ['Kolkata', 'Howrah', 'Durgapur', 'Asansol', 'Siliguri'],
      'Rajasthan': ['Jaipur', 'Jodhpur', 'Udaipur', 'Kota', 'Ajmer', 'Bikaner'],
      'Telangana': [
        'Hyderabad',
        'Warangal',
        'Nizamabad',
        'Karimnagar',
        'Khammam'
      ],
      'Kerala': ['Trivandrum', 'Kochi', 'Kozhikode', 'Thrissur'],
      'Punjab': ['Amritsar', 'Ludhiana', 'Jalandhar', 'Patiala']
    };

    // Get current user data to pre-fill the form
    if (_auth.currentUser != null) {
      _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .get()
          .then((userDoc) {
        if (userDoc.exists && userDoc.data() != null) {
          var userData = userDoc.data()!;
          isAvailable = userData['isAvailable'] ?? true;
          availabilityController.text =
              isAvailable ? 'Available' : 'Not Available';

          // Set initial values for dropdowns if they exist in user data
          if (userData['state'] != null && userData['state'] != '') {
            selectedState = userData['state'];
          } else if (states.isNotEmpty) {
            selectedState =
                states[0]; // Default to first state if no state is set
          }

          if (userData['district'] != null && userData['district'] != '') {
            selectedDistrict = userData['district'];
          } else if (selectedState != '' &&
              districts[selectedState]?.isNotEmpty == true) {
            selectedDistrict =
                districts[selectedState]![0]; // Default to first district
          }
        }
      });
    }

    // Function to get district list based on selected state
    List<String> getDistrictsForState(String state) {
      return districts.containsKey(state) ? districts[state]! : [];
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(
              _isDonor ? 'Update Donor Profile' : 'Complete Donor Profile'),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // State Dropdown
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'State',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF3D3366),
                        ),
                      ),
                      SizedBox(height: 8),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: DropdownButtonFormField<String>(
                          value: selectedState.isEmpty && states.isNotEmpty
                              ? states[0]
                              : selectedState,
                          isExpanded: true,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                          ),
                          items: states.map((String state) {
                            return DropdownMenuItem<String>(
                              value: state,
                              child: Text(state),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedState = value!;
                              // Reset district when state changes
                              if (districts[selectedState]?.isNotEmpty ==
                                  true) {
                                selectedDistrict = districts[selectedState]![0];
                              } else {
                                selectedDistrict = '';
                              }
                            });
                          },
                          validator: (value) => value == null || value.isEmpty
                              ? 'Please select a state'
                              : null,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),

                  // District Dropdown
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'District',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF3D3366),
                        ),
                      ),
                      SizedBox(height: 8),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: DropdownButtonFormField<String>(
                          value: selectedDistrict.isEmpty &&
                                  getDistrictsForState(selectedState).isNotEmpty
                              ? getDistrictsForState(selectedState)[0]
                              : selectedDistrict,
                          isExpanded: true,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                          ),
                          items: getDistrictsForState(selectedState)
                              .map((String district) {
                            return DropdownMenuItem<String>(
                              value: district,
                              child: Text(district),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedDistrict = value!;
                            });
                          },
                          validator: (value) => value == null || value.isEmpty
                              ? 'Please select a district'
                              : null,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),

                  // Availability Status
                  DropdownButtonFormField<String>(
                    value: availabilityController.text,
                    decoration: InputDecoration(
                      labelText: 'Availability Status',
                      border: OutlineInputBorder(),
                    ),
                    items: ['Available', 'Not Available'].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      availabilityController.text = newValue!;
                    },
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
                    // Print values being saved
                    print("Saving donor profile with values:");
                    print(
                        "Available: ${availabilityController.text == 'Available'}");
                    print("State: $selectedState");
                    print("District: $selectedDistrict");

                    // Prepare update data
                    Map<String, dynamic> updateData = {
                      'isAvailable': availabilityController.text == 'Available',
                      'isDonor':
                          true, // Always set isDonor to true when profile is updated
                      'lastUpdated': FieldValue.serverTimestamp(),
                      // Location data from dropdowns
                      'state': selectedState,
                      'district': selectedDistrict,
                      // Removed city field
                      // Make sure name and phone are saved too
                      'name': _userName, // Use current user name
                      'phone': _auth.currentUser?.phoneNumber ??
                          '', // Get phone if available
                    };

                    // Update user data in Firestore
                    await _firestore
                        .collection('users')
                        .doc(_auth.currentUser!.uid)
                        .update(updateData);

                    // Update local state
                    setState(() {
                      _isDonor = true;
                    });

                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text('Donor profile updated successfully')),
                    );
                  } catch (e) {
                    print("Error updating profile: $e");
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error updating profile: $e')),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFC14465),
              ),
              child: Text(_isDonor ? 'Update' : 'Complete'),
            ),
          ],
        ),
      ),
    );
  }
}
