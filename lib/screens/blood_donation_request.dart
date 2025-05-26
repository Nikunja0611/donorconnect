import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BloodDonationRequestPage extends StatelessWidget {
  const BloodDonationRequestPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final bool isTablet = screenSize.width > 600;
    
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(isTablet ? 80 : 70),
        child: AppBar(
          backgroundColor: const Color(0xFFD44C6D),
          centerTitle: true,
          elevation: 4.0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Blood Donation Camp',
                style: TextStyle(
                  fontSize: isTablet ? 24 : 20, 
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                  color: Colors.white,
                ),
              ),
              Text(
                'Request Partnership',
                style: TextStyle(
                  fontSize: isTablet ? 14 : 12,
                  fontWeight: FontWeight.w300,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: BloodDonationRequestForm(isTablet: isTablet),
      ),
    );
  }
}

class BloodDonationRequestForm extends StatefulWidget {
  final bool isTablet;
  
  const BloodDonationRequestForm({Key? key, required this.isTablet}) : super(key: key);

  @override
  State<BloodDonationRequestForm> createState() => _BloodDonationRequestFormState();
}

class _BloodDonationRequestFormState extends State<BloodDonationRequestForm> {
  bool _isSubmitting = false;
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _organizationController = TextEditingController();
  final _addressController = TextEditingController();
  final _expectedParticipantsController = TextEditingController();
  final _preferredDateController = TextEditingController();
  final _additionalNotesController = TextEditingController();
  
  DateTime? _selectedPreferredDate;

  @override
  void dispose() {
    _phoneController.dispose();
    _organizationController.dispose();
    _addressController.dispose();
    _expectedParticipantsController.dispose();
    _preferredDateController.dispose();
    _additionalNotesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(widget.isTablet ? 24.0 : 16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(widget.isTablet ? 24.0 : 20.0),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFFD44C6D),
                    const Color(0xFFE06B8A),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFD44C6D).withOpacity(0.3),
                    spreadRadius: 0,
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.favorite,
                          color: Colors.white,
                          size: widget.isTablet ? 32 : 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          'Host a Blood Donation Camp with Raktpurak Charitable Foundation',
                          style: TextStyle(
                            fontSize: widget.isTablet ? 22 : 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            height: 1.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Join our mission to save lives through 100% free and voluntary blood donation. This initiative is a sewaa-based effort— no money is exchanged at any stage, either by donors or recipients.',
                    style: TextStyle(
                      fontSize: widget.isTablet ? 16 : 14,
                      color: Colors.white.withOpacity(0.95),
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: EdgeInsets.all(widget.isTablet ? 16 : 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.block,
                          color: Colors.white,
                          size: widget.isTablet ? 20 : 18,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'We strictly prohibit any form of blood selling, buying, or compensation.',
                            style: TextStyle(
                              fontSize: widget.isTablet ? 15 : 13,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Form Section
            Container(
              padding: EdgeInsets.all(widget.isTablet ? 24 : 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 0,
                    blurRadius: 20,
                    offset: const Offset(0, 5),
                  ),
                ],
                border: Border.all(
                  color: const Color(0xFFD44C6D).withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD44C6D).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.volunteer_activism,
                          color: const Color(0xFFD44C6D),
                          size: widget.isTablet ? 24 : 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Request Details',
                        style: TextStyle(
                          fontSize: widget.isTablet ? 22 : 18,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFFD44C6D),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Phone Number Field
                  _buildTextField(
                    controller: _phoneController,
                    label: 'Phone Number *',
                    hint: 'Enter your phone number',
                    icon: Icons.phone,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Phone number is required';
                      }
                      if (value.trim().length < 10) {
                        return 'Please enter a valid phone number';
                      }
                      return null;
                    },
                    keyboardType: TextInputType.phone,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Organization Name Field
                  _buildTextField(
                    controller: _organizationController,
                    label: 'Organization/Institution Name *',
                    hint: 'Enter your organization name',
                    icon: Icons.business,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Organization name is required';
                      }
                      return null;
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Address Field
                  _buildTextField(
                    controller: _addressController,
                    label: 'Address *',
                    hint: 'Enter the complete address where camp will be held',
                    icon: Icons.location_on,
                    maxLines: 2,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Address is required';
                      }
                      return null;
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Expected Participants Field
                  _buildTextField(
                    controller: _expectedParticipantsController,
                    label: 'Expected Participants',
                    hint: 'Approximate number of expected donors',
                    icon: Icons.people,
                    keyboardType: TextInputType.number,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Preferred Date Field
                  _buildTextField(
                    controller: _preferredDateController,
                    label: 'Preferred Date',
                    hint: 'Select your preferred date',
                    icon: Icons.calendar_today,
                    readOnly: true,
                    onTap: () => _selectDate(context),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Additional Notes Field
                  _buildTextField(
                    controller: _additionalNotesController,
                    label: 'Additional Notes',
                    hint: 'Any additional information or special requirements',
                    icon: Icons.note,
                    maxLines: 3,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Submit Button
            Container(
              width: double.infinity,
              height: widget.isTablet ? 60 : 55,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFFD44C6D),
                    const Color(0xFFE06B8A),
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFD44C6D).withOpacity(0.4),
                    spreadRadius: 0,
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitRequest,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: _isSubmitting
                    ? CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.send,
                            color: Colors.white,
                            size: widget.isTablet ? 24 : 20,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Submit Request',
                            style: TextStyle(
                              fontSize: widget.isTablet ? 20 : 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Footer Note
            Container(
              padding: EdgeInsets.all(widget.isTablet ? 16 : 12),
              decoration: BoxDecoration(
                color: Colors.pink[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFD44C6D).withOpacity(0.2),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: const Color(0xFFD44C6D),
                    size: widget.isTablet ? 20 : 18,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Our team will contact you within 2-3 business days to discuss the details and coordinate the blood donation camp.',
                      style: TextStyle(
                        fontSize: widget.isTablet ? 14 : 12,
                        color: const Color(0xFFD44C6D),
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int maxLines = 1,
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      maxLines: maxLines,
      readOnly: readOnly,
      onTap: onTap,
      style: TextStyle(
        fontSize: widget.isTablet ? 16 : 14,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(
          icon,
          color: const Color(0xFFD44C6D),
          size: widget.isTablet ? 24 : 20,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Colors.grey[300]!,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: const Color(0xFFD44C6D),
            width: 2,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Colors.grey[300]!,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Colors.red,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Colors.red,
            width: 2,
          ),
        ),
        filled: true,
        fillColor: Colors.grey[50],
        contentPadding: EdgeInsets.symmetric(
          horizontal: 16,
          vertical: widget.isTablet ? 16 : 12,
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: const Color(0xFFD44C6D),
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null) {
      setState(() {
        _selectedPreferredDate = picked;
        _preferredDateController.text = "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  Future<void> _submitRequest() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Get current user
      final User? currentUser = FirebaseAuth.instance.currentUser;
      
      if (currentUser == null) {
        // Handle case where user is not logged in
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please log in to submit a request'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Create the request document with all form data
      await FirebaseFirestore.instance
          .collection('blood_donation_requests')
          .add({
        'userId': currentUser.uid,
        'userEmail': currentUser.email ?? 'No email provided',
        'phone': _phoneController.text.trim(),
        'organizationName': _organizationController.text.trim(),
        'address': _addressController.text.trim(),
        'expectedParticipants': _expectedParticipantsController.text.trim().isEmpty 
            ? null 
            : int.tryParse(_expectedParticipantsController.text.trim()),
        'preferredDate': _selectedPreferredDate != null 
            ? Timestamp.fromDate(_selectedPreferredDate!)
            : null,
        'additionalNotes': _additionalNotesController.text.trim().isEmpty 
            ? null 
            : _additionalNotesController.text.trim(),
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'requestType': 'blood_donation_camp',
        'description': 'Request to host a blood donation camp in partnership with Raktpurak Charitable Foundation',
      });

      // Show success dialog
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green[100],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      Icons.check_circle,
                      color: Colors.green[600],
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Request Submitted Successfully!',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ],
              ),
              content: const Text(
                'Thank you for your interest in hosting a blood donation camp with Raktpurak Charitable Foundation. Our team will contact you within 2-3 business days to discuss the details and coordinate the event.',
                style: TextStyle(height: 1.5),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close dialog
                    Navigator.of(context).pop(); // Go back to previous page
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: const Color(0xFFD44C6D),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text(
                      'OK',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      // Handle errors
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error submitting request: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }
}