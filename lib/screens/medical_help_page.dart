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
    'Bipap Machines', 'Oxygen Concentrator',
    'Oxygen Cylinder', 'Patient Beds', 'Wheel Chairs',
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
          colorScheme: ColorScheme.light(primary: primaryColor),
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
      _showSnackbar('You must be signed in to submit a request.', Colors.red);
      return;
    }
    if (selectedEquipments.isEmpty) {
      _showSnackbar('Please select at least one equipment.', Colors.red);
      return;
    }
    try {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      final userName = userDoc.data()?['name'] ?? 'Unknown';
      await FirebaseFirestore.instance.collection('medical_help').add({
        'requesterId': user.uid,
        'requesterName': userName,
        'equipments': selectedEquipments,
        'requestedDate': Timestamp.fromDate(selectedDate),
        'status': 'Pending',
        'timestamp': FieldValue.serverTimestamp(),
      });
      _showSnackbar('Request submitted successfully!', primaryColor);
      setState(() {
        selectedEquipments.clear();
        selectedDate = DateTime.now();
      });
    } catch (e) {
      _showSnackbar('Error submitting request: $e', Colors.red);
    }
  }

  void _showSnackbar(String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/');
        break;
      case 1:
        // Stay on medical help page - do nothing
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
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: width * 0.05, vertical: 20),
          child: Column(
            children: [
              const SizedBox(height: 10),
              Text(
                'MEDICAL HELP',
                style: TextStyle(
                  color: primaryColor,
                  fontSize: width > 600 ? 28 : 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              _buildIntroCard(width),
              _buildUserRequestsCard(),
              const SizedBox(height: 20),
              _buildRequestForm(width),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.pink[700],
        unselectedItemColor: Colors.pink[300],
        type: BottomNavigationBarType.fixed,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.medical_services), label: 'Medical Help'),
          BottomNavigationBarItem(
              icon: Icon(Icons.opacity), label: 'Blood Bank'),
          BottomNavigationBarItem(
              icon: Icon(Icons.volunteer_activism), label: 'Fundraising'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildIntroCard(double width) {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.medical_services, color: primaryColor, size: width > 600 ? 28 : 24),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'About Medical Equipment Rental',
                  style: TextStyle(
                    fontSize: width > 600 ? 20 : 18,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            'The Raktapurak Charitable Foundation provides medical equipment on a rental basis to those in need...',
            style: TextStyle(fontSize: width > 600 ? 16 : 14, color: Colors.grey[800]),
          ),
          const SizedBox(height: 10),
          Text(
            'How it works:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: accentColor),
          ),
          const SizedBox(height: 8),
          _buildStepItem('1', 'Select the equipment you need from the list below'),
          _buildStepItem('2', 'Choose the date when you need the equipment'),
          _buildStepItem('3', 'Submit your request and wait for approval'),
          _buildStepItem('4', 'Once approved, our team will contact you for delivery details'),
          const SizedBox(height: 10),
          Text(
            'Note: All equipment is provided on a first-come, first-served basis. Availability may vary.',
            style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey[700]),
          ),
        ],
      ),
    );
  }

  Widget _buildUserRequestsCard() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('medical_help')
          .where('requesterId', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
          .orderBy('timestamp', descending: true)
          .limit(3)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
          return _buildCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your Recent Requests',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: accentColor),
                ),
                const SizedBox(height: 8),
                ...snapshot.data!.docs.map((doc) {
                  var data = doc.data() as Map<String, dynamic>;
                  List<dynamic> equip = data['equipments'] ?? [];
                  String status = data['status'] ?? 'Pending';
                  Timestamp? ts = data['requestedDate'];
                  String date = ts != null ? '${ts.toDate().day}-${ts.toDate().month}-${ts.toDate().year}' : 'N/A';
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: _getStatusColor(status).withOpacity(0.2),
                        child: Icon(Icons.medical_services, color: _getStatusColor(status)),
                      ),
                      title: Text(
                        equip.length > 1 ? '${equip[0]} + ${equip.length - 1} more' : (equip.isEmpty ? 'No equipment' : equip[0]),
                        style: const TextStyle(fontSize: 14),
                      ),
                      subtitle: Text('Needed by: $date', style: const TextStyle(fontSize: 12)),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getStatusColor(status).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          status,
                          style: TextStyle(
                            color: _getStatusColor(status),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ],
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildRequestForm(double width) {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Request Medical Equipment',
            style: TextStyle(fontSize: width > 600 ? 20 : 18, fontWeight: FontWeight.bold, color: primaryColor),
          ),
          const SizedBox(height: 15),
          Text('Select Equipment:', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
          const SizedBox(height: 10),
          _buildEquipmentGrid(width),
          const SizedBox(height: 20),
          Text('Select Required Date:', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
          const SizedBox(height: 10),
          InkWell(
            onTap: () => _selectDate(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("${selectedDate.day}-${selectedDate.month}-${selectedDate.year}", style: const TextStyle(fontSize: 16)),
                  Icon(Icons.calendar_today, color: primaryColor),
                ],
              ),
            ),
          ),
          const SizedBox(height: 25),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: selectedEquipments.isNotEmpty ? _submitRequest : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Submit Request', style: TextStyle(fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEquipmentGrid(double width) {
    return Column(
      children: equipments.map((equipment) {
        final isSelected = selectedEquipments.contains(equipment);
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: InkWell(
            onTap: () {
              setState(() {
                if (isSelected) {
                  selectedEquipments.remove(equipment);
                } else {
                  selectedEquipments.add(equipment);
                }
              });
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: isSelected ? primaryColor.withOpacity(0.1) : Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isSelected ? primaryColor : Colors.grey.shade300,
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Checkbox(
                    value: isSelected,
                    onChanged: (bool? value) {
                      setState(() {
                        if (value == true) {
                          selectedEquipments.add(equipment);
                        } else {
                          selectedEquipments.remove(equipment);
                        }
                      });
                    },
                    activeColor: primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      equipment,
                      style: TextStyle(
                        fontSize: 16, // Increased font size
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        color: isSelected ? primaryColor : Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: child,
    );
  }

  Widget _buildStepItem(String stepNumber, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 11,
            backgroundColor: primaryColor,
            child: Text(stepNumber, style: const TextStyle(color: Colors.white, fontSize: 12)),
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(description, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved': return Colors.green;
      case 'in progress': return Colors.blue;
      case 'pending': return Colors.orange;
      case 'completed': return Colors.teal;
      case 'rejected':
      case 'cancelled': return Colors.red;
      default: return Colors.grey;
    }
  }
}