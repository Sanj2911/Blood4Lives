import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:savelives/feed/post.dart';
import 'package:savelives/screens/loginScreen.dart';
import 'package:savelives/screens/recipient/about.dart';
import 'package:savelives/screens/recipient/nearby.dart';
import 'package:savelives/screens/recipient/rViewProfile.dart';
import 'package:savelives/screens/recipient/sendRequest.dart';
import 'package:savelives/screens/recipient/nearbyCenters.dart';
import 'package:savelives/screens/recipient/notification.dart'; // Import your notification screen

class RecipientProfileScreen extends StatefulWidget {
  @override
  _RecipientProfileScreenState createState() => _RecipientProfileScreenState();
}

class _RecipientProfileScreenState extends State<RecipientProfileScreen> {
  int _selectedIndex = 0;
  String? _fullName;
  int _notificationCount = 0;

  static final List<Widget> _widgetOptions = <Widget>[
    RecipientProfileContent(),
    NearbyCentersPage(),
    NearbyDonorsPage(),
    SendRequestScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _fetchFullName();
    _fetchNotificationCount();
  }

  Future<void> _fetchFullName() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        DocumentSnapshot<Map<String, dynamic>> userDoc = await FirebaseFirestore
            .instance
            .collection('Recipients')
            .doc(user.uid)
            .get();
        if (userDoc.exists) {
          setState(() {
            _fullName = userDoc.data()?['fullName'];
          });
        } else {
          print('Document does not exist');
        }
      } catch (e) {
        print('Error fetching full name: $e');
      }
    } else {
      print('User is not authenticated');
    }
  }

  Future<void> _fetchNotificationCount() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        FirebaseFirestore.instance
            .collection('recipients')
            .doc(user.uid)
            .snapshots()
            .listen((DocumentSnapshot<Map<String, dynamic>> userDoc) {
          if (userDoc.exists) {
            List<dynamic> notifications = userDoc.data()?['notifications'] ?? [];
            setState(() {
              _notificationCount = notifications.length;
            });
          } else {
            print('Document does not exist');
          }
        });
      } catch (e) {
        print('Error fetching notification count: $e');
      }
    } else {
      print('User is not authenticated');
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  void _showNotifications() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => NotificationsScreen()), // Create and use a notification screen
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: _fullName != null
            ? Text('Welcome, $_fullName!',
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple))
            : Text('Welcome !',
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple)),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: Icon(Icons.notifications),
                onPressed: _showNotifications,
              ),
              Positioned(
                right: 5,
                top: 5,
                child: Container(
                  padding: EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$_notificationCount',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      drawer: Drawer(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xffB81736), Color(0xff281537)],
            ),
          ),
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xffB81736), Color(0xff281537)],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'Blood4Life',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Donate Blood, Save Lives',
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                  ],
                ),
              ),
              ListTile(
                leading: Icon(Icons.home, color: Colors.white),
                title: Text('Profile', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => RViewProfile()),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.location_on, color: Colors.white),
                title: Text('Donation Centers',
                    style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => NearbyCentersPage()),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.people_sharp, color: Colors.white),
                title: Text('Nearby Donors',
                    style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => NearbyDonorsPage()),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.send, color: Colors.white),
                title: Text('Blood Requests',
                    style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SendRequestScreen()),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.share, color: Colors.white),
                title: Text('Share', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => PostNewsFeedPage()),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.analytics, color: Colors.white),
                title: Text('Analytics', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ReportsScreen()),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.logout, color: Colors.white),
                title: Text('Sign Out', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  _signOut();
                },
              ),
            ],
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xffB81736), Color(0xff281537)],
          ),
        ),
        child: Center(
          child: _widgetOptions.elementAt(_selectedIndex),
        ),
      ),
    );
  }
}

class RecipientProfileContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            margin: EdgeInsets.symmetric(vertical: 16),
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20),
                  Image.asset('assets/recip.jpg', fit: BoxFit.cover),
                  SizedBox(height: 8),
                  SizedBox(height: 8),
                  Text(
                    'Here you can find useful information related to managing your health as a blood recipient.',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
          Card(
            margin: EdgeInsets.symmetric(vertical: 8),
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Preparing for Your Transfusion',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                  Divider(thickness: 1, color: Colors.deepPurple),
                  SizedBox(height: 8),
                  buildBulletPoint(
                      'Stay hydrated by drinking plenty of water.'),
                  buildBulletPoint(
                      'Eat a balanced diet rich in iron and vitamins.'),
                  buildBulletPoint(
                      'Get enough rest and avoid strenuous activities.'),
                  buildBulletPoint(
                      'Communicate any concerns with your healthcare provider.'),
                ],
              ),
            ),
          ),
          Card(
            margin: EdgeInsets.symmetric(vertical: 8),
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Managing Your Health',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                  Divider(thickness: 1, color: Colors.deepPurple),
                  SizedBox(height: 8),
                  Text(
                    'After your transfusion, it\'s important to:',
                    style: TextStyle(fontSize: 16),
                  ),
                  buildBulletPoint('Follow your doctor\'s instructions.'),
                  buildBulletPoint('Take prescribed medications on time.'),
                  buildBulletPoint(
                      'Monitor any changes in your health or symptoms.'),
                  buildBulletPoint(
                      'Maintain a healthy lifestyle and diet.'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.brightness_1, size: 8, color: Colors.deepPurple),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
