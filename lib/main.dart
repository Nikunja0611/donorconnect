import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'services/auth_service.dart';
import 'services/donation_service.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/medical_help_page.dart';
import 'screens/blood_bank_page.dart';
import 'screens/fundraising_page.dart';
import 'screens/profile_page.dart';
import 'screens/about_us_page.dart';
import 'screens/donor_connect.dart';
import 'screens/welcome_user.dart';
import 'screens/donation_history_page.dart';
import 'screens/admin_login_screen.dart'; // Import admin login screen
import 'screens/admin_dashboard.dart'; // Import admin dashboard
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthService>(
          create: (_) => AuthService(),
        ),
        Provider<DonationService>(
          create: (_) => DonationService(),
        ),
        StreamProvider(
          create: (context) => FirebaseFirestore.instance
              .collection('users')
              .snapshots(),
          initialData: null,
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Raktapurak Charitable Foundation',
        theme: ThemeData(
          primarySwatch: MaterialColor(0xFFC14465, {
            50: Color(0xFFFCE4EA),
            100: Color(0xFFF8BBCD),
            200: Color(0xFFF48BAE),
            300: Color(0xFFF05B8F),
            400: Color(0xFFC14465),
            500: Color(0xFFA12D4F),
            600: Color(0xFF8B1E3F),
            700: Color(0xFF72162F),
            800: Color(0xFF5A0E1F),
            900: Color(0xFF420910),
          }),
          scaffoldBackgroundColor: Color(0xFFF8ECF1),
          fontFamily: 'Poppins',
          appBarTheme: AppBarTheme(
            backgroundColor: Color(0xFFD95373),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFD95373),
            ),
          ),
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => AuthWrapper(),
          '/login': (context) => LoginScreen(),
          '/register': (context) => RegisterScreen(),
          '/home_screen': (context) => HomePage(),
          '/medical_help_page': (context) => MedicalHelpPage(),
          '/blood_bank_page': (context) => BloodBankPage(),
          '/fundraising_page': (context) => FundraisingPage(),
          '/profile_page': (context) => ProfilePage(),
          '/about_us_page': (context) => AboutUsPage(),
          '/donor_connect_page': (context) => DonorConnectPage(),
          '/welcome_user': (context) => WelcomeUserPage(),
          '/donation_history_page': (context) => DonationHistoryPage(),
          '/admin_login': (context) => AdminLoginScreen(), // Added admin login route
          '/admin_dashboard': (context) => AdminDashboard(), // Added admin dashboard route
        },
        onUnknownRoute: (settings) {
          return MaterialPageRoute(
            builder: (context) => Scaffold(
              body: Center(child: Text("404! Page not found: ${settings.name}")),
            ),
          );
        },
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          final user = snapshot.data;
          return user != null ? HomePage() : LoginScreen();
        }
        return Scaffold(
          body: Center(
            child: CircularProgressIndicator(
              color: Color(0xFFC14465),
            ),
          ),
        );
      },
    );
  }
}