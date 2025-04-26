import 'package:flutter/material.dart';

class AchievementPage extends StatefulWidget {
  const AchievementPage({Key? key}) : super(key: key);

  @override
  _AchievementPageState createState() => _AchievementPageState();
}

class _AchievementPageState extends State<AchievementPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentIndex = 0;

  final List<Achievement> achievements = [
    Achievement(
      title: "COVID-19 Plasma Therapy & Blood Donation",
      description: "With Honorable Governor Anandi Ben Patel during Lockdown Covid-19 for helping patients through Plasma Therapy & Blood Donation Camps",
      imageUrl: "assets/images/achievement1.jpeg",
    ),
    Achievement(
      title: "KGMU Cancer Patient Support",
      description: "With Deputy CM Brijesh Pathak, Col Puri Vice Chancellor (King George Medical University) & Governor Anandi Ben Patel at KGMU Medical College Lucknow for arranging Blood Donation Camps for Cancer Patients",
      imageUrl: "assets/images/achievement2.jpeg",
    ),
    Achievement(
      title: "Divine Heart Hospital Collaboration",
      description: "With Dr. AK Srivastava MD Divine Heart Hospital (Lucknow) for the Nobel Cause of Blood Donation",
      imageUrl: "assets/images/achievement3.jpeg",
    ),
    Achievement(
      title: "KGMU Blood Donation Initiative",
      description: "KGMU For Blood Donation Camps & Helping Patients In Dire Need Of Blood",
      imageUrl: "assets/images/achievement4.jpeg",
    ),
    Achievement(
      title: "World Book of Records Recognition",
      description: "World Book of Records participation certificate for Raktpurak Charitable Foundation",
      imageUrl: "assets/images/achievement5.jpeg",
    ),
    Achievement(
      title: "Media Coverage",
      description: "Media coverage of our blood donation initiatives and charitable activities",
      imageUrl: "assets/images/media1.jpeg",
    ),
    Achievement(
      title: "Media Recognition",
      description: "Press coverage highlighting our contributions to healthcare and community service",
      imageUrl: "assets/images/media2.jpeg",
    ),
    Achievement(
      title: "News Feature",
      description: "News feature on our ongoing efforts to support medical institutions and patients",
      imageUrl: "assets/images/media3.jpeg",
    ),
    Achievement(
      title: "Press Highlight",
      description: "Press highlighting our partnership with medical professionals and institutions",
      imageUrl: "assets/images/media4.jpeg",
    ),
    Achievement(
      title: "Media Spotlight",
      description: "Media spotlight on our foundation's recognition and impact",
      imageUrl: "assets/images/media5.jpeg",
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _currentIndex = _tabController.index;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get screen size for responsive layouts
    final Size screenSize = MediaQuery.of(context).size;
    final bool isTablet = screenSize.width > 600;
    final bool isLandscape = screenSize.width > screenSize.height;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(isTablet ? 120 : 110),
        child: AppBar(
          backgroundColor: const Color(0xFFD44C6D),
          title: const Text(
            'Our Achievements',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 22,
              color: Colors.white,
            ),
          ),
          centerTitle: true,
          elevation: 0,
          bottom: TabBar(
            controller: _tabController,
            indicatorWeight: 3,
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(
                icon: const Icon(Icons.emoji_events),
                text: isTablet ? 'Recognition & Awards' : 'Recognition',
              ),
              Tab(
                icon: const Icon(Icons.newspaper),
                text: 'Media Coverage',
              ),
            ],
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.pink[50] ?? Colors.pink.shade50,
              Colors.white,
            ],
          ),
        ),
        child: TabBarView(
          controller: _tabController,
          children: [
            // Recognition & Awards Tab
            buildAchievementGrid(0, 5, isTablet, isLandscape),
            // Media Coverage Tab
            buildAchievementGrid(5, 10, isTablet, isLandscape),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0, // Home selected
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

  Widget buildAchievementGrid(int start, int end, bool isTablet, bool isLandscape) {
    // Determine grid columns based on screen size and orientation
    int crossAxisCount = 2; // Default for phones in portrait
    
    if (isTablet) {
      crossAxisCount = isLandscape ? 4 : 3; // 4 columns on landscape tablet, 3 on portrait
    } else if (isLandscape) {
      crossAxisCount = 3; // 3 columns on landscape phone
    }
    
    // Adjust childAspectRatio for better card proportions
    double childAspectRatio = isTablet ? 0.8 : 0.7;

    return Padding(
      padding: EdgeInsets.all(isTablet ? 16.0 : 12.0),
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          childAspectRatio: childAspectRatio,
          crossAxisSpacing: isTablet ? 16 : 12,
          mainAxisSpacing: isTablet ? 16 : 12,
        ),
        itemCount: end - start,
        itemBuilder: (context, index) {
          final achievement = achievements[start + index];
          return buildAchievementCard(achievement, isTablet);
        },
      ),
    );
  }

  Widget buildAchievementCard(Achievement achievement, bool isTablet) {
    return GestureDetector(
      onTap: () => _showFullScreenImage(achievement),
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image section with fixed proportional height
            Expanded(
              flex: 3,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      achievement.imageUrl,
                      fit: BoxFit.cover,
                    ),
                    Positioned(
                      right: 8,
                      bottom: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Icon(
                          Icons.fullscreen,
                          color: Colors.white,
                          size: isTablet ? 24 : 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Text content section - fixed height to prevent overflow
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(15)),
              ),
              padding: EdgeInsets.all(isTablet ? 12.0 : 8.0),
              // Fixed height for text content to prevent overflow
              height: isTablet ? 100 : 80,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    achievement.title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: isTablet ? 16 : 13,
                      color: Colors.pink[700],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: isTablet ? 6 : 3),
                  Expanded(
                    child: Text(
                      achievement.description,
                      style: TextStyle(
                        fontSize: isTablet ? 14 : 11,
                        color: Colors.grey.shade700,
                      ),
                      maxLines: isTablet ? 3 : 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFullScreenImage(Achievement achievement) {
    final Size screenSize = MediaQuery.of(context).size;
    final bool isTablet = screenSize.width > 600;
    
    showDialog(
      context: context,
      builder: (context) => Dialog.fullscreen(
        child: Container(
          color: Colors.black,
          child: SafeArea(
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Image with pinch-to-zoom functionality
                InteractiveViewer(
                  minScale: 0.5,
                  maxScale: 3.0,
                  child: Center(
                    child: Hero(
                      tag: achievement.imageUrl,
                      child: Image.asset(
                        achievement.imageUrl,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
                // Close button
                Positioned(
                  top: isTablet ? 30 : 20,
                  right: isTablet ? 30 : 20,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: EdgeInsets.all(isTablet ? 12 : 8),
                      decoration: const BoxDecoration(
                        color: Colors.black45,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.close,
                        color: Colors.white,
                        size: isTablet ? 30 : 24,
                      ),
                    ),
                  ),
                ),
                // Caption at the bottom
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    color: const Color(0xFFD44C6D).withOpacity(0.8),
                    padding: EdgeInsets.symmetric(
                      horizontal: isTablet ? 24 : 16,
                      vertical: isTablet ? 16 : 12,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          achievement.title,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: isTablet ? 22 : 18,
                          ),
                        ),
                        SizedBox(height: isTablet ? 8 : 6),
                        Text(
                          achievement.description,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: isTablet ? 16 : 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class Achievement {
  final String title;
  final String description;
  final String imageUrl;

  Achievement({
    required this.title,
    required this.description,
    required this.imageUrl,
  });
}