import 'package:flutter/material.dart';

class FundraisingPage extends StatelessWidget {
  const FundraisingPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: AppBar(
          backgroundColor: const Color(0xFFD44C6D),
          centerTitle: true,
          title: const Text(
            'Fund Raising',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Fundraising Event Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.pink[50],
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'ROTI BANK EVENT',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.purple,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Raktapurak Charitable Foundation is organising the "Roti Bank," where people will voluntarily donate cooked meals to support the underprivileged, promoting care and humanity.',
                      style: TextStyle(fontSize: 14, color: Colors.black87),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          child: Image.asset(
                            'assets/images/roti_bank.jpeg',
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/event_details');
                          },
                          child: Row(
                            children: [
                              Text(
                                'View More',
                                style: TextStyle(
                                  color: Colors.purple[600],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Icon(Icons.arrow_forward_ios,
                                  size: 14, color: Colors.purple),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Event Images Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  eventImage('assets/images/donation1.jpeg'),
                  eventImage('assets/images/donation2.jpeg'),
                  eventImage('assets/images/donation3.jpeg'),
                ],
              ),

              const SizedBox(height: 16),

              // Fundraising Call-to-Action
              Center(
                child: GestureDetector(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'If you want to raise funds',
                        style: TextStyle(
                          color: Colors.purple[900],
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Icon(Icons.arrow_forward, color: Colors.purple),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // QR Code and Event Details
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 1,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Center(
                      child: Image.asset(
                        'assets/images/qr_code.jpeg',
                        height: 100,
                        width: 100,
                      ),
                    ),
                    const SizedBox(height: 16),
                    eventDetail(Icons.calendar_month, 'Date: 01-03-2025'),
                    eventDetail(Icons.access_time, 'Time: 11:00 am onwards'),
                    eventDetail(Icons.location_on, 'Venue: Shivaji Park'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 3, // Fundraising selected
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

  // Widget for event images
  Widget eventImage(String imagePath) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.asset(
        imagePath,
        width: 100,
        height: 80,
        fit: BoxFit.cover,
      ),
    );
  }

  // Widget for event details
  Widget eventDetail(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: Colors.pink[700], size: 20),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
