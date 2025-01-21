import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class REditProfileScreen extends StatefulWidget {
  final Map<String, dynamic> userData;

  const REditProfileScreen({Key? key, required this.userData}) : super(key: key);

  @override
  _REditProfileScreenState createState() => _REditProfileScreenState();
}

class _REditProfileScreenState extends State<REditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _fullNameController;
  late TextEditingController _ageController;
  late TextEditingController _nicController;
  late TextEditingController _addressController;
  late TextEditingController _phoneController;
  late TextEditingController _needDateController;
  late TextEditingController _amountController;

  String? _selectedGender;
  String? _selectedUrgencyLevel;
  String? _selectedBloodType;

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController(text: widget.userData['fullName']);
    _ageController = TextEditingController(text: widget.userData['age'].toString());
    _nicController = TextEditingController(text: widget.userData['nic']);
    _addressController = TextEditingController(text: widget.userData['address']);
    _phoneController = TextEditingController(text: widget.userData['phone']);
    _needDateController = TextEditingController(text: widget.userData['needDate']);
    _amountController = TextEditingController(text: widget.userData['amountNeeded'].toString());
    _selectedGender = widget.userData['gender'];
    _selectedUrgencyLevel = widget.userData['urgencyLevel'];
    _selectedBloodType = widget.userData['bloodType'];
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _ageController.dispose();
    _nicController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _needDateController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      _needDateController.text = picked.toIso8601String();
    }
  }

  Future<void> _updateProfile(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      final fullName = _fullNameController.text;
      final age = int.tryParse(_ageController.text);
      final nic = _nicController.text;
      final address = _addressController.text;
      final gender = _selectedGender;
      final bloodType = _selectedBloodType;
      final phone = _phoneController.text;
      final urgencyLevel = _selectedUrgencyLevel;
      final amountNeeded = int.tryParse(_amountController.text);
      final needDate = _needDateController.text;

      try {
        User? user = FirebaseAuth.instance.currentUser;

        if (user != null) {
          await FirebaseFirestore.instance.collection('recipients').doc(user.uid).update({
            'fullName': fullName,
            'age': age,
            'nic': nic,
            'address': address,
            'gender': gender,
            'bloodType': bloodType,
            'phone': phone,
            'urgencyLevel': urgencyLevel,
            'amountNeeded': amountNeeded,
            'needDate': needDate,
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile updated successfully!')),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        print('Error updating profile: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating profile: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Edit Profile',
          style: TextStyle(color: Colors.white),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xffB81736), Color(0xff281537)],
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
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
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your age';
                    }
                    return null;
                  },
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
                  value: _selectedGender,
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
                  value: _selectedBloodType,
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
                  controller: _phoneController,
                  decoration: const InputDecoration(
                    suffixIcon: Icon(Icons.phone, color: Colors.grey),
                    labelText: 'Phone',
                    labelStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xffB81736),
                    ),
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your phone number';
                    }
                    return null;
                  },
                ),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Urgency Level',
                    labelStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xffB81736),
                    ),
                  ),
                  items: ['Low', 'Medium', 'High']
                      .map((urgencyLevel) => DropdownMenuItem<String>(
                            value: urgencyLevel,
                            child: Text(urgencyLevel),
                          ))
                      .toList(),
                  value: _selectedUrgencyLevel,
                  onChanged: (String? value) {
                    setState(() {
                      _selectedUrgencyLevel = value;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Please select urgency level';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _amountController,
                  decoration: const InputDecoration(
                    suffixIcon: Icon(Icons.water_drop, color: Colors.grey),
                    labelText: 'Amount Needed (ml)',
                    labelStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xffB81736),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the amount needed';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _needDateController,
                  decoration: const InputDecoration(
                    suffixIcon: Icon(Icons.calendar_today, color: Colors.grey),
                    labelText: 'Need Date',
                    labelStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xffB81736),
                    ),
                  ),
                  readOnly: true,
                  onTap: () => _pickDate(context),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the need date';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => _updateProfile(context),
                  child: const Text('Update Profile'),
                  style: ElevatedButton.styleFrom(
                      iconColor: Color.fromARGB(255, 236, 202, 209), // Button background color

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
