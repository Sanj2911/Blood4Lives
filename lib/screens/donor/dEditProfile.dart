import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EditProfileScreen extends StatefulWidget {
  final Map<String, dynamic>? userData;

  EditProfileScreen({Key? key, this.userData}) : super(key: key);

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _fullNameController;
  late TextEditingController _ageController;
  late TextEditingController _nicController;
  late TextEditingController _addressController;
  late TextEditingController _phoneController;
  late TextEditingController _lastDonationDateController;
  late bool _isActive;

  @override
  void initState() {
    super.initState();
    _fullNameController =
        TextEditingController(text: widget.userData?['fullName'] ?? '');
    _ageController =
        TextEditingController(text: widget.userData?['age'] ?? '');
    _nicController =
        TextEditingController(text: widget.userData?['nic'] ?? '');
    _addressController =
        TextEditingController(text: widget.userData?['address'] ?? '');
    _phoneController =
        TextEditingController(text: widget.userData?['phone'] ?? '');
    _lastDonationDateController =
        TextEditingController(text: widget.userData?['lastDonationDate'] ?? '');

    _isActive = widget.userData?['isActive'] ?? false;
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _ageController.dispose();
    _nicController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _lastDonationDateController.dispose();
    super.dispose();
  }

  void _saveChanges() async {
    // Update user data in Firestore
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Calculate isActive based on lastDonationDate
        bool isActive = _isDonorActive(_lastDonationDateController.text);

        await FirebaseFirestore.instance.collection('donors').doc(user.uid).update({
          'fullName': _fullNameController.text,
          'age': _ageController.text,
          'nic': _nicController.text,
          'address': _addressController.text,
          'phone': _phoneController.text,
          'isActive': isActive,
          if (_isActive) 'lastDonationDate': _lastDonationDateController.text,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Profile updated successfully!'),
          ),
        );
        Navigator.pop(context); // Go back to the profile view
      }
    } catch (e) {
      print('Error updating profile: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating profile: $e'),
        ),
      );
    }
  }

  bool _isDonorActive(String? lastDonationDateStr) {
    if (lastDonationDateStr == null || lastDonationDateStr.isEmpty) {
      return true; // No last donation date means active
    }

    DateTime lastDonation = DateTime.parse(lastDonationDateStr); // Parse last donation date
    DateTime now = DateTime.now(); // Get current date and time
    int differenceInDays =
        now.difference(lastDonation).inDays; // Calculate difference in days

    return differenceInDays >= 180; // Active if no last donation or last donation more than 180 days ago
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Edit Profile',
          style: TextStyle(color: Colors.white), // Set app bar font color to white
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
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pop(context);
          },
          color: Colors.white, // Set back icon color to white
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20),
            TextFormField(
              controller: _fullNameController,
              decoration: InputDecoration(
                labelText: 'Full Name',
                hintText: 'Enter your full name',
                labelStyle: TextStyle(color: Colors.blue),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue),
                ),
              ),
              style: TextStyle(color: Colors.black87), // Text color
            ),
            SizedBox(height: 20),
            TextFormField(
              controller: _ageController,
              decoration: InputDecoration(
                labelText: 'Age',
                hintText: 'Enter your age',
                labelStyle: TextStyle(color: Colors.blue),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue),
                ),
              ),
              keyboardType: TextInputType.number, // Set keyboard type
              style: TextStyle(color: Colors.black87),
            ),
            SizedBox(height: 20),
            TextFormField(
              controller: _nicController,
              decoration: InputDecoration(
                labelText: 'NIC',
                hintText: 'Enter your NIC number',
                labelStyle: TextStyle(color: Colors.blue),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue),
                ),
              ),
              style: TextStyle(color: Colors.black87),
            ),
            SizedBox(height: 20),
            TextFormField(
              controller: _addressController,
              decoration: InputDecoration(
                labelText: 'Address',
                hintText: 'Enter your address',
                labelStyle: TextStyle(color: Colors.blue),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue),
                ),
              ),
              maxLines: null, // Allow multiple lines
              style: TextStyle(color: Colors.black87),
            ),
            SizedBox(height: 20),
            TextFormField(
              controller: _phoneController,
              decoration: InputDecoration(
                labelText: 'Phone',
                hintText: 'Enter your phone number',
                labelStyle: TextStyle(color: Colors.blue),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue),
                ),
              ),
              keyboardType: TextInputType.phone, // Set keyboard type
              style: TextStyle(color: Colors.black87),
            ),
            SizedBox(height: 20),
            TextFormField(
              controller: _lastDonationDateController,
              decoration: InputDecoration(
                labelText: 'Last Donation Date',
                hintText: 'Enter your last donation date',
                labelStyle: TextStyle(color: Colors.blue),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue),
                ),
              ),
              style: TextStyle(color: Colors.black87),
              enabled: _isActive, // Enable only if isActive is true
            ),
            SizedBox(height: 40),
            ElevatedButton(
              onPressed: _saveChanges,
              child: Text('Save Changes'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromARGB(255, 120, 187, 232), // Button background color
                textStyle: TextStyle(color: Colors.black), // Button text color
              ),
            ),
          ],
        ),
      ),
    );
  }
}
