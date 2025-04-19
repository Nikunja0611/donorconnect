import 'package:flutter/material.dart';
import 'donor_connect.dart';
import 'welcome_user.dart';

class BloodBankPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text('Blood Bank Services', style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFFC14465),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Choose Your Service',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF3D3366),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 30),
            _buildServiceButton(
                context: context,
                label: 'Patient',
                onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => DonorConnectPage()))),
            SizedBox(height: 20),
            _buildServiceButton(
                context: context,
                label: 'Donor',
                onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => WelcomeUserPage()))),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceButton(
      {required BuildContext context,
      required String label,
      required VoidCallback onPressed}) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFFC14465),
        padding: EdgeInsets.symmetric(vertical: 15),
        minimumSize: Size(double.infinity, 60),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
            color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }
}
