import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:savelives/screens/admin/donors.dart';
import 'package:savelives/screens/admin/recipients.dart';
import 'package:savelives/screens/admin/reports.dart';
import 'package:savelives/screens/admin/settings.dart';
import 'package:savelives/screens/admin/adminLogin.dart'; // Import the login screen to handle logout
import 'Campaign_screen.dart';
class AdminDashboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Dashboard'),
        backgroundColor: Color.fromARGB(255, 226, 136, 154), // Custom app bar color
      ),
      drawer: Drawer(
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
              child: Center(
                child: Text(
                  'Admin Dashboard',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.people, color: Colors.purple), // Custom icon color
              title: Text('Donors', style: TextStyle(color: Colors.purple)),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DonorsScreen()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.person, color: Colors.blue), // Custom icon color
              title: Text('Recipients', style: TextStyle(color: Colors.blue)),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RecipientsScreen()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.campaign, color: Colors.green), // Custom icon color
              title: Text('Campaigns', style: TextStyle(color: Colors.green)),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Campaign()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.bar_chart, color: Colors.pink), // Custom icon color
              title: Text('Reports', style: TextStyle(color: Colors.pink)),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ReportsScreen()),
                );
              },
            ),
           
            ListTile(
              leading: Icon(Icons.settings, color: Colors.orange), // Custom icon color
              title: Text('Settings', style: TextStyle(color: Colors.orange)),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SettingsScreen()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.logout, color: Colors.red), // Custom icon color
              title: Text('Logout', style: TextStyle(color: Colors.red)),
              onTap: () {
                // Navigate to the login screen
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => AdminLoginScreen()),
                );
              },
            ),
          ],
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  'Welcome to Admin Dashboard!',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
                  textAlign: TextAlign.center, // Center align the text
                ),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance.collection('donors').snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}', style: TextStyle(color: Colors.red)); // Custom error text color
                      }
                      if (!snapshot.hasData) {
                        return CircularProgressIndicator();
                      }
                      int totalDonors = snapshot.data!.docs.length;
                      return DashboardCard(
                        title: 'Total Donors',
                        value: totalDonors.toString(),
                        icon: Icons.people,
                        color: Colors.blue, // Custom card color
                      );
                    },
                  ),
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance.collection('recipients').snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}', style: TextStyle(color: Colors.red)); // Custom error text color
                      }
                      if (!snapshot.hasData) {
                        return CircularProgressIndicator();
                      }
                      int totalRecipients = snapshot.data!.docs.length;
                      return DashboardCard(
                        title: 'Total Recipients',
                        value: totalRecipients.toString(),
                        icon: Icons.person,
                        color: Colors.green, // Custom card color
                      );
                    },
                  ),
                ],
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance.collection('requests').snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}', style: TextStyle(color: Colors.red)); // Custom error text color
                      }
                      if (!snapshot.hasData) {
                        return CircularProgressIndicator();
                      }
                      int totalRequests = snapshot.data!.docs.length;
                      return DashboardCard(
                        title: 'Urgent Requests',
                        value: totalRequests.toString(),
                        icon: Icons.hourglass_empty,
                        color: Colors.orange, // Custom card color
                      );
                    },
                  ),
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance.collection('donation_history').snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}', style: TextStyle(color: Colors.red)); // Custom error text color
                      }
                      if (!snapshot.hasData) {
                        return CircularProgressIndicator();
                      }
                      int totalDonations = snapshot.data!.docs.length;
                      return DashboardCard(
                        title: 'Donations',
                        value: totalDonations.toString(),
                        icon: Icons.attach_money,
                        color: Colors.purple, // Custom card color
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DashboardCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color; // Custom card color

  DashboardCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      color: color, // Set custom card color
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 30,
              color: Colors.white, // Icon color
            ),
            SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white, // Title text color
              ),
            ),
            SizedBox(height: 5),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white, // Value text color
              ),
            ),
          ],
        ),
      ),
    );
  }
}
