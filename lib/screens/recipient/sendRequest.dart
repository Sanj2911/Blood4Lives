import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SendRequestScreen extends StatefulWidget {
  @override
  _SendRequestScreenState createState() => _SendRequestScreenState();
}

class _SendRequestScreenState extends State<SendRequestScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _getCurrentUserId();
  }

  Future<void> _getCurrentUserId() async {
    User? user = _auth.currentUser;
    if (user != null) {
      setState(() {
        _currentUserId = user.uid;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Blood Request'),
        backgroundColor: Colors.red, // Change app bar color
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Card(
                  elevation: 4, // Add elevation for a card effect
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text(
                          'How Rare Is My Blood Type?',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      _buildBloodTypeTable(),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: _sendBloodRequest,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red, // Button color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  elevation: 4, // Add elevation for a button effect
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  child: Text(
                    'Send Blood Request',
                    style: TextStyle(
                      fontSize: 18.0,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBloodTypeTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowColor: MaterialStateColor.resolveWith((states) => Colors.red.withOpacity(0.6)), // Header row color
        columns: [
          DataColumn(
            label: Text(
              'Blood Type',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          DataColumn(
            label: Text(
              'Frequency',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
        rows: [
          _buildDataRow('O+', '37.4%'),
          _buildDataRow('O-', '6.6%'),
          _buildDataRow('A+', '35.7%'),
          _buildDataRow('A-', '6.3%'),
          _buildDataRow('B+', '8.5%'),
          _buildDataRow('B-', '1.5%'),
          _buildDataRow('AB+', '3.4%'),
          _buildDataRow('AB-', '0.6%'),
        ],
      ),
    );
  }

  DataRow _buildDataRow(String bloodType, String frequency) {
    return DataRow(
      cells: [
        DataCell(
          Text(bloodType),
        ),
        DataCell(
          Text(frequency),
        ),
      ],
    );
  }

  Future<void> _sendBloodRequest() async {
    if (_currentUserId == null) {
      _showMessageDialog('Error', 'User not logged in.');
      return;
    }

    try {
      DocumentSnapshot recipientSnapshot =
          await _firestore.collection('recipients').doc(_currentUserId).get();
      if (!recipientSnapshot.exists) {
        _showMessageDialog('Error', 'Recipient document does not exist.');
        return;
      }

      String recipientFullName = recipientSnapshot['fullName'];
      String recipientBloodType = recipientSnapshot['bloodType'];
      String recipientPhone = recipientSnapshot['phone'];
      String recipientNeedDate = recipientSnapshot['needDate'];

      QuerySnapshot donorQuerySnapshot = await _firestore
          .collection('donors')
          .where('isActive', isEqualTo: true)
          .get();

      if (donorQuerySnapshot.docs.isEmpty) {
        _showMessageDialog('No Donors', 'No active donors found.');
        return;
      }

      bool requestSent = false;

      WriteBatch batch = _firestore.batch();

      for (var donorDoc in donorQuerySnapshot.docs) {
        String donorBloodType = donorDoc['bloodType'];
        if (isBloodTypeCompatible(donorBloodType, recipientBloodType)) {
          Map<String, dynamic> message = {
            'type': 'recipientRequest',
            'message': "Blood Donation Needed!",
            'recipientBloodType': recipientBloodType,
            'contact': recipientPhone,
            'needDate': recipientNeedDate,
            'fullName': recipientFullName,
            'recipientId': _currentUserId,
          };

          batch.update(
            _firestore.collection('donors').doc(donorDoc.id),
            {
              'notifications': FieldValue.arrayUnion([message]),
            },
          );

          requestSent = true;
        }
      }

      if (requestSent) {
        await batch.commit();
        _showMessageDialog(
            'Request Sent', 'Blood request sent successfully.');
      } else {
        _showMessageDialog(
            'No Compatible Donors', 'No compatible donors found.');
      }
    } catch (error) {
      _showMessageDialog('Error', 'Error sending blood request: $error');
    }
  }

  bool isBloodTypeCompatible(
      String donorBloodType, String recipientBloodType) {
    Map<String, List<String>> compatibilityMap = {
      'A+': ['A+', 'A-', 'O+', 'O-'],
      'A-': ['A-', 'O-'],
      'B+': ['B+', 'B-', 'O+', 'O-'],
      'B-': ['B-', 'O-'],
      'AB+': ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'],
      'AB-': ['A-', 'B-', 'AB-', 'O-'],
      'O+': ['O+', 'O-'],
      'O-': ['O-'],
    };

    return compatibilityMap[recipientBloodType]?.contains(donorBloodType) ??
        false;
  }

  void _showMessageDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }
}
