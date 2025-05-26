import 'package:flutter/material.dart';
import 'donor_connect.dart';
import 'welcome_user.dart';

class BloodBankPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Blood Donation Services', style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFFC14465),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            // Navigate to homepage - replace with your homepage route
            Navigator.of(context).pushNamedAndRemoveUntil(
              '/', // Replace '/' with your homepage route name
              (Route<dynamic> route) => false,
            );
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
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
                  builder: (context) => DonorConnectPage()))
              ),
              SizedBox(height: 20),
              
              _buildServiceButton(
                context: context,
                label: 'Donor',
                onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => WelcomeUserPage()))
              ),
              
              SizedBox(height: 40),
              
              // Disclaimer Section
              Container(
                margin: EdgeInsets.symmetric(vertical: 10),
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFFF8F9FA),
                      Color(0xFFE8F4FD),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: Color(0xFFC14465).withOpacity(0.3),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 2,
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Color(0xFFC14465),
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: Icon(
                            Icons.info_outline,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        SizedBox(width: 12),
                        Text(
                          'Disclaimer',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF3D3366),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    
                    Container(
                      padding: EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Color(0xFFFFF3E0),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: Color(0xFFFF9800).withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.volunteer_activism,
                            color: Color(0xFFFF6B35),
                            size: 24,
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Blood Donation is 100% Free of Charge',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFE65100),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    SizedBox(height: 15),
                    
                    Text(
                      'This is a voluntary blood donation (sewaa) initiative. No money is involved at any stage — neither for the donor nor the recipient. The entire process is carried out purely for humanitarian and charitable purposes.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF555555),
                        height: 1.5,
                      ),
                    ),
                    
                    SizedBox(height: 12),
                    
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Color(0xFFFFEBEE),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Color(0xFFC14465).withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.block,
                            color: Color(0xFFC14465),
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'We strictly discourage and do not support any form of blood selling, buying, or compensation.',
                              style: TextStyle(
                                fontSize: 13,
                                color: Color(0xFFC14465),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    SizedBox(height: 15),
                    
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color(0xFF3D3366).withOpacity(0.1),
                            Color(0xFFC14465).withOpacity(0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Raktpurak Charitable Foundation operates this initiative solely as a service to society, in alignment with ethical and medical standards.',
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF3D3366),
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildServiceButton({
    required BuildContext context,
    required String label,
    required VoidCallback onPressed
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFFC14465),
        padding: EdgeInsets.symmetric(vertical: 15),
        minimumSize: Size(double.infinity, 60),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        elevation: 3,
      ),
      child: Text(
        label,
        style: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold
        ),
      ),
    );
  }
}