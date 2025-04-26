import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({Key? key}) : super(key: key);

  // Helper method to launch URLs with better error handling and fallback options
  Future<void> _launchURL(BuildContext context, String urlString) async {
    final Uri url = Uri.parse(urlString);
    try {
      // Try to launch with external application mode first
      if (!await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      )) {
        // Try alternative launch mode if first attempt fails
        if (!await launchUrl(
          url,
          mode: LaunchMode.platformDefault,
        )) {
          // Show error message if both attempts fail
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Could not open $urlString')),
            );
          }
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'ABOUT US',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFFE63946),
      ),
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
              Navigator.pushNamed(context, '/event_fund_page');
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
    // Multiple URL options for better compatibility
    // Web URLs
    final String facebookUrl = 'https://m.facebook.com/raktpurak';
    final String linkedinUrl =
        'https://in.linkedin.com/in/balraj-dhillon-a95719172';
    final String whatsappUrl =
        'https://api.whatsapp.com/send?phone=917607609777';

    // App-specific URLs (fallbacks)
    final String facebookAppUrl = 'fb://page/raktpurak';
    final String linkedinAppUrl =
        'https://in.linkedin.com/in/balraj-dhillon-a95719172';
    final String whatsappAppUrl = 'whatsapp://send?phone=917607609777';

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
                url: facebookUrl,
                appUrl: facebookAppUrl,
              ),
              buildSocialIcon(
                context: context,
                icon: FontAwesomeIcons.linkedin,
                color: const Color(0xFF0A66C2),
                url: linkedinUrl,
                appUrl: linkedinAppUrl,
              ),
              buildSocialIcon(
                context: context,
                icon: FontAwesomeIcons.whatsapp,
                color: const Color(0xFF25D366),
                url: whatsappUrl,
                appUrl: whatsappAppUrl,
              ),
            ],
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () => _launchURL(context, 'mailto:info@raktpurak.org'),
            child: const Row(
              children: [
                Icon(Icons.email, color: Color(0xFF1D3557)),
                SizedBox(width: 8),
                Text(
                  "Email: info@raktpurak.org",
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: () => _launchURL(context, 'tel:+917607609777'),
            child: const Row(
              children: [
                Icon(Icons.phone, color: Color(0xFF1D3557)),
                SizedBox(width: 8),
                Text(
                  "Phone: +91 7607609777",
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: () => _launchURL(context,
                'https://www.google.com/maps/dir//C-1415,+Alamnagar,+Rajajipuram,+Lucknow,+Uttar+Pradesh+226017/@26.8424919,80.7830519,12z/data=!4m8!4m7!1m0!1m5!1m1!1s0x399bff718606e7f3:0x1f01e5442179bd1c!2m2!1d80.8654534!2d26.8425158?entry=ttu&g_ep=EgoyMDI1MDQyMy4wIKXMDSoASAFQAw%3D%3D'),
            child: const Row(
              children: [
                Icon(Icons.location_on, color: Color(0xFF1D3557)),
                SizedBox(width: 8),
                Text(
                  "Address: C-1415, Alamnagar, \nRajajipuram, Lucknow, \nUttar Pradesh 226017",
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
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
    required String appUrl,
  }) {
    return InkWell(
      onTap: () async {
        // Try app-specific URL first
        try {
          final appUri = Uri.parse(appUrl);
          if (await canLaunchUrl(appUri)) {
            await launchUrl(appUri);
            return;
          }
        } catch (e) {
          // Silent catch - will try web URL next
        }

        // Fall back to web URL
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

  Widget buildBottomNavigationBar(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: 0,
      selectedItemColor: Colors.pink[700],
      unselectedItemColor: Colors.pink[300],
      type: BottomNavigationBarType.fixed,
      onTap: (index) {
        switch (index) {
          case 0:
            Navigator.pushReplacementNamed(context, '/home_screen');
            break;
          case 1:
            Navigator.pushReplacementNamed(context, '/blood_bank_page');
            break;
          case 2:
            Navigator.pushReplacementNamed(context, '/fundraising_page');
            break;
          case 3:
            Navigator.pushReplacementNamed(context, '/medical_help_page');
            break;
          case 4:
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
