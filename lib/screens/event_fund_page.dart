import 'package:flutter/material.dart';

class EventFundPage extends StatelessWidget {
  const EventFundPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upcoming Campaign'
        
        ),
        backgroundColor: const Color(0xFFD44C6D),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Feed the Future Campaign',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF3D3366),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Join our “Feed the Future” campaign. We aim to collect donations '
              'to provide nutritious meals to underprivileged children across the city.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            Center(
              child: Image.asset(
                'assets/images/qr_code.jpeg',
                width: 200,
                height: 200,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Scan this QR code to contribute securely via our payment portal.',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 3, // Fundraising still selected contextually
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
}