import 'package:flutter/material.dart';

class FundraisingPage extends StatelessWidget {
  const FundraisingPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions for responsive layouts
    final Size screenSize = MediaQuery.of(context).size;
    final bool isTablet = screenSize.width > 600;
    
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(isTablet ? 80 : 70),
        child: AppBar(
          backgroundColor: const Color(0xFFD44C6D),
          centerTitle: true,
          elevation: 4.0,
          automaticallyImplyLeading: false, // Remove back button
          title: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Fund Raising',
                style: TextStyle(
                  fontSize: isTablet ? 26 : 20, 
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                  color: Colors.white,
                ),
              ),
              Text(
                'Make a difference today',
                style: TextStyle(
                  fontSize: isTablet ? 16 : 12,
                  fontWeight: FontWeight.w300,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(isTablet ? 24.0 : 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header section
              Container(
                padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
                decoration: BoxDecoration(
                  color: Colors.pink[50],
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  children: [
                    Icon(Icons.volunteer_activism, color: const Color(0xFFD44C6D), size: isTablet ? 32 : 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Your generosity can change lives. Every contribution counts!',
                        style: TextStyle(
                          fontSize: isTablet ? 18 : 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.purple[900],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              // Roti Bank section
              _enhancedInfoSection(
                context: context,
                image: 'assets/images/roti_bank.jpeg',
                title: 'Roti Bank Initiative',
                text: 'Raktpurak Charitable Foundation offers a helping hand by arranging "Roti Bank" '
                    'in which people can voluntarily contribute cooked meals for the weaker sections of the society '
                    'and spread the message of care and humanity. Date, place and time is informed to the members well '
                    'in advance so that they can generously take part and share a meal. Reach out to us day or night; '
                    'we are there to help you and your loved ones!',
                imageLeft: false,
                isTablet: isTablet,
              ),
              const SizedBox(height: 24),
              
              // Quote 1
              _enhancedInfoSection(
                context: context,
                image: 'assets/images/donation1.jpeg',
                title: 'Make an Impact',
                text: '"Helping one person might not change the world, but it could change the world for one person." '
                    'Every meal served is a step toward a kinder world.',
                imageLeft: true,
                isTablet: isTablet,
              ),
              const SizedBox(height: 24),
              
              // Quote 2
              _enhancedInfoSection(
                context: context,
                image: 'assets/images/donation2.jpeg',
                title: 'The Joy of Giving',
                text: '"No one has ever become poor by giving." – Anne Frank\nJoin hands with us to feed the hungry '
                    'and show them that humanity still thrives.',
                imageLeft: false,
                isTablet: isTablet,
              ),
              const SizedBox(height: 24),
              
              // Quote 3
              _enhancedInfoSection(
                context: context,
                image: 'assets/images/donation3.jpeg',
                title: 'Together We Can',
                text: '"We cannott help everyone, but everyone can help someone." – Ronald Reagan\nLet us unite to ensure '
                    'no one sleeps hungry tonight.',
                imageLeft: true,
                isTablet: isTablet,
              ),
              
              const SizedBox(height: 30),
              
              // Call to action button
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, '/event_fund_page');
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        spreadRadius: 1,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                    border: Border.all(color: const Color(0xFFD44C6D), width: 1.5),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Raise Funds For A Cause',
                        style: TextStyle(
                          color: Colors.purple[900],
                          fontSize: isTablet ? 18 : 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward_rounded, color: Color(0xFFD44C6D)),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 40),
              
              // Disclaimer section
              Container(
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.red[200]!, width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.red[700], size: isTablet ? 28 : 24),
                        const SizedBox(width: 12),
                        Text(
                          'Disclaimer',
                          style: TextStyle(
                            fontSize: isTablet ? 22 : 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.red[700],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Blood Donation is 100% Free of Charge',
                      style: TextStyle(
                        fontSize: isTablet ? 18 : 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.red[800],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'This is a voluntary blood donation (sewaa) initiative. No money is involved at any stage — neither for the donor nor the recipient. The entire process is carried out purely for humanitarian and charitable purposes. We strictly discourage and do not support any form of blood selling, buying, or compensation.\n\nRaktpurak Charitable Foundation operates this initiative solely as a service to society, in alignment with ethical and medical standards.',
                      style: TextStyle(
                        fontSize: isTablet ? 16 : 14,
                        height: 1.6,
                        color: Colors.red[800],
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 30),
              
              // Blood donation registration button
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, '/blood_donation_request');
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 24.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        spreadRadius: 1,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                    border: Border.all(color: const Color(0xFFD44C6D), width: 1.5),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.app_registration, color: const Color(0xFFD44C6D), size: isTablet ? 22 : 20),
                      const SizedBox(width: 12),
                      Flexible(
                        child: Text(
                          'Register With Us For Blood Donation Camps/Drives In Your Society',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.purple[900],
                            fontSize: isTablet ? 16 : 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward_rounded, color: Color(0xFFD44C6D)),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 3,
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
              // Already on fundraising page
              break;
            case 4:
              Navigator.pushReplacementNamed(context, '/profile_page');
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.medical_services), 
            label: 'Medical Help'
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.opacity), 
            label: 'Blood Bank'
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.volunteer_activism), 
            label: 'Fundraising'
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person), 
            label: 'Profile'
          ),
        ],
      ),
    );
  }

  Widget _enhancedInfoSection({
    required BuildContext context,
    required String image,
    required String title,
    required String text,
    required bool imageLeft,
    required bool isTablet,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: isTablet
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: imageLeft
                  ? [
                      _enhancedImageBox(image, isTablet),
                      const SizedBox(width: 20),
                      Expanded(child: _enhancedTextBox(title, text, isTablet)),
                    ]
                  : [
                      Expanded(child: _enhancedTextBox(title, text, isTablet)),
                      const SizedBox(width: 20),
                      _enhancedImageBox(image, isTablet),
                    ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(child: _enhancedImageBox(image, isTablet)),
                const SizedBox(height: 16),
                _enhancedTextBox(title, text, isTablet),
              ],
            ),
    );
  }

  Widget _enhancedImageBox(String path, bool isTablet) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.asset(
          path,
          width: isTablet ? 180 : 160,
          height: isTablet ? 180 : 160,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _enhancedTextBox(String title, String text, bool isTablet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: isTablet ? 20 : 18,
            fontWeight: FontWeight.bold,
            color: const Color(0xFFD44C6D),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          text,
          style: TextStyle(
            fontSize: isTablet ? 16 : 14,
            height: 1.5,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}