import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:savelives/screens/loginScreen.dart';
import 'package:geolocator/geolocator.dart'; // Import geolocator package

class DRegScreen extends StatefulWidget {
  const DRegScreen({Key? key}) : super(key: key);

  @override
  _DRegScreenState createState() => _DRegScreenState();
}

class _DRegScreenState extends State<DRegScreen> {
  final _formKey = GlobalKey<FormState>();

  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _ageController = TextEditingController();
  final _nicController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _lastDonationDateController = TextEditingController();

  String? _selectedGender;
  String? _selectedBloodType;

    // Variables to store latitude and longitude
  double? _latitude;
  double? _longitude;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _ageController.dispose();
    _nicController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _lastDonationDateController.dispose();
    super.dispose();
  }
  // Function to get current location
  Future<void> _getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    setState(() {
      _latitude = position.latitude;
      _longitude = position.longitude;
    });
  }

  bool _isDonorActive(String lastDonationDateStr) {
  if ( lastDonationDateStr.isEmpty) {
      return true;
    }
     // Parse last donation date if not empty
  DateTime lastDonation = DateTime.tryParse(lastDonationDateStr) ?? DateTime.now();
  DateTime now = DateTime.now();
  int differenceInDays = now.difference(lastDonation).inDays;
  return differenceInDays >= 180; // Assuming 180 days (6 months) as the threshold
}

  Future<void> _pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      _lastDonationDateController.text = picked.toString().split(' ')[0];
    }
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter an email';
    }
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a password';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters long';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a phone number';
    }
    final phoneRegex = RegExp(r'^\+?[0-9]{10}$');
    if (!phoneRegex.hasMatch(value)) {
      return 'Please enter a valid phone number';
    }
    return null;
  }

  String? _validateAge(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your age';
    }
    final age = int.tryParse(value);
    if (age == null || age <= 18 || age > 60) {
      return 'You are not eligible';
    }
    return null;
  }

  Future<void> _signUp(BuildContext context) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final fullName = _fullNameController.text;
    final age = _ageController.text;
    final nic = _nicController.text;
    final address = _addressController.text;
    final gender = _selectedGender;
    final bloodType = _selectedBloodType;
    final email = _emailController.text;
    final phone = _phoneController.text;
    final lastDonationDate = _lastDonationDateController.text;
    final password = _passwordController.text;

    if (fullName.isEmpty ||
        age.isEmpty ||
        nic.isEmpty ||
        address.isEmpty ||
        gender == null ||
        bloodType == null ||
        email.isEmpty ||
        phone.isEmpty ||
        password.isEmpty) {
      return;
    }
    

    try {
      // Get current location
    await _getCurrentLocation();

    // Check if location is available
    if (_latitude == null || _longitude == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Location not available'),
        ),
      );
      return;
    }
      bool isActive = _isDonorActive(lastDonationDate);

      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
  
      await FirebaseFirestore.instance.collection('donors').doc(userCredential.user!.uid).set({
        'fullName': fullName,
        'age': age,
        'nic': nic,
        'address': address,
        'gender': gender,
        'bloodType': bloodType,
        'email': email,
        'phone': phone,
        'lastDonationDate': lastDonationDate,
         'isActive': isActive,
        'latitude': _latitude,
        'longitude': _longitude,
        'notifications': [],
      });
  
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registration successful!'),
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error registering user: $e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            height: double.infinity,
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xffB81736), Color(0xff281537)],
              ),
            ),
            child: const Padding(
              padding: EdgeInsets.only(top: 60.0, left: 22),
              child: Text(
                'Create Your Donor Account',
                style: TextStyle(
                  fontSize: 30,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 200.0),
            child: Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
                color: Colors.white,
              ),
              height: double.infinity,
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextFormField(
                          controller: _fullNameController,
                          decoration: const InputDecoration(
                            suffixIcon: Icon(Icons.perm_identity, color: Colors.grey),
                            labelText: 'Full Name',
                            labelStyle: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xffB81736),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your full name';
                            }
                            return null;
                          },
                        ),
                        TextFormField(
                          controller: _ageController,
                          decoration: const InputDecoration(
                            suffixIcon: Icon(Icons.check, color: Colors.grey),
                            labelText: 'Age',
                            labelStyle: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xffB81736),
                            ),
                          ),
                          validator: _validateAge,
                        ),
                        TextFormField(
                          controller: _nicController,
                          decoration: const InputDecoration(
                            suffixIcon: Icon(Icons.verified, color: Colors.grey),
                            labelText: 'NIC',
                            labelStyle: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xffB81736),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your NIC';
                            }
                            return null;
                          },
                        ),
                        TextFormField(
                          controller: _addressController,
                          decoration: const InputDecoration(
                            suffixIcon: Icon(Icons.location_on, color: Colors.grey),
                            labelText: 'Address',
                            labelStyle: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xffB81736),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your address';
                            }
                            return null;
                          },
                        ),
                        DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                            labelText: 'Gender',
                            labelStyle: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xffB81736),
                            ),
                          ),
                          items: ['Male', 'Female']
                              .map((gender) => DropdownMenuItem<String>(
                                    value: gender,
                                    child: Text(gender),
                                  ))
                              .toList(),
                          onChanged: (String? value) {
                            setState(() {
                              _selectedGender = value;
                            });
                          },
                          validator: (value) {
                            if (value == null) {
                              return 'Please select your gender';
                            }
                            return null;
                          },
                        ),
                        DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                            labelText: 'Blood Type',
                            labelStyle: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xffB81736),
                            ),
                          ),
                          items: ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-']
                              .map((bloodType) => DropdownMenuItem<String>(
                                    value: bloodType,
                                    child: Text(bloodType),
                                  ))
                              .toList(),
                          onChanged: (String? value) {
                            setState(() {
                              _selectedBloodType = value;
                            });
                          },
                          validator: (value) {
                            if (value == null) {
                              return 'Please select your blood type';
                            }
                            return null;
                          },
                        ),
                        TextFormField(
                          controller: _emailController,
                          decoration: const InputDecoration(
                            suffixIcon: Icon(Icons.email, color: Colors.grey),
                            labelText: 'Email',
                            labelStyle: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xffB81736),
                            ),
                          ),
                          validator: _validateEmail,
                        ),
                        TextFormField(
                          controller: _phoneController,
                          decoration: const InputDecoration(
                            suffixIcon: Icon(Icons.phone, color: Colors.grey),
                            labelText: 'Phone',
                            labelStyle: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xffB81736),
                            ),
                          ),
                          validator: _validatePhone,
                        ),
                        GestureDetector(
                          onTap: () => _pickDate(context),
                          child: AbsorbPointer(
                            child: TextFormField(
                              controller: _lastDonationDateController,
                              decoration: const InputDecoration(
                                suffixIcon: Icon(Icons.calendar_today, color: Colors.grey),
                                labelText: 'Last Donation Date',
                                labelStyle: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xffB81736),
                                ),
                              ),
                              
                            ),
                          ),
                        ),
                        TextFormField(
                          controller: _passwordController,
                          decoration: const InputDecoration(
                            suffixIcon: Icon(Icons.visibility_off, color: Colors.grey),
                            labelText: 'Password',
                            labelStyle: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xffB81736),
                            ),
                          ),
                          obscureText: true,
                          validator: _validatePassword,
                        ),
                        const SizedBox(height: 10),
                        const SizedBox(height: 70),
                        Container(
                          height: 55,
                          width: 300,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xffB81736),
                                Color(0xff281537),
                              ],
                            ),
                          ),
                          child: ElevatedButton(
                            onPressed: () => _signUp(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                                side: const BorderSide(color: Colors.white),
                              ),
                            ),
                            child: const Text(
                              'SIGN UP',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text(
                                "Already have an account?",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                                  );
                                },
                                child: const Text(
                                  "Sign In",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 17,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
