import 'package:flutter/material.dart';

class MedicalHelpPage extends StatefulWidget {
  const MedicalHelpPage({Key? key}) : super(key: key);

  @override
  State<MedicalHelpPage> createState() => _MedicalHelpPageState();
}

class _MedicalHelpPageState extends State<MedicalHelpPage> {
  DateTime selectedDate = DateTime.now();
  String? selectedEquipment;
  List<String> equipments = ['VENTILATOR', 'WHEELCHAIR', 'WALKER / CRUTCHES'];
  int _selectedIndex = 1; // Index for Medical Help page

  // Define color scheme
  final Color primaryColor = const Color(0xFFC14465); // Deep rose/burgundy
  final Color accentColor = const Color(0xFF3D3366); // Deep indigo/purple
  final Color backgroundColor = const Color(0xFFFCF3F9); // Very light pink

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: primaryColor,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // Navigation logic
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/home_screen');
        break;
      case 1:
        // Current page, do nothing
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
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      Text(
                        'MEDICAL HELP',
                        style: TextStyle(
                          color: primaryColor,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 30),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
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
                            const SizedBox(height: 15),
                            GestureDetector(
                              onTap: () => _selectDate(context),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 15,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                  ),
                                  borderRadius: BorderRadius.circular(5),
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
                            const SizedBox(height: 30),
                            const Text(
                              'Select the Equipments Required',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF333333),
                              ),
                            ),
                            const SizedBox(height: 15),
                            ...equipments
                                .map((equipment) =>
                                    _buildEquipmentOption(equipment))
                                .toList(),
                            const SizedBox(height: 30),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {
                                  if (selectedEquipment != null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: const Text(
                                            'Confirmation and details will be notified soon!!'),
                                        backgroundColor: primaryColor,
                                      ),
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content:
                                            Text('Please select an equipment'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryColor,
                                  foregroundColor: Colors.white,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 15),
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
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.medical_services),
            label: 'Medical Help',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.water_drop),
            label: 'Blood Bank',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.volunteer_activism),
            label: 'Fundraising',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.pink[700],
        unselectedItemColor: Colors.pink[300],
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white, // White background for nav bar
      ),
    );
  }

  Widget _buildEquipmentOption(String equipment) {
    final bool isSelected = selectedEquipment == equipment;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedEquipment = equipment;
        });
      },
      child: ListTile(
        leading: Icon(
          isSelected ? Icons.check_circle : Icons.circle_outlined,
          color: isSelected ? primaryColor : Colors.grey,
        ),
        title: Text(
          equipment,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? accentColor : Colors.black,
          ),
        ),
      ),
    );
  }
}
