import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:savelives/feed/post.dart';
import 'package:savelives/screens/donor/about.dart';
import 'package:savelives/screens/loginScreen.dart';
import 'package:savelives/screens/donor/dViewProfile.dart';
import 'package:savelives/screens/donor/notification.dart';
import 'package:savelives/screens/donor/nearbyCenters.dart';
import 'package:savelives/screens/donor/nearbyRecipients.dart';
import 'package:savelives/screens/donor/campaign.dart';
import 'package:savelives/screens/donor/donationHistory.dart';

class DonorProfileScreen extends StatefulWidget {
  @override
  _DonorProfileScreenState createState() => _DonorProfileScreenState();
}

class _DonorProfileScreenState extends State<DonorProfileScreen> {
  int _selectedIndex = 0;
  String? _fullName;
  int _notificationCount = 0;
  bool _isActive = true;

  static final List<Widget> _widgetOptions = <Widget>[
    DonorProfileContent(),
    NearbyRecipientsPage(),
    CampaignDetailsScreen(),
    DonationHistoryScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _fetchFullName();
    _fetchNotificationCount();
    _checkAndUpdateDonorActivity();
  }

  Future<void> _fetchFullName() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        FirebaseFirestore.instance
            .collection('donors')
            .doc(user.uid)
            .snapshots()
            .listen((DocumentSnapshot<Map<String, dynamic>> userDoc) {
          if (userDoc.exists) {
            setState(() {
              _fullName = userDoc.data()?['fullName'];
              // Get last donation date as string
              String? lastDonationDateStr = userDoc.data()?['lastDonationDate'];
              // Check donor activity
              _isActive = _isDonorActive(lastDonationDateStr);
            });
          }
        });
      } catch (e) {
        print('Error fetching full name: $e');
      }
    }
  }

  bool _isDonorActive(String? lastDonationDateStr) {
    if (lastDonationDateStr == null || lastDonationDateStr.isEmpty) {
      return true; // No last donation date means active
    }

    DateTime lastDonation = DateTime.parse(lastDonationDateStr); // Parse last donation date
    DateTime now = DateTime.now(); // Get current date and time
    int differenceInDays = now.difference(lastDonation).inDays; // Calculate difference in days

    return differenceInDays >= 180; // Active if no last donation or last donation more than 180 days ago
  }
Future<void> _checkAndUpdateDonorActivity() async {
  User? user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    try {
      DocumentSnapshot<Map<String, dynamic>> donorDoc = await FirebaseFirestore.instance
          .collection('donors')
          .doc(user.uid)
          .get();

      if (donorDoc.exists) {
        String? lastDonationDateStr = donorDoc.data()?['lastDonationDate'];
        bool isActive = _isDonorActive(lastDonationDateStr);

        // Update isActive field if necessary
        if (isActive != donorDoc.data()?['isActive']) {
          await FirebaseFirestore.instance
              .collection('donors')
              .doc(user.uid)
              .update({'isActive': isActive});
        }
      }
    } catch (e) {
      print('Error checking/updating donor activity: $e');
    }
  }
}

  

  Future<void> _fetchNotificationCount() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        FirebaseFirestore.instance
            .collection('donors')
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
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    } catch (e) {
      print('Error signing out: $e');
    }
  }

  void _showNotifications() {
    String? currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId != null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => NotificationsScreen()),
      );
    } else {
      print('User is not authenticated or currentUserId is null');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: _fullName != null
            ? Row(
                children: [
                  CircleAvatar(
                    backgroundColor: _isActive
                        ? const Color.fromARGB(255, 54, 244, 57)
                        : Color.fromARGB(255, 216, 46, 46),
                    radius: 8,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Welcome!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                ],
              )
            : Text(
                '',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
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
                    MaterialPageRoute(builder: (context) => DViewProfile()),
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
                    MaterialPageRoute(
                        builder: (context) => NearbyCentersPage()),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.water_drop_sharp, color: Colors.white),
                title: Text('Nearby Recipients',
                    style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  _onItemTapped(1);
                },
              ),
              ListTile(
                leading: Icon(Icons.campaign, color: Colors.white),
                title: Text('Campaigns', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => CampaignDetailsScreen()),
                  );
                },
              ),
               ListTile(
                leading: Icon(Icons.share, color: Colors.white),
                title: Text('Share', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => PostNewsFeedPage()),
                  );
                  // Navigate to immediate blood requests screen
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

class DonorProfileContent extends StatelessWidget {
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
                  Image.asset('assets/donate.png', fit: BoxFit.cover),
                  SizedBox(height: 8),
                  Text(
                    'Blood donation is a noble act that saves millions of lives every year. At Blood4Life, we are dedicated to ensuring a safe and efficient blood donation process.',
                    style: TextStyle(fontSize: 20),
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
                    'Donor Selection Criteria',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                  Divider(thickness: 1, color: Colors.deepPurple),
                  SizedBox(height: 8),
                  buildBulletPoint('Age: 18 - 60 years.'),
                  buildBulletPoint('Previous donation: At least 6 months gap.'),
                  buildBulletPoint('Hemoglobin level: >12g/dL.'),
                  buildBulletPoint('Free from serious diseases or pregnancy.'),
                  buildBulletPoint('Valid identification required.'),
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
                    'Risk Behaviours',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                  Divider(thickness: 1, color: Colors.deepPurple),
                  SizedBox(height: 8),
                  Text('Donors should be free from certain risk behaviors:'),
                  buildBulletPoint('Homosexual activity.'),
                  buildBulletPoint(
                      'Engagement in sex work or with sex workers.'),
                  buildBulletPoint('Drug addiction.'),
                  buildBulletPoint('Multiple sexual partners.'),
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

