import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dEditProfile.dart'; // Import the EditProfileScreen file

class DViewProfile extends StatefulWidget {
  @override
  _DViewProfileState createState() => _DViewProfileState();
}

class _DViewProfileState extends State<DViewProfile> {
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
        await FirebaseFirestore.instance.collection('donors').doc(_user.uid).get();
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
          style: TextStyle(color: Colors.white, fontSize: 20), // Title font size and color
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
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => EditProfileScreen(userData: _userData!)),
              );
            },
            color: Colors.white, // Set edit icon color to white
          ),
        ],
      ),
      body: _userData != null
          ? ListView(
              padding: EdgeInsets.all(16),
              children: [
                _buildProfileCard('Personal Information', [
                  _buildProfileItem('Full Name', _userData!['fullName']),
                  _buildProfileItem('Age', _userData!['age'].toString()), // Convert to string if it's not
                  _buildProfileItem('NIC', _userData!['nic']),
                  _buildProfileItem('Address', _userData!['address']),
                  _buildProfileItem('Gender', _userData!['gender']),
                  _buildProfileItem('Blood Type', _userData!['bloodType']),
                ]),
                SizedBox(height: 24),
                _buildProfileCard('Contact Information', [
                  _buildProfileItem('Email', _userData!['email']),
                  _buildProfileItem('Phone', _userData!['phone']),
                ]),
                SizedBox(height: 24),
                _buildProfileCard('Donation Details', [
                  _buildProfileItem(
                    'Last Donation Date',
                    _userData!['lastDonationDate'] != null
                        ? _userData!['lastDonationDate'].toString()
                        : 'Never',
                    icon: Icons.calendar_today,
                  ), // Show 'Never' if last donation date is null
                ]),
              ],
            )
          : Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildProfileCard(String title, List<Widget> children) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue, // Adjust color as needed
              ),
            ),
            SizedBox(height: 12),
            Column(children: children),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileItem(String title, String value, {IconData? icon}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (icon != null)
              Icon(
                icon,
                size: 20,
                color: Colors.black54,
              ),
            SizedBox(width: icon != null ? 12 : 0),
            Text(
              title,
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87, fontSize: 16),
            ),
          ],
        ),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(fontSize: 16, color: Colors.black87),
        ),
        Divider(),
      ],
    );
  }
}
