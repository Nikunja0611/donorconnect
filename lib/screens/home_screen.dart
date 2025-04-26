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
        Navigator.pushNamed(context, '/home_screen');
        break;
      case 1:
        Navigator.pushNamed(context, '/medical_help_page');
        break;
      case 2:
        Navigator.pushNamed(context, '/blood_bank_page');
        break;
      case 3:
        Navigator.pushNamed(context, '/fundraising_page');
        break;
      case 4:
        Navigator.pushNamed(context, '/profile_page');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get the screen size for responsive design
    final screenSize = MediaQuery.of(context).size;
    final textScaleFactor = MediaQuery.of(context).textScaleFactor;
    
    // Calculate responsive font sizes
    final double titleFontSize = screenSize.width < 360 ? 20 : (screenSize.width < 400 ? 22 : 24);
    final double subtitleFontSize = 16 * (screenSize.width / 400).clamp(0.8, 1.2);
    final double bodyFontSize = 14 * (screenSize.width / 400).clamp(0.85, 1.1);
    final double smallFontSize = 12 * (screenSize.width / 400).clamp(0.9, 1.05);

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(70 + (screenSize.width < 360 ? 10 : 0)),
        child: AppBar(
          backgroundColor: const Color(0xFFD44C6D),
          centerTitle: true,
          title: Column(
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  'RAKTPURAK CHARITABLE FOUNDATION',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: titleFontSize,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    height: 1.1,
                  ),
                ),
              ),
              if (!isLoading)
                Text(
                  'Welcome, $userName',
                  style: TextStyle(
                    color: Colors.white, 
                    fontSize: subtitleFontSize,
                  ),
                ),
            ],
          ),
          actions: [
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
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                            fontSize: subtitleFontSize * 1.1,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 5),
                        RichText(
                          text: TextSpan(
                            style: TextStyle(
                              color: Colors.grey[800], 
                              fontSize: bodyFontSize,
                            ),
                            children: const [
                              TextSpan(
                                text: 'Your one blood donation can be someone\'s second ',
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
                      height: 60,
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
                      fontSize: subtitleFontSize,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/about_us_page');
                    },
                    child: Text(
                      'View More',
                      style: TextStyle(
                        color: Colors.pink[400],
                        fontSize: bodyFontSize,
                      ),
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
                  height: screenSize.width * 0.5, // Responsive height
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
                      fontSize: subtitleFontSize,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ImageSlideshow(
                    width: double.infinity,
                    height: screenSize.width * 0.4, // Responsive height
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
                                height: screenSize.width * 0.4,
                                width: screenSize.width * 0.3,
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
                                        fontSize: subtitleFontSize,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      event['date'],
                                      style: TextStyle(
                                        fontSize: smallFontSize,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      event['location'],
                                      style: TextStyle(fontSize: smallFontSize),
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
                      fontSize: subtitleFontSize,
                      fontWeight: FontWeight.w600,
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
                        height: 100,
                        width: screenSize.width * 0.3,
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
                                fontSize: subtitleFontSize,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              'Blood Donation Drive',
                              style: TextStyle(fontSize: bodyFontSize),
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
                          fontSize: subtitleFontSize,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          // Navigate to detailed achievements page
                          Navigator.pushNamed(context, '/achievement_page');
                        },
                        child: Text(
                          'View All',
                          style: TextStyle(
                            color: Colors.pink[400],
                            fontSize: bodyFontSize,
                          ),
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
            
            // Added Achievements Cards from first home screen
            SizedBox(
              height: screenSize.width * 0.6, // Responsive height
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: achievements.length,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemBuilder: (context, index) {
                  final achievement = achievements[index];
                  return Container(
                    width: screenSize.width * 0.5, // Responsive width
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
                        // Achievement image
                        ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(12),
                            topRight: Radius.circular(12),
                          ),
                          child: Image.asset(
                            achievement['image'],
                            height: screenSize.width * 0.28, // Responsive height
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                        // Achievement details
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                achievement['title'],
                                style: TextStyle(
                                  color: Colors.pink[700],
                                  fontSize: bodyFontSize,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                achievement['description'],
                                style: TextStyle(
                                  fontSize: smallFontSize,
                                  color: Colors.grey[800],
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
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
                                    fontSize: smallFontSize,
                                    color: Colors.pink[700],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            
            // Bottom padding
            const SizedBox(height: 16),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.pink[700],
        unselectedItemColor: Colors.pink[300],
        type: BottomNavigationBarType.fixed,
        onTap: _onTabTapped,
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
}