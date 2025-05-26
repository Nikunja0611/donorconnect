import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DonorConnectPage extends StatefulWidget {
  const DonorConnectPage({Key? key}) : super(key: key);

  @override
  _DonorConnectPageState createState() => _DonorConnectPageState();
}

class _DonorConnectPageState extends State<DonorConnectPage> {
  String selectedBloodGroup = 'All';
  String selectedState = 'All';
  String selectedDistrict = 'All';
  String selectedCity = 'All';
  List<Donor> filteredDonors = [];
  bool isLoading = false;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final List<String> bloodGroups = [
    'All',
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    'O+',
    'O-'
  ];

  final List<String> states = [
    'All',
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
    'All': ['All'],
    'Maharashtra': [
      'All',
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
      'All',
      'Bangalore',
      'Mysore',
      'Hubli',
      'Mangalore',
      'Belgaum',
      'Gulbarga',
      'Shimoga'
    ],
    'Gujarat': [
      'All',
      'Ahmedabad',
      'Surat',
      'Vadodara',
      'Rajkot',
      'Gandhinagar',
      'Bhavnagar'
    ],
    'Tamil Nadu': [
      'All',
      'Chennai',
      'Coimbatore',
      'Madurai',
      'Trichy',
      'Salem',
      'Tirunelveli'
    ],
    'Delhi': [
      'All',
      'New Delhi',
      'North Delhi',
      'South Delhi',
      'East Delhi',
      'West Delhi'
    ],
    'Uttar Pradesh': [
      'All',
      'Lucknow',
      'Kanpur',
      'Agra',
      'Varanasi',
      'Meerut',
      'Allahabad',
      'Ghaziabad'
    ],
    'West Bengal': [
      'All',
      'Kolkata',
      'Howrah',
      'Durgapur',
      'Asansol',
      'Siliguri'
    ],
    'Rajasthan': [
      'All',
      'Jaipur',
      'Jodhpur',
      'Udaipur',
      'Kota',
      'Ajmer',
      'Bikaner'
    ],
    'Telangana': [
      'All',
      'Hyderabad',
      'Warangal',
      'Nizamabad',
      'Karimnagar',
      'Khammam'
    ],
    'Kerala': ['All', 'Trivandrum'],
    'Punjab': ['All', 'Amritsar']
  };

  @override
  void initState() {
    super.initState();
    fetchDonors();
  }

  Future<void> fetchDonors() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Make sure to only fetch donors who have explicit isDonor = true
      QuerySnapshot userSnapshot = await _firestore
          .collection('users')
          .where('isDonor', isEqualTo: true)
          .get();

      List<Donor> donorList = [];
      for (var doc in userSnapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        // Debug - Print the entire user document to check fields
        print("Donor data retrieved: ${doc.id}");
        print(data);

        // Add better conditional checks to ensure we have all required fields
        if (data.containsKey('name') && data.containsKey('bloodGroup')) {
          donorList.add(Donor(
            id: doc.id,
            name: data['name'] ?? 'Anonymous Donor',
            bloodGroup: data['bloodGroup'] ?? '',
            phone: data['phone'] ?? '',
            state: data['state'] ?? '',
            district: data['district'] ?? '',
            city: data['city'] ?? '',
            available: data['isAvailable'] ?? false,
          ));
        }
      }

      setState(() {
        filteredDonors = donorList;
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching donors: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  void filterDonors() {
    setState(() {
      isLoading = true;
    });

    try {
      // Start with the base query
      Query usersRef =
          _firestore.collection('users').where('isDonor', isEqualTo: true);

      // Add blood group filter if selected
      if (selectedBloodGroup != 'All') {
        usersRef = usersRef.where('bloodGroup', isEqualTo: selectedBloodGroup);
      }

      // Add state filter if selected
      if (selectedState != 'All') {
        usersRef = usersRef.where('state', isEqualTo: selectedState);
      }

      // Execute the query
      usersRef.get().then((querySnapshot) {
        List<Donor> donors = [];

        print("Query returned ${querySnapshot.docs.length} documents");

        for (var doc in querySnapshot.docs) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

          // Debug - print each document
          print("Processing donor: ${doc.id}");
          print(data);

          // Filter by district client-side if needed
          bool districtMatch = selectedDistrict == 'All' ||
              (data['district'] != null &&
                  data['district'] == selectedDistrict);

          if (districtMatch) {
            donors.add(Donor(
              id: doc.id,
              name: data['name'] ?? 'Anonymous Donor',
              bloodGroup: data['bloodGroup'] ?? '',
              phone: data['phone'] ?? '',
              state: data['state'] ?? '',
              district: data['district'] ?? '',
              city: data['city'] ?? '',
              available: data['isAvailable'] ?? false,
            ));
          }
        }

        setState(() {
          filteredDonors = donors;
          isLoading = false;
        });
      }).catchError((error) {
        print("Error executing query: $error");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error searching donors: $error'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          isLoading = false;
        });
      });
    } catch (e) {
      print("Exception in filterDonors: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  void _showReportDialog(BuildContext context, Donor donor) {
    final TextEditingController _reportController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Report Donor'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Please provide a reason for reporting this donor:'),
            SizedBox(height: 16),
            TextField(
              controller: _reportController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Enter reason for report',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFC14465),
            ),
            onPressed: () {
              // Get current user ID
              final currentUserId = FirebaseAuth.instance.currentUser?.uid;
              
              if (currentUserId == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('You must be logged in to report a donor'),
                    backgroundColor: Colors.red,
                  ),
                );
                Navigator.pop(context);
                return;
              }
              
              // Submit report to Firestore with reporter ID
              _firestore.collection('reports').add({
                'donorId': donor.id,
                'donorName': donor.name,
                'reportReason': _reportController.text,
                'reporterId': currentUserId,
                'reportedAt': FieldValue.serverTimestamp(),
              }).then((_) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Report submitted successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              }).catchError((error) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to submit report: $error'),
                    backgroundColor: Colors.red,
                  ),
                );
              });
            },
            child: Text('Submit'),
          ),
        ],
      ),
    );
  }

  // Fixed navigation method to ensure consistent behavior
  void _navigateToPage(int index) {
    switch (index) {
      case 0: // Home
        // Clear entire navigation stack and go to home
        Navigator.pushNamedAndRemoveUntil(
          context, 
          '/', 
          (Route<dynamic> route) => false,
        );
        break;
      case 1: // Medical Help
        Navigator.pushNamedAndRemoveUntil(
          context, 
          '/medical_help_page', 
          (Route<dynamic> route) => false,
        );
        break;
      case 2: // BloodBank - Current page, do nothing
        break;
      case 3: // Fundraising
        Navigator.pushNamedAndRemoveUntil(
          context, 
          '/fundraising_page', 
          (Route<dynamic> route) => false,
        );
        break;
      case 4: // Profile
        Navigator.pushNamedAndRemoveUntil(
          context, 
          '/profile_page', 
          (Route<dynamic> route) => false,
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Raktapurak Charitable Foundation',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color(0xFFC14465),
        elevation: 0,
        // Ensure no back button is shown
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          Container(
            color: Color(0xFFC14465),
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            child: Text(
              'DonorConnect',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Blood Donor Details',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF3D3366),
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: filterDropdown(
                        'Blood Group',
                        selectedBloodGroup,
                        bloodGroups,
                        (value) {
                          setState(() {
                            selectedBloodGroup = value!;
                          });
                        },
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: filterDropdown(
                        'State',
                        selectedState,
                        states,
                        (value) {
                          setState(() {
                            selectedState = value!;
                            selectedDistrict = 'All';
                          });
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: filterDropdown(
                        'District',
                        selectedDistrict,
                        getDistrictsForState(selectedState),
                        (value) {
                          setState(() {
                            selectedDistrict = value!;
                          });
                        },
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: Icon(Icons.search),
                        label: Text('Search Donors'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFC14465),
                          padding: EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: filterDonors,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: fetchDonors,
              child: isLoading
                  ? Center(
                      child:
                          CircularProgressIndicator(color: Color(0xFFC14465)))
                  : filteredDonors.isEmpty
                      ? Center(
                          child: Text(
                            'No donors found. Try different criteria.',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF3D3366),
                            ),
                          ),
                        )
                      : ListView.builder(
                          itemCount: filteredDonors.length,
                          itemBuilder: (context, index) {
                            final donor = filteredDonors[index];
                            return DonorCard(
                              donor: donor,
                              onReport: () => _showReportDialog(context, donor),
                            );
                          },
                        ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2, // BloodBank selected
        selectedItemColor: Colors.pink[700],
        unselectedItemColor: Colors.pink[300],
        type: BottomNavigationBarType.fixed,
        onTap: _navigateToPage, // Use the new navigation method
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

  Widget filterDropdown(String label, String value, List<String> items,
      Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
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
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              items: items.map((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(item),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  List<String> getDistrictsForState(String state) {
    return districts.containsKey(state) ? districts[state]! : ['All'];
  }
}

class Donor {
  final String id;
  final String name;
  final String bloodGroup;
  final String phone;
  final String state;
  final String district;
  final String city;
  final bool available;

  Donor({
    required this.id,
    required this.name,
    required this.bloodGroup,
    required this.phone,
    required this.state,
    required this.district,
    required this.city,
    required this.available,
  });
}

class DonorCard extends StatelessWidget {
  final Donor donor;
  final VoidCallback onReport;

  const DonorCard({
    Key? key,
    required this.donor,
    required this.onReport,
  }) : super(key: key);

  String _getLocationString() {
    // Debug print to see what location data we actually have
    print("Location data for ${donor.name}:");
    print("State: '${donor.state}'");
    print("District: '${donor.district}'");
    print("City: '${donor.city}'");

    // Create location string with the best available data
    List<String> locationParts = [];

    if (donor.city.isNotEmpty &&
        donor.city != 'null' &&
        donor.city != 'undefined') {
      locationParts.add(donor.city);
    }

    if (donor.district.isNotEmpty &&
        donor.district != 'All' &&
        donor.district != 'null' &&
        donor.district != 'undefined') {
      locationParts.add(donor.district);
    }

    if (donor.state.isNotEmpty &&
        donor.state != 'All' &&
        donor.state != 'null' &&
        donor.state != 'undefined') {
      locationParts.add(donor.state);
    }

    // If all location fields are empty or invalid, show default message
    if (locationParts.isEmpty) {
      return "Location not specified";
    }

    return locationParts.join(', ');
  }

  @override
  Widget build(BuildContext context) {
    final String locationString = _getLocationString();

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Color(0xFFC14465),
                        child: Text(
                          donor.bloodGroup,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              donor.name,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF3D3366),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 4),
                            // Location Row with improved layout
                            Row(
                              children: [
                                Icon(
                                  Icons.location_on_outlined,
                                  size: 14,
                                  color: Colors.grey[600],
                                ),
                                SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    locationString,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2, // Allow two lines for location
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color:
                        donor.available ? Colors.green[100] : Colors.grey[200],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    donor.available ? 'Available' : 'Not Available',
                    style: TextStyle(
                      fontSize: 12,
                      color: donor.available
                          ? Colors.green[800]
                          : Colors.grey[800],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon:
                        Icon(Icons.message, color: Color(0xFF3D3366), size: 16),
                    label: Text(
                      'Message',
                      style: TextStyle(color: Color(0xFF3D3366), fontSize: 12),
                    ),
                    onPressed: () {
                      launchUrl(Uri.parse('sms:${donor.phone}'));
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Color(0xFF3D3366)),
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: Icon(Icons.call, size: 16),
                    label: Text('Call', style: TextStyle(fontSize: 12)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFC14465),
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                    ),
                    onPressed: () {
                      launchUrl(Uri.parse('tel:${donor.phone}'));
                    },
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    icon:
                        Icon(Icons.flag, color: Colors.red.shade700, size: 16),
                    label: Text(
                      'Report',
                      style:
                          TextStyle(color: Colors.red.shade700, fontSize: 12),
                    ),
                    onPressed: onReport,
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.red.shade700),
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}