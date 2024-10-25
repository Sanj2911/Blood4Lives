import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: ReportsScreen(),
    theme: ThemeData(
      primaryColor: Colors.red, // Example primary color
      colorScheme: ThemeData().colorScheme.copyWith(
        secondary: Colors.blue, // Example accent color
      ),
      fontFamily: 'Roboto', // Example font family
    ),
  ));
}

class ReportsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reports'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 20),
              _buildCard(
                'Donor Analytics',
                Colors.red,
                DonorAnalyticsReport(),
              ),
              SizedBox(height: 20),
              _buildCard(
                'Recipient Analytics',
                Colors.blue,
                RecipientAnalyticsReport(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard(String title, Color color, Widget reportWidget) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: reportWidget,
          ),
        ],
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
        Map<String, int> bloodTypeCounts = {};
        for (var doc in snapshot.data!.docs) {
          String bloodType = doc['bloodType'];
          bloodTypeCounts[bloodType] = (bloodTypeCounts[bloodType] ?? 0) + 1;
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildReportItem(
              'Total Donors',
              totalDonors.toString(),
              Icons.favorite,
              Colors.red,
            ),
            SizedBox(height: 12),
            ...bloodTypeCounts.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: _buildReportItem(
                  'Blood Type ${entry.key}',
                  entry.value.toString(),
                  Icons.bloodtype,
                  Colors.purple,
                ),
              );
            }).toList(),
          ],
        );
      },
    );
  }

  Widget _buildReportItem(String label, String value, IconData icon, Color color) {
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
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ],
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
        Map<String, int> bloodTypeCounts = {};
        for (var doc in snapshot.data!.docs) {
          String bloodType = doc['bloodType'];
          bloodTypeCounts[bloodType] = (bloodTypeCounts[bloodType] ?? 0) + 1;
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildReportItem(
              'Total Recipients',
              totalRecipients.toString(),
              Icons.people,
              Colors.blue,
            ),
            SizedBox(height: 12),
            ...bloodTypeCounts.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: _buildReportItem(
                  'Blood Type ${entry.key}',
                  entry.value.toString(),
                  Icons.bloodtype,
                  Colors.purple,
                ),
              );
            }).toList(),
          ],
        );
      },
    );
  }

  Widget _buildReportItem(String label, String value, IconData icon, Color color) {
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
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
