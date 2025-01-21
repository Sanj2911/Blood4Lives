import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ReportsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reports'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              
              SizedBox(height: 20),
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Donor Analytics',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 12),
                      DonorAnalyticsReport(),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Recipient Analytics',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 12),
                      RecipientAnalyticsReport(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class DonorAnalyticsReport extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('donors').snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        int totalDonors = snapshot.data!.docs.length;
        // Assuming you have fields for bloodType and donationDate in the donors collection
        Map<String, int> bloodTypeCounts = {};
        for (var doc in snapshot.data!.docs) {
          String bloodType = doc['bloodType'];
          bloodTypeCounts[bloodType] = (bloodTypeCounts[bloodType] ?? 0) + 1;
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ReportItem(
              label: 'Total Donors',
              value: totalDonors.toString(),
              icon: Icons.favorite,
              color: Colors.red,
            ),
            SizedBox(height: 12),
            ...bloodTypeCounts.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: ReportItem(
                  label: 'Blood Type ${entry.key}',
                  value: entry.value.toString(),
                  icon: Icons.bloodtype,
                  color: Colors.purple,
                ),
              );
            }).toList(),
          ],
        );
      },
    );
  }
}

class RecipientAnalyticsReport extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('recipients').snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        int totalRecipients = snapshot.data!.docs.length;
        // Assuming you have fields for bloodType and needDate in the recipients collection
        Map<String, int> bloodTypeCounts = {};
        for (var doc in snapshot.data!.docs) {
          String bloodType = doc['bloodType'];
          bloodTypeCounts[bloodType] = (bloodTypeCounts[bloodType] ?? 0) + 1;
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ReportItem(
              label: 'Total Recipients',
              value: totalRecipients.toString(),
              icon: Icons.people,
              color: Colors.blue,
            ),
            SizedBox(height: 12),
            ...bloodTypeCounts.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: ReportItem(
                  label: 'Blood Type ${entry.key}',
                  value: entry.value.toString(),
                  icon: Icons.bloodtype,
                  color: Colors.purple,
                ),
              );
            }).toList(),
          ],
        );
      },
    );
  }
}

class ReportItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const ReportItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          color: color,
          size: 28,
        ),
        SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[800],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: ReportsScreen(),
  ));
}
