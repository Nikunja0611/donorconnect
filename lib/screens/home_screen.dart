import 'package:flutter/material.dart';
import 'package:flutter_image_slideshow/flutter_image_slideshow.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  String userName = "User";
  bool isLoading = true;
  bool isAdmin = false;

  final List<String> images = [
    'assets/images/blood_donation.jpg',
    'assets/images/donor_2.jpg',
    'assets/images/blood_drive.jpg',
  ];

  final List<Map<String, dynamic>> featuredEvents = [
    {
      'title': 'World Blood Donor Day',
      'image': 'assets/images/blood_drive.jpg',
      'date': 'June 14, 2025',
      'location': 'City Community Center'
    },
    {
      'title': 'Campus Blood Drive',
      'image': 'assets/images/donor_2.jpg',
      'date': 'May 10, 2025',
      'location': 'University Campus'
    },
    {
      'title': 'Corporate Donation Camp',
      'image': 'assets/images/blood_donation.jpg',
      'date': 'May 25, 2025',
      'location': 'Tech Park'
    },
  ];

  final List<Map<String, dynamic>> achievements = [
    {
      'title': "COVID-19 Plasma Therapy & Blood Donation",
      'description': "With Honorable Governor Anandi Ben Patel during Lockdown Covid-19 ",
      'image': "assets/images/achievement1.jpeg",
      'year': "2022"
    },
    {
      'title': "News Feature",
      'description': "News feature on our ongoing efforts to support patients",
      'image': "assets/images/media3.jpeg",
      'year': "2023"
    },
    {
      'title': "World Book of Records Recognition",
      'description': "World Book of Records participation certificate ",
      'image': "assets/images/achievement5.jpeg",
      'year': "2024"
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final userData = await authService.getCurrentUserData();
    
    if (userData != null && userData.containsKey('name')) {
      setState(() {
        userName = userData['name'];
        isAdmin = userData['isAdmin'] == true;
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });

    switch (index) {
      case 0:
        // We're already on home page, no need to navigate
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
    // Get screen dimensions for responsive layouts
    final Size screenSize = MediaQuery.of(context).size;
    final bool isTablet = screenSize.width > 600;
    
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(isTablet ? 80 : 70),
        child: AppBar(
          backgroundColor: const Color(0xFFD44C6D),
          centerTitle: true,
          title: Column(
            children: [
              Text(
                'RAKTPURAK CHARITABLE FOUNDATION',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: isTablet ? 30 : 22,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (!isLoading)
                Text(
                  'Welcome, $userName',
                  style: TextStyle(color: Colors.white, fontSize: isTablet ? 22 : 16),
                ),
            ],
          ),
          actions: [
            // Admin dashboard button (shows only for admins)
            if (isAdmin)
              IconButton(
                icon: const Icon(Icons.dashboard),
                tooltip: 'Admin Dashboard',
                onPressed: () {
                  Navigator.pushNamed(context, '/admin_dashboard');
                },
              ),
            IconButton(
              icon: const Icon(Icons.person),
              onPressed: () {
                Navigator.pushNamed(context, '/profile_page');
              },
            ),
          ],
        ),
      ),
      body: SafeArea(
        bottom: false, // Don't apply bottom padding as BottomNavigationBar handles it
        child: ListView(
          // Using ListView instead of SingleChildScrollView for better performance
          padding: EdgeInsets.only(
            bottom: kBottomNavigationBarHeight + 16, // Add padding at bottom
          ),
          children: [
            // Blood Donation Card
            Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.pink[50],
                borderRadius: BorderRadius.circular(15),
              ),
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Blood Donation',
                          style: TextStyle(
                            color: Colors.purple[900],
                            fontSize: isTablet ? 22 : 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 5),
                        RichText(
                          text: TextSpan(
                            style: TextStyle(
                              color: Colors.grey[800], 
                              fontSize: isTablet ? 16 : 14
                            ),
                            children: const [
                              TextSpan(
                                text: 'Your one blood donation can be someone\'s second '
                              ),
                              TextSpan(
                                text: 'chance at life',
                                style: TextStyle(color: Colors.purple),
                              ),
                              TextSpan(text: '. Be a hero—donate today!'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Image.asset(
                      'assets/images/logo.png',
                      height: isTablet ? 80 : 60,
                    ),
                  ),
                ],
              ),
            ),

            // A Peek into Our Motive
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'A Peek into Our Motive',
                    style: TextStyle(
                      color: Colors.deepPurple, 
                      fontSize: isTablet ? 20 : 18, 
                      fontWeight: FontWeight.w600
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/about_us_page');
                    },
                    child: Text(
                      'View More',
                      style: TextStyle(color: Colors.pink[400]),
                    ),
                  ),
                ],
              ),
            ),

            // Image Slideshow
            Container(
              margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: ImageSlideshow(
                  width: double.infinity,
                  height: isTablet ? 250 : 200,
                  initialPage: 0,
                  indicatorColor: Colors.pink,
                  indicatorBackgroundColor: Colors.grey,
                  autoPlayInterval: 5000,
                  isLoop: true,
                  children: images.map((item) {
                    return Image.asset(
                      item,
                      fit: BoxFit.cover,
                    );
                  }).toList(),
                ),
              ),
            ),

            // Featured Events
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Featured Events',
                    style: TextStyle(
                      color: Colors.deepPurple, 
                      fontSize: isTablet ? 20 : 18, 
                      fontWeight: FontWeight.w600
                    ),
                  ),
                  const SizedBox(height: 10),
                  ImageSlideshow(
                    width: double.infinity,
                    height: isTablet ? 180 : 150,
                    initialPage: 0,
                    indicatorColor: Colors.pink,
                    indicatorBackgroundColor: Colors.grey,
                    onPageChanged: (value) {},
                    autoPlayInterval: 6000,
                    isLoop: true,
                    children: featuredEvents.map((event) {
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              spreadRadius: 1,
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(12),
                                bottomLeft: Radius.circular(12),
                              ),
                              child: Image.asset(
                                event['image'],
                                height: isTablet ? 180 : 150,
                                width: isTablet ? 150 : 120,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      event['title'],
                                      style: TextStyle(
                                        color: Colors.pink[400],
                                        fontSize: isTablet ? 20 : 18,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      event['date'],
                                      style: TextStyle(
                                        fontSize: isTablet ? 16 : 14,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      event['location'],
                                      style: TextStyle(fontSize: isTablet ? 16 : 14),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),

            // Upcoming Events
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Upcoming Events',
                    style: TextStyle(
                      color: Colors.deepPurple, 
                      fontSize: isTablet ? 20 : 18, 
                      fontWeight: FontWeight.w600
                    ),
                  ),
                  Container(
                    height: 1,
                    color: Colors.grey[300],
                    margin: const EdgeInsets.only(right: 16),
                  ),
                ],
              ),
            ),

            // Hospital Event Card
            GestureDetector(
              onTap: () {
                // Handle tap on hospital event card
              },
              child: Container(
                margin: const EdgeInsets.all(16),
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
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        bottomLeft: Radius.circular(12),
                      ),
                      child: Image.asset(
                        'assets/images/hospital.jpg',
                        height: isTablet ? 120 : 100,
                        width: isTablet ? 140 : 120,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hospital',
                              style: TextStyle(
                                color: Colors.pink[400],
                                fontSize: isTablet ? 20 : 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              'Blood Donation Drive',
                              style: TextStyle(fontSize: isTablet ? 18 : 16),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Added Achievements Section from first home screen
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Our Achievements',
                        style: TextStyle(
                          color: Colors.deepPurple, 
                          fontSize: isTablet ? 20 : 18, 
                          fontWeight: FontWeight.w600
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          // Navigate to detailed achievements page
                          Navigator.pushNamed(context, '/achievement_page');
                        },
                        child: Text(
                          'View All',
                          style: TextStyle(color: Colors.pink[400]),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    height: 1,
                    color: Colors.grey[300],
                    margin: const EdgeInsets.only(top: 4, bottom: 12),
                  ),
                ],
              ),
            ),
            
            // UPDATED Achievements Cards - Fixed to prevent overflow
            Container(
              height: isTablet ? screenSize.height * 0.32 : screenSize.height * 0.33,
              margin: const EdgeInsets.only(bottom: 24),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const ClampingScrollPhysics(),
                itemCount: achievements.length,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemBuilder: (context, index) {
                  final achievement = achievements[index];
                  return LayoutBuilder(
                    builder: (context, constraints) {
                      return Container(
                        width: isTablet ? 240 : 200,
                        constraints: BoxConstraints(
                          maxHeight: constraints.maxHeight - 16,
                        ),
                        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
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
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Achievement image with adaptive height
                            ClipRRect(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(12),
                                topRight: Radius.circular(12),
                              ),
                              child: Image.asset(
                                achievement['image'],
                                height: isTablet ? 130 : constraints.maxHeight * 0.45,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                            // Achievement details in an Expanded widget to prevent overflow
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      achievement['title'],
                                      style: TextStyle(
                                        color: Colors.pink[700],
                                        fontSize: isTablet ? 16 : 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Expanded(
                                      child: Text(
                                        achievement['description'],
                                        style: TextStyle(
                                          fontSize: isTablet ? 14 : 12,
                                          color: Colors.grey[800],
                                        ),
                                        maxLines: 3,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.pink[50],
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        achievement['year'],
                                        style: TextStyle(
                                          fontSize: isTablet ? 14 : 12,
                                          color: Colors.pink[700],
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.pink[700],
        unselectedItemColor: Colors.pink[300],
        type: BottomNavigationBarType.fixed,
        onTap: _onTabTapped,
        items: [
          const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: const Icon(Icons.medical_services), 
              label: isTablet ? 'Medical Help' : 'Medical'),
          const BottomNavigationBarItem(
              icon: Icon(Icons.opacity), label: 'Blood Bank'),
          BottomNavigationBarItem(
              icon: const Icon(Icons.volunteer_activism), 
              label: isTablet ? 'Fundraising' : 'Fundraising'),
          const BottomNavigationBarItem(
              icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}