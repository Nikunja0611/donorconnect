import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
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
  bool _isAvailable = true; // Track if user can donate
  String? _nextDonationDate; // Store next eligible donation date
  String _inspirationalQuote = ""; // Store a motivational quote

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
            _isAvailable = userData['isAvailable'] ?? true; // Get availability status
            _nextDonationDate = userData['nextDonationDate']; // Get next donation date
            
            // Set an inspirational quote based on availability
            _setInspirationalQuote();
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
  
  // Set an inspirational quote based on user's donation status
  void _setInspirationalQuote() {
    List<String> availableQuotes = [
      "Your blood donation is a precious gift that can save up to three lives!",
      "Be a hero today - donate blood, save lives!",
      "A single drop of your blood can make a huge difference in someone's life.",
      "Giving blood is giving the gift of life.",
    ];
    
    List<String> waitingQuotes = [
      "Thank you for your donation! Your body is regenerating - take care of yourself.",
      "Heroes need rest too. Your next chance to save lives is coming soon!",
      "Your recent donation already made a difference. We'll see you again soon!",
      "Rest and recover - your body is preparing for your next heroic donation.",
    ];
    
    if (_isDonor) {
      if (_isAvailable) {
        // Randomly select an available quote
        _inspirationalQuote = availableQuotes[DateTime.now().millisecond % availableQuotes.length];
      } else {
        // Randomly select a waiting quote
        _inspirationalQuote = waitingQuotes[DateTime.now().millisecond % waitingQuotes.length];
      }
    } else {
      // Default quote for new users
      _inspirationalQuote = "Join our blood donation community and become a lifesaver!";
    }
  }
  
  // Helper method to parse date strings
  DateTime _parseDate(String dateStr) {
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
      print('Error parsing date: $e');
    }
    return DateTime.now(); // Return current date as fallback
  }
  
  // Calculate days until next eligible donation
  int _getDaysRemaining() {
    if (_nextDonationDate == null) return 0;
    
    DateTime nextDate = _parseDate(_nextDonationDate!);
    DateTime today = DateTime.now();
    return nextDate.difference(today).inDays;
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
                  
                  // Inspirational quote container
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Container(
                      padding: EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Color(0xFFC14465).withOpacity(0.3)),
                      ),
                      child: Text(
                        _inspirationalQuote,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF3D3366),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ),
                  
                  SizedBox(height: 10),
                  
                  // Show donation status for donors
                  if (_isDonor && !_isAvailable && _nextDonationDate != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Text(
                        'You can donate again on: $_nextDonationDate (${_getDaysRemaining()} days)',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFFC14465),
                        ),
                      ),
                    ),
                  
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
        currentIndex: 2, // BloodBank selected
        selectedItemColor: Colors.pink[700],
        unselectedItemColor: Colors.pink[300],
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushReplacementNamed(context, '/');
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
              Navigator.pushReplacementNamed(context, '/profile_page');
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.medical_services), label: 'MedicalHelp'),
          BottomNavigationBarItem(
              icon: Icon(Icons.opacity), label: 'BloodBank'),
          BottomNavigationBarItem(
              icon: Icon(Icons.volunteer_activism), label: 'Fundraising'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  void _updateDonorProfile(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    
    // Remove the availability controller and dropdown since users shouldn't manually change this

    // Initial values for dropdowns
    String selectedState = '';
    String selectedDistrict = '';

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

                  // Display current availability status (but don't allow changing it)
                  if (_isDonor)
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(4),
                        color: Colors.grey.shade100,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Availability Status',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF3D3366),
                            ),
                          ),
                          SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                _isAvailable ? Icons.check_circle : Icons.timer,
                                color: _isAvailable ? Colors.green : Colors.orange,
                              ),
                              SizedBox(width: 8),
                              Text(
                                _isAvailable ? 'Available' : 'Not Available',
                                style: TextStyle(
                                  color: _isAvailable ? Colors.green : Colors.orange,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 4),
                          Text(
                            _isAvailable 
                                ? 'You are eligible to donate blood.'
                                : _nextDonationDate != null 
                                    ? 'You can donate again on: $_nextDonationDate'
                                    : 'You are currently not eligible to donate.',
                            style: TextStyle(
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Note: Availability is automatically updated based on your donation history and the required 100-day recovery period.',
                            style: TextStyle(
                              fontSize: 12, 
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
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
                    print("State: $selectedState");
                    print("District: $selectedDistrict");

                    // Prepare update data
                    Map<String, dynamic> updateData = {
                      'isDonor': true, // Always set isDonor to true when profile is updated
                      'lastUpdated': FieldValue.serverTimestamp(),
                      // Location data from dropdowns
                      'state': selectedState,
                      'district': selectedDistrict,
                      // Make sure name and phone are saved too
                      'name': _userName, // Use current user name
                      'phone': _auth.currentUser?.phoneNumber ?? '', // Get phone if available
                    };

                    // IMPORTANT: Do not update isAvailable field here
                    // That should only be managed by the donation recording system

                    // Update user data in Firestore
                    await _firestore
                        .collection('users')
                        .doc(_auth.currentUser!.uid)
                        .update(updateData);

                    // Update local state (but don't change availability)
                    setState(() {
                      _isDonor = true;
                      // Don't update _isAvailable here
                      _setInspirationalQuote(); // Update quote based on current status
                    });

                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text('Donor profile updated successfully')),
                    );
                    
                    // Refresh user data
                    _getUserData();
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