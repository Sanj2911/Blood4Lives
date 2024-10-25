import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'rEditProfile.dart'; // Import the EditProfileScreen file

class RViewProfile extends StatefulWidget {
  @override
  _RViewProfileState createState() => _RViewProfileState();
}

class _RViewProfileState extends State<RViewProfile> {
  late User _user;
  Map<String, dynamic>? _userData;

  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser!;
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    DocumentSnapshot<Map<String, dynamic>> userDoc =
        await FirebaseFirestore.instance.collection('recipients').doc(_user.uid).get();
    if (userDoc.exists) {
      setState(() {
        _userData = userDoc.data();
      });
    } else {
      print('User document does not exist');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Your Profile',
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
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pop(context);
          },
          color: Colors.white,
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => REditProfileScreen(userData: _userData!)),
              );
            },
            color: Colors.white,
          ),
        ],
      ),
      body: _userData != null
          ? SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20),
                  _buildProfileItem('Full Name', _userData!['fullName']),
                  _buildProfileItem('Age', _userData!['age'].toString()),
                  _buildProfileItem('NIC', _userData!['nic']),
                  _buildProfileItem('Address', _userData!['address']),
                  _buildProfileItem('Gender', _userData!['gender']),
                  _buildProfileItem('Blood Type', _userData!['bloodType']),
                  _buildProfileItem('Urgency Level', _userData!['urgencyLevel']),
                  _buildProfileItem('Amount Needed', _userData!['amountNeeded'].toString()),
                  _buildProfileItem('Need Date', _userData!['needDate']),
                  SizedBox(height: 24),
                  _buildProfileItem('Email', _userData!['email']),
                  _buildProfileItem('Phone', _userData!['phone']),
                ],
              ),
            )
          : Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildProfileItem(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 16),
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            color: Colors.black87,
          ),
        ),
        Divider(color: Colors.grey[400]),
      ],
    );
  }
}
