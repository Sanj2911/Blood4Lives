import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DonationHistoryScreen extends StatefulWidget {
  @override
  _DonationHistoryScreenState createState() => _DonationHistoryScreenState();
}

class _DonationHistoryScreenState extends State<DonationHistoryScreen> {
  List<Map<String, dynamic>> donationHistory = []; // List to store donation history data

  @override
  void initState() {
    super.initState();
    // Load donation history data
    _loadDonationHistory();
  }

  Future<void> _loadDonationHistory() async {
    // Get current user ID
    String donorId = FirebaseAuth.instance.currentUser!.uid;

    // Query Firestore for donation proofs
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('proofs')
        .where('donorId', isEqualTo: donorId)
        .get();

    // Process query results
    List<Map<String, dynamic>> history = [];
    querySnapshot.docs.forEach((DocumentSnapshot document) {
      Map<String, dynamic> data = document.data() as Map<String, dynamic>;
      history.add({
        'requestId': data['requestId'],
        'proof': data['proof'],
        'donationDate': data['donationDate'],
        'donationNumber': data['donationNumber'],
      });
    });

    setState(() {
      donationHistory = history;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Donation History'),
      ),
      body: donationHistory.isEmpty
          ? Center(
              child: Text('No donation history available.'),
            )
          : ListView.builder(
              itemCount: donationHistory.length,
              itemBuilder: (BuildContext context, int index) {
                Map<String, dynamic> donation = donationHistory[index];
                return ListTile(
                  title: Text('Donation for Request ID: ${donation['requestId']}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Proof: ${donation['proof']}'),
                      Text('Donation Date: ${donation['donationDate']}'),
                      Text('Donation Number: ${donation['donationNumber']}'),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
