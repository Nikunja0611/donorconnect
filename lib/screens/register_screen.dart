import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../widgets/custom_text_field.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _bloodGroupController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String _errorMessage = '';
  String _passwordStrengthMessage = '';
  Color _passwordStrengthColor = Colors.grey;

  final List<String> _bloodGroups = [
    'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _dobController.dispose();
    _bloodGroupController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(Duration(days: 365 * 18)),
      firstDate: DateTime(1940),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Color(0xFFC14465),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      String formattedDate = '${pickedDate.day}/${pickedDate.month}/${pickedDate.year}';
      setState(() {
        _dobController.text = formattedDate;
      });
    }
  }

  void _showBloodGroupPicker() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(16),
          height: 320,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  'Select Blood Group',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              Divider(),
              Expanded(
                child: ListView.builder(
                  itemCount: _bloodGroups.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(_bloodGroups[index]),
                      onTap: () {
                        setState(() {
                          _bloodGroupController.text = _bloodGroups[index];
                        });
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _checkPasswordStrength(String password) {
    setState(() {
      if (password.isEmpty) {
        _passwordStrengthMessage = '';
        _passwordStrengthColor = Colors.grey;
        return;
      }

      bool hasUppercase = password.contains(RegExp(r'[A-Z]'));
      bool hasLowercase = password.contains(RegExp(r'[a-z]'));
      bool hasDigit = password.contains(RegExp(r'[0-9]'));
      bool hasSpecialChar = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
      bool hasMinLength = password.length >= 8;

      int strength = 0;
      if (hasUppercase) strength++;
      if (hasLowercase) strength++;
      if (hasDigit) strength++;
      if (hasSpecialChar) strength++;
      if (hasMinLength) strength++;

      if (strength <= 2) {
        _passwordStrengthMessage = 'Weak password';
        _passwordStrengthColor = Colors.red;
      } else if (strength == 3) {
        _passwordStrengthMessage = 'Moderate password';
        _passwordStrengthColor = Colors.orange;
      } else if (strength == 4) {
        _passwordStrengthMessage = 'Strong password';
        _passwordStrengthColor = Colors.green;
      } else {
        _passwordStrengthMessage = 'Very strong password';
        _passwordStrengthColor = Colors.green.shade700;
      }
    });
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Column(
            children: [
              Icon(
                Icons.check_circle,
                color: Color(0xFF4CAF50),
                size: 60,
              ),
              SizedBox(height: 16),
              Text(
                'Registration Successful!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Text(
            'Your account has been created successfully. Please login to continue.',
            textAlign: TextAlign.center,
          ),
          actions: [
            TextButton(
              child: Text(
                'LOG IN',
                style: TextStyle(
                  color: Color(0xFFC14465),
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Go back to login page
              },
            ),
          ],
          actionsAlignment: MainAxisAlignment.center,
        );
      },
    );
  }

  Future<void> _register() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    if (_formKey.currentState!.validate()) {
      try {
        final authService = Provider.of<AuthService>(context, listen: false);
        await authService.registerWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
          name: _nameController.text.trim(),
          phone: _phoneController.text.trim(),
          address: _addressController.text.trim(),
          dob: _dobController.text.trim(),
          bloodGroup: _bloodGroupController.text.trim(),
        );
        
        // Show success dialog and then navigate to login page
        _showSuccessDialog();
      } catch (e) {
        setState(() {
          if (e.toString().contains('email-already-in-use')) {
            _errorMessage = 'This email is already registered. Try logging in instead.';
          } else {
            _errorMessage = 'Registration failed. Please try again later.';
          }
        });
      }
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8ECF1),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Color(0xFFC14465)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 30),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Image.asset('assets/images/logo.png', height: 80),
                  SizedBox(height: 20),
                  Text(
                    "REGISTER",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 20),
                  CustomTextField(
                    hintText: "Full Name",
                    icon: Icons.person,
                    controller: _nameController,
                    validator: (value) =>
                        (value == null || value.isEmpty) ? 'Please enter your name' : null,
                  ),
                  SizedBox(height: 15),
                  CustomTextField(
                    hintText: "Email",
                    icon: Icons.email,
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Please enter your email';
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 15),
                  CustomTextField(
                    hintText: "Phone Number",
                    icon: Icons.phone,
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Please enter your phone number';
                      if (!RegExp(r'^\d{10}$').hasMatch(value)) {
                        return 'Enter a valid 10-digit number';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 15),
                  CustomTextField(
                    hintText: "Address",
                    icon: Icons.location_on,
                    controller: _addressController,
                    validator: (value) =>
                        (value == null || value.isEmpty) ? 'Please enter your address' : null,
                  ),
                  SizedBox(height: 15),
                  CustomTextField(
                    hintText: "Date of Birth",
                    icon: Icons.calendar_today,
                    controller: _dobController,
                    readOnly: true,
                    onTap: () => _selectDate(context),
                    validator: (value) =>
                        (value == null || value.isEmpty) ? 'Please select your date of birth' : null,
                  ),
                  SizedBox(height: 15),
                  CustomTextField(
                    hintText: "Blood Group",
                    icon: Icons.water_drop,
                    controller: _bloodGroupController,
                    readOnly: true,
                    onTap: _showBloodGroupPicker,
                    validator: (value) =>
                        (value == null || value.isEmpty) ? 'Please select your blood group' : null,
                  ),
                  SizedBox(height: 15),
                  // Password field with eye icon
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    keyboardType: TextInputType.visiblePassword,
                    onChanged: _checkPasswordStrength,
                    decoration: InputDecoration(
                      hintText: "Password",
                      prefixIcon: Icon(Icons.lock, color: Color(0xFFC14465)),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_off : Icons.visibility,
                          color: Color(0xFFC14465),
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: EdgeInsets.symmetric(vertical: 15),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Please enter a password';
                      if (value.length < 8) return 'Password must be at least 8 characters';
                      if (!value.contains(RegExp(r'[A-Z]'))) 
                        return 'Password must contain at least one uppercase letter';
                      if (!value.contains(RegExp(r'[a-z]'))) 
                        return 'Password must contain at least one lowercase letter';
                      if (!value.contains(RegExp(r'[0-9]'))) 
                        return 'Password must contain at least one number';
                      if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) 
                        return 'Password must contain at least one special character';
                      return null;
                    },
                  ),
                  if (_passwordStrengthMessage.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 5.0, left: 12.0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          _passwordStrengthMessage,
                          style: TextStyle(color: _passwordStrengthColor, fontSize: 12),
                        ),
                      ),
                    ),
                  SizedBox(height: 5),
                  Padding(
                    padding: const EdgeInsets.only(left: 12.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Password must contain:',
                        style: TextStyle(fontSize: 12, color: Colors.black54),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('• At least 8 characters', style: TextStyle(fontSize: 12, color: Colors.black54)),
                        Text('• At least one uppercase letter (A-Z)', style: TextStyle(fontSize: 12, color: Colors.black54)),
                        Text('• At least one lowercase letter (a-z)', style: TextStyle(fontSize: 12, color: Colors.black54)),
                        Text('• At least one number (0-9)', style: TextStyle(fontSize: 12, color: Colors.black54)),
                        Text('• At least one special character (!@#\$%^&*)', style: TextStyle(fontSize: 12, color: Colors.black54)),
                      ],
                    ),
                  ),
                  SizedBox(height: 15),
                  // Confirm Password field with eye icon
                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: _obscureConfirmPassword,
                    decoration: InputDecoration(
                      hintText: "Confirm Password",
                      prefixIcon: Icon(Icons.lock_outline, color: Color(0xFFC14465)),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                          color: Color(0xFFC14465),
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureConfirmPassword = !_obscureConfirmPassword;
                          });
                        },
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: EdgeInsets.symmetric(vertical: 15),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Please confirm your password';
                      if (value != _passwordController.text) return 'Passwords do not match';
                      return null;
                    },
                  ),
                  if (_errorMessage.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 15.0),
                      child: Text(
                        _errorMessage,
                        style: TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  SizedBox(height: 25),
                  _isLoading
                      ? CircularProgressIndicator(color: Color(0xFFC14465))
                      : ElevatedButton(
                          onPressed: _register,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFFD95373),
                            minimumSize: Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          child: Text(
                            "REGISTER",
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        ),
                  SizedBox(height: 20),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: "Already have an account? ",
                            style: TextStyle(color: Colors.black54),
                          ),
                          TextSpan(
                            text: "Login",
                            style: TextStyle(
                              color: Color(0xFFC14465),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}