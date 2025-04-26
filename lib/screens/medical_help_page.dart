import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MedicalHelpPage extends StatefulWidget {
  const MedicalHelpPage({Key? key}) : super(key: key);

  @override
  State<MedicalHelpPage> createState() => _MedicalHelpPageState();
}

class _MedicalHelpPageState extends State<MedicalHelpPage> {
  DateTime selectedDate = DateTime.now();
  List<String> selectedEquipments = [];
  final List<String> equipments = [
    'Bipap Machines',
    'Cpap Machines',
    'Oxygen Concentrator',
    'Oxygen Cylinder',
    'Patient Beds',
    'Portable Suction Machines',
    'Air Mattress',
    'NIV Mask',
    'Wheel Chairs',
    'Patient Monitor',
    'Nebulizer',
    'BP Machine',
  ];
  int _selectedIndex = 1;

  final Color primaryColor = const Color(0xFFC14465);
  final Color accentColor = const Color(0xFF3D3366);
  final Color backgroundColor = const Color(0xFFFCF3F9);

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(
            primary: primaryColor,
            onPrimary: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null && picked != selectedDate) {
      setState(() => selectedDate = picked);
    }
  }

  Future<void> _submitRequest() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You must be signed in to submit a request.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (selectedEquipments.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one equipment.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      final userName = userDoc.data()?['name'] ?? 'Unknown';

      await FirebaseFirestore.instance.collection('medical_help').add({
        'requesterId': user.uid,
        'requesterName': userName,
        'equipments': selectedEquipments,
        'requestedDate': Timestamp.fromDate(selectedDate),
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Request submitted successfully!'),
          backgroundColor: primaryColor,
        ),
      );

      setState(() {
        selectedEquipments.clear();
        selectedDate = DateTime.now();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error submitting request: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    Text(
                      'MEDICAL HELP',
                      style: TextStyle(
                        color: primaryColor,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 30),
                    _buildCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Select the desired date',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF333333),
                            ),
                          ),
                          const SizedBox(height: 10),
                          GestureDetector(
                            onTap: () => _selectDate(context),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 15,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Colors.grey.shade300,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '${selectedDate.day.toString().padLeft(2, '0')}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.year}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Color(0xFF333333),
                                    ),
                                  ),
                                  Icon(
                                    Icons.calendar_today,
                                    color: primaryColor,
                                    size: 20,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'Select the Equipments Required',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF333333),
                            ),
                          ),
                          const SizedBox(height: 10),
                          ...equipments.map(_buildEquipmentOption),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _submitRequest,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor,
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text(
                                'SUBMIT REQUEST',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            BottomNavigationBar(
              items: const [
                BottomNavigationBarItem(
                    icon: Icon(Icons.home), label: 'Home'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.medical_services),
                    label: 'Medical Help'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.opacity), label: 'Blood Bank'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.volunteer_activism),
                    label: 'Fundraising'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.person), label: 'Profile'),
              ],
              currentIndex: _selectedIndex,
              selectedItemColor: Colors.pink[700],
              unselectedItemColor: Colors.pink[300],
              onTap: _onItemTapped,
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.white,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({required Widget child}) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        margin: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: child,
      );

  Widget _buildEquipmentOption(String equipment) {
    final bool isSelected = selectedEquipments.contains(equipment);
    return GestureDetector(
      onTap: () {
        setState(() {
          isSelected
              ? selectedEquipments.remove(equipment)
              : selectedEquipments.add(equipment);
        });
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? primaryColor.withOpacity(0.1)
              : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? primaryColor : Colors.grey.shade300,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.check_circle : Icons.circle_outlined,
              color: isSelected ? primaryColor : Colors.grey,
            ),
            const SizedBox(width: 10),
            Text(
              equipment,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? accentColor : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}