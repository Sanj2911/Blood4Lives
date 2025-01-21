import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';

typedef ClearReminderCallback = void Function(String requestId);

class DonationFormScreen extends StatefulWidget {
  final String requestId;
  final ClearReminderCallback clearReminderCallback;

  DonationFormScreen({
    required this.requestId,
    required this.clearReminderCallback,
  });

  @override
  _DonationFormScreenState createState() => _DonationFormScreenState();
}

class _DonationFormScreenState extends State<DonationFormScreen> {
  TextEditingController _proofController = TextEditingController();
  TextEditingController _donationDateController = TextEditingController();
  TextEditingController _donationNumberController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Initialize donationDate with current date
    _donationDateController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Provide Proof of Donation'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _proofController,
                      maxLines: 5,
                      decoration: InputDecoration(
                        labelText: 'Proof of Donation',
                        hintText: 'Provide details or upload image link',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      controller: _donationDateController,
                      decoration: InputDecoration(
                        labelText: 'Donation Date',
                        hintText: 'YYYY-MM-DD',
                        border: OutlineInputBorder(),
                      ),
                      readOnly: true,
                      onTap: () {
                        _selectDate(context);
                      },
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      controller: _donationNumberController,
                      decoration: InputDecoration(
                        labelText: 'Donation Number',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        _submitProof();
                      },
                      child: Text('Submit'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Future<void> _submitProof() async {
    // Validate input
    String proof = _proofController.text.trim();
    String donationDate = _donationDateController.text.trim();
    String donationNumber = _donationNumberController.text.trim();

    if (proof.isEmpty || donationDate.isEmpty || donationNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please provide all details')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Get current user ID
      String donorId = FirebaseAuth.instance.currentUser!.uid;

      // Store proof of donation in 'proofs' collection
      await FirebaseFirestore.instance.collection('proofs').add({
        'requestId': widget.requestId,
        'proof': proof,
        'donationDate': donationDate,
        'donationNumber': donationNumber,
        'donorId': donorId,
      });

      // Update the 'requests' collection or mark proof submitted
      await FirebaseFirestore.instance
          .collection('requests')
          .doc(widget.requestId)
          .update({
        'donationProofSubmitted': true,
      });

      // Update lastDonationDate, isActive, and clear notifications in donor's document
      await FirebaseFirestore.instance
          .collection('donors')
          .doc(donorId)
          .update({
        'lastDonationDate': donationDate,
        'isActive': false,
        'proofSubmitted': true,  // Add the proofSubmitted field
        'notifications': [], // Clear all notifications
      });

      // Clear the reminder notification using the callback
      widget.clearReminderCallback(widget.requestId);

      // Show confirmation dialog
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Thank you for your donation!'),
            content: Text('Your proof of donation has been submitted.'),
            actions: <Widget>[
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.pop(context); // Pop back to previous screen
                },
              ),
            ],
          );
        },
      );
    } catch (e) {
      print('Error submitting proof of donation: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit proof of donation')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null) {
      setState(() {
        _donationDateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
      });
    }
  }
}
