import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ABOUT US', textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 28,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),),
        backgroundColor: const Color(0xFFE63946),
      ),
      drawer: buildDrawer(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                "ABOUT RCF",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
            const SizedBox(height: 20),
            buildSectionCard(
              title: "WELCOME TO RAKTPURAK CHARITABLE FOUNDATION",
              content:
                  "Raktpurak Charitable Foundation is a non-profit organization helping patients by providing blood donors during emergencies. Our mission is to spread awareness about Thalassemia and work towards building a 'Zero Thalassemia Country.'",
            ),
            const SizedBox(height: 30),
            buildTextSection("Our Mission",
                "At Raktpurak Charitable Foundation, we are committed to ensuring that no patient is left without the blood they need during critical moments."),
            const SizedBox(height: 20),
            buildTextSection("Our Vision",
                "We envision a world where Thalassemia is eliminated, and where all patients have immediate access to the blood they need."),
            const SizedBox(height: 30),
            const Text(
              "Our Initiatives",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1D3557),
              ),
            ),
            const SizedBox(height: 15),
            buildInitiativeCard(
              "Blood Donation Drives",
              "Regular blood donation camps are organized to ensure a steady supply of blood.",
            ),
            const SizedBox(height: 15),
            buildInitiativeCard(
              "Roti Bank",
              "Providing meals to underprivileged communities through voluntary contributions.",
            ),
            const SizedBox(height: 15),
            buildInitiativeCard(
              "Medical Equipment Support",
              "Offering wheelchairs, ventilators, and other essential equipment to those in need.",
            ),
            const SizedBox(height: 30),
            buildCallToAction(context),
            const SizedBox(height: 30),
            buildContactUsSection(context),
          ],
        ),
      ),
      bottomNavigationBar: buildBottomNavigationBar(context),
    );
  }

  Widget buildSectionCard({required String title, required String content}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1D3557),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            content,
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget buildTextSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1D3557),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          content,
          style: const TextStyle(fontSize: 16),
        ),
      ],
    );
  }

  Widget buildInitiativeCard(String title, String description) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFFE63946),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget buildCallToAction(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFA8DADC),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          const Text(
            "Join Our Cause",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1D3557),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            "Your contribution—whether through blood donation, volunteering, or financial support—can make a huge difference.",
            style: TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 15),
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/fundraising');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE63946),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text(
              "Support Us Today",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildContactUsSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Contact Us",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1D3557),
            ),
          ),
          const SizedBox(height: 15),
          const Text(
            "Connect with us on social media or reach out to us directly.",
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              buildSocialIcon(
                context: context,
                icon: FontAwesomeIcons.facebook,
                color: const Color(0xFF1877F2),
                url: 'https://facebook.com/raktpurak',
                label: 'Facebook',
              ),
              buildSocialIcon(
                context: context,
                icon: FontAwesomeIcons.linkedin,
                color: const Color(0xFF0A66C2),
                url: 'https://linkedin.com/company/raktpurak',
                label: 'LinkedIn',
              ),
              buildSocialIcon(
                context: context,
                icon: FontAwesomeIcons.whatsapp,
                color: const Color(0xFF25D366),
                url: 'https://wa.me/1234567890',
                label: 'WhatsApp',
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            "Email: info@raktpurak.org",
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 10),
          const Text(
            "Phone: +91 1234567890",
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 10),
          const Text(
            "Address: 123 Charity Road, Mumbai, India",
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget buildSocialIcon({
    required BuildContext context,
    required IconData icon,
    required Color color,
    required String url,
    required String label,
  }) {
    return InkWell(
      onTap: () async {
        _launchURL(context, url);
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: FaIcon(
          icon,
          color: color,
          size: 32,
        ),
      ),
    );
  }

  Future<void> _launchURL(BuildContext context, String urlString) async {
    try {
      final Uri url = Uri.parse(urlString);
      if (!await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      )) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not launch $urlString')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error launching URL: $e')),
      );
    }
  }

  Widget buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: Color(0xFFE63946)),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'Raktpurak Charitable Foundation',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Donate Blood, Save Lives',
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () {
              Navigator.pushReplacementNamed(context, '/home_screen');
            },
          ),
          ListTile(
            leading: const Icon(Icons.bloodtype),
            title: const Text('Blood Bank'),
            onTap: () {
              Navigator.pushReplacementNamed(context, '/blood_bank_page');
            },
          ),
        ],
      ),
    );
  }

  Widget buildBottomNavigationBar(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: 4, // Profile/About Us page
      selectedItemColor: Colors.pink[700],
      unselectedItemColor: Colors.pink[300],
      type: BottomNavigationBarType.fixed,
      onTap: (index) {
        switch (index) {
          case 0:
            Navigator.pushReplacementNamed(context, '/home_screen');
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
            // Current page, do nothing
            break;
        }
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(
            icon: Icon(Icons.medical_services), label: 'Medical Help'),
        BottomNavigationBarItem(icon: Icon(Icons.opacity), label: 'Blood Bank'),
        BottomNavigationBarItem(
            icon: Icon(Icons.volunteer_activism), label: 'Fundraising'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
      ],
    );
  }
}