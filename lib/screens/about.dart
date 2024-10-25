import 'package:flutter/material.dart';
import 'package:savelives/screens/campaign.dart';
import 'package:savelives/feed/displayNews.dart';
import 'blood_request.dart';
import 'donationCenters.dart';
import 'loginScreen.dart';


class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Do you know.. ?',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      drawer: Drawer(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xffB81736),
                Color(0xff281537),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.transparent,
                ),
                child: Text(
                  'Menu',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
              ),
              ListTile(
                leading: Icon(Icons.login, color: Colors.white),
                title: Text('Sign In', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LoginScreen()),
                  );
                  // Navigate to immediate blood requests screen
                },
              ),
              ListTile(
                leading: Icon(Icons.quick_contacts_dialer_rounded, color: Colors.white),
                title: Text('Immediate Blood Requests', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => BloodRequestScreen()),
                  );
                  // Navigate to immediate blood requests screen
                },
              ),
              ListTile(
                leading: Icon(Icons.location_pin, color: Colors.white),
                title: Text('Donation Centers', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => DonationCentersPage()),
                  );
                  // Navigate to donation centers screen
                },
              ),
              
               ListTile(
                leading: Icon(Icons.newspaper, color: Colors.white),
                title: Text(' Feed', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => NewsFeedPage()),
                  );
                  // Navigate to immediate blood requests screen
                },
              ),
              ListTile(
                leading: Icon(Icons.campaign, color: Colors.white),
                title: Text('Campaigns', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CampaignDetailsForm()),
                  );
                  // Navigate to campaign details screen
                },
              ),
            ],
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xffB81736),
              Color(0xff281537),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              SizedBox(height: 20),
              FactCard(
                imagePath: 'assets/100.jpg',
                text:
                    '100% of Sri Lankan blood donors are voluntary non-remunerated donors.',
              ),
              FactCard(
                imagePath: 'assets/4person.jpg',
                text:
                    'Your precious donation of blood can save as many as 4 lives.',
              ),
              FactCard(
                imagePath: 'assets/6month.png',
                text: 'You can donate blood every 6 months.',
              ),
              FactCard(
                imagePath: 'assets/date.jpg',
                text: 'World Blood Donor Day.',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FactCard extends StatelessWidget {
  final String imagePath;
  final String text;

  const FactCard({required this.imagePath, required this.text});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              imagePath,
              width: 100,
              height: 100,
              fit: BoxFit.cover,
            ),
            SizedBox(height: 12),
            Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
