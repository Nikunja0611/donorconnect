import 'package:flutter/material.dart';

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

  List<Donor> allDonors = [
    Donor(
        name: 'Ranjan Hegde',
        bloodGroup: 'O+',
        phone: '9856458426',
        state: 'Maharashtra',
        district: 'Mumbai',
        city: 'Mumbai',
        available: true),
    Donor(
        name: 'Atul More',
        bloodGroup: 'A+',
        phone: '8956458478',
        state: 'Maharashtra',
        district: 'Pune',
        city: 'Pune',
        available: true),
    Donor(
        name: 'Shobha Menon',
        bloodGroup: 'B-',
        phone: '7896458468',
        state: 'Karnataka',
        district: 'Bangalore',
        city: 'Bangalore',
        available: true),
    Donor(
        name: 'Virat Shukla',
        bloodGroup: 'AB+',
        phone: '8856458499',
        state: 'Gujarat',
        district: 'Ahmedabad',
        city: 'Ahmedabad',
        available: true),
    Donor(
        name: 'Rahul Sharma',
        bloodGroup: 'A-',
        phone: '9875643210',
        state: 'Delhi',
        district: 'New Delhi',
        city: 'New Delhi',
        available: true),
    Donor(
        name: 'Priya Singh',
        bloodGroup: 'O-',
        phone: '7765432109',
        state: 'Uttar Pradesh',
        district: 'Lucknow',
        city: 'Lucknow',
        available: false),
    Donor(
        name: 'Aarav Patel',
        bloodGroup: 'B+',
        phone: '8867543210',
        state: 'Gujarat',
        district: 'Surat',
        city: 'Surat',
        available: true),
    Donor(
        name: 'Neha Gupta',
        bloodGroup: 'AB-',
        phone: '9987654321',
        state: 'Maharashtra',
        district: 'Nagpur',
        city: 'Nagpur',
        available: true),
    Donor(
        name: 'Vikram Desai',
        bloodGroup: 'O+',
        phone: '7789654321',
        state: 'Karnataka',
        district: 'Mysore',
        city: 'Mysore',
        available: true),
    Donor(
        name: 'Ananya Reddy',
        bloodGroup: 'A+',
        phone: '8876543219',
        state: 'Telangana',
        district: 'Hyderabad',
        city: 'Hyderabad',
        available: true),
    Donor(
        name: 'Rajesh Kumar',
        bloodGroup: 'B+',
        phone: '9765432180',
        state: 'Tamil Nadu',
        district: 'Chennai',
        city: 'Chennai',
        available: true),
    Donor(
        name: 'Meera Joshi',
        bloodGroup: 'AB+',
        phone: '8867543290',
        state: 'Maharashtra',
        district: 'Pune',
        city: 'Pune',
        available: false),
    Donor(
        name: 'Arjun Nair',
        bloodGroup: 'O-',
        phone: '7754321098',
        state: 'Kerala',
        district: 'Trivandrum',
        city: 'Trivandrum',
        available: true),
    Donor(
        name: 'Kavita Mehta',
        bloodGroup: 'A-',
        phone: '9876543217',
        state: 'Rajasthan',
        district: 'Jaipur',
        city: 'Jaipur',
        available: true),
    Donor(
        name: 'Suresh Iyer',
        bloodGroup: 'B-',
        phone: '8865432178',
        state: 'Tamil Nadu',
        district: 'Coimbatore',
        city: 'Coimbatore',
        available: true),
    Donor(
        name: 'Divya Malhotra',
        bloodGroup: 'AB-',
        phone: '7798765432',
        state: 'Punjab',
        district: 'Amritsar',
        city: 'Amritsar',
        available: true),
    Donor(
        name: 'Amit Shah',
        bloodGroup: 'O+',
        phone: '9987654329',
        state: 'Gujarat',
        district: 'Vadodara',
        city: 'Vadodara',
        available: true),
    Donor(
        name: 'Pooja Verma',
        bloodGroup: 'A+',
        phone: '8876543218',
        state: 'Uttar Pradesh',
        district: 'Kanpur',
        city: 'Kanpur',
        available: false),
    Donor(
        name: 'Kiran Rao',
        bloodGroup: 'B+',
        phone: '7765432187',
        state: 'West Bengal',
        district: 'Kolkata',
        city: 'Kolkata',
        available: true),
    Donor(
        name: 'Sandeep Khanna',
        bloodGroup: 'AB+',
        phone: '9876543216',
        state: 'Maharashtra',
        district: 'Thane',
        city: 'Thane',
        available: true),
  ];

  @override
  void initState() {
    super.initState();
    filteredDonors = List.from(allDonors);
  }

  // Navigation method for bottom navigation bar
  void _navigateToPage(int index) {
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/home_screen');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/medical_help_page');
        break;
      case 2:
        break;
      case 3:
        Navigator.pushReplacementNamed(context, '/fundraising_page');
        break;
      case 4:
        Navigator.pushReplacementNamed(context, '/profile_page');
        break;
    }
  }

  List<String> getDistrictsForState(String state) {
    if (districts.containsKey(state)) {
      return districts[state]!;
    } else {
      return ['All'];
    }
  }

  void filterDonors() {
    setState(() {
      filteredDonors = allDonors.where((donor) {
        bool bloodGroupMatch = selectedBloodGroup == 'All' ||
            donor.bloodGroup == selectedBloodGroup;
        bool stateMatch =
            selectedState == 'All' || donor.state == selectedState;
        bool districtMatch =
            selectedDistrict == 'All' || donor.district == selectedDistrict;

        return bloodGroupMatch && stateMatch && districtMatch;
      }).toList();
    });
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
                            filterDonors();
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
                            filterDonors();
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
                            filterDonors();
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
          SizedBox(height: 16),
          Expanded(
            child: filteredDonors.isEmpty
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
                      return DonorCard(donor: donor);
                    },
                  ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Color(0xfffff0f4),
        selectedItemColor: Colors.pink[700],
        unselectedItemColor: Colors.pink[300],
        selectedLabelStyle:
            TextStyle(fontWeight: FontWeight.w600, color: Colors.pink[300]),
        unselectedLabelStyle: TextStyle(
            fontWeight: FontWeight.w600, color: Colors.white.withOpacity(0.6)),
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home, color: Colors.pink[300]),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.medical_services, color: Colors.pink[300]),
            label: 'MedicalHelp',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bloodtype, color: Colors.pink[300]),
            label: 'BloodBank',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.volunteer_activism, color: Colors.pink[300]),
            label: 'Fundraising',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person, color: Colors.pink[300]),
            label: 'Profile',
          ),
        ],
        currentIndex: 2, // Blood Bank page
        onTap: _navigateToPage,
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
            fontWeight: FontWeight.w600,
            color: Color(0xFF3D3366),
          ),
        ),
        SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(4),
          ),
          child: DropdownButtonFormField<String>(
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              border: InputBorder.none,
            ),
            value: value,
            isExpanded: true,
            dropdownColor: Colors.white,
            icon: Icon(Icons.arrow_drop_down, color: Color(0xFF3D3366)),
            style: TextStyle(color: Color(0xFF3D3366), fontSize: 14),
            onChanged: onChanged,
            items: items.map<DropdownMenuItem<String>>((String item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(item),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class Donor {
  final String name;
  final String bloodGroup;
  final String phone;
  final String state;
  final String district;
  final String city;
  final bool available;

  Donor({
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

  const DonorCard({Key? key, required this.donor}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 4,
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
                Text(
                  donor.name,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF3D3366),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: donor.available ? Colors.green : Colors.red,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    donor.available ? 'Available' : 'Not Available',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.bloodtype, color: Color(0xFFC14465)),
                SizedBox(width: 8),
                Text(
                  'Blood Group: ${donor.bloodGroup}',
                  style: TextStyle(color: Color(0xFF3D3366)),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.phone, color: Color(0xFFC14465)),
                SizedBox(width: 8),
                Text(
                  donor.phone,
                  style: TextStyle(color: Color(0xFF3D3366)),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.location_on, color: Color(0xFFC14465)),
                SizedBox(width: 8),
                Text(
                  '${donor.city}, ${donor.district}, ${donor.state}',
                  style: TextStyle(color: Color(0xFF3D3366)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
