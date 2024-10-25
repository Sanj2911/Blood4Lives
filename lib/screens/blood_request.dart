import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';

class BloodRequestScreen extends StatefulWidget {
  @override
  _BloodRequestScreenState createState() => _BloodRequestScreenState();
}

class _BloodRequestScreenState extends State<BloodRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _bloodTypeController = TextEditingController();
  final _amountController = TextEditingController();
  final _locationController = TextEditingController();
  bool _isLoading = false;

  Future<void> _submitRequest() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final name = _nameController.text;
        final phone = _phoneController.text;
        final bloodType = _bloodTypeController.text;
        final amount = int.parse(_amountController.text);
        final location = await _getLocation(); // Get requester's location
        final requestId =
            FirebaseFirestore.instance.collection('requests').doc().id;

        final currentTime = DateTime.now();
      final formattedTime = DateFormat('yyyy-MM-dd HH:mm:ss').format(currentTime);

        await FirebaseFirestore.instance
            .collection('requests')
            .doc(requestId)
            .set({
          'name': name,
          'phone': phone,
          'bloodType': bloodType,
          'amount': amount,
          'location': location,
          'confirmedAmount': 0,
          'status': 'open',
          'confirmedDonorId': "",
        'timestamp': formattedTime, // Store formatted timestamp
        });

        await _notifyDonors(requestId, bloodType, location);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Blood request submitted successfully!')),
        );

        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error submitting blood request: $e')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<String> _getLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      return '${position.latitude},${position.longitude}';
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error getting location: $e')),
      );
      return '0,0'; // Fallback location
    }
  }

  Future<void> _notifyDonors(
      String requestId, String bloodType, String location) async {
    final CollectionReference donors =
        FirebaseFirestore.instance.collection('donors');

    // Define compatible blood groups for each blood type
    final Map<String, List<String>> compatibleBloodGroups = {
      'A+': ['A+', 'A-', 'O+', 'O-'],
      'A-': ['A-', 'O-'],
      'B+': ['B+', 'B-', 'O+', 'O-'],
      'B-': ['B-', 'O-'],
      'AB+': ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'],
      'AB-': ['A-', 'B-', 'AB-', 'O-'],
      'O+': ['O+', 'O-'],
      'O-': ['O-'],
    };

    // Fetch compatible blood groups
    final List<String> compatibleGroups =
        compatibleBloodGroups[bloodType] ?? [];

    // Fetch the requester's latitude and longitude
    final List<String> requesterLocation = location.split(',');
    final double requesterLat = double.parse(requesterLocation[0]);
    final double requesterLng = double.parse(requesterLocation[1]);

    // Fetch donors with compatible blood groups
    final querySnapshot = await donors
        .where('bloodType', whereIn: compatibleGroups)
        .where('isActive', isEqualTo: true)
        .get();

    // Filter donors within a 30km radius
    final List<DocumentSnapshot> nearbyDonors = [];
    querySnapshot.docs.forEach((donorDoc) {
      final donorData = donorDoc.data() as Map<String, dynamic>;
      final donorLat = donorData['latitude'];
      final donorLng = donorData['longitude'];

      final double distance = Geolocator.distanceBetween(
        requesterLat,
        requesterLng,
        donorLat,
        donorLng,
      );

      if (distance <= 30000) {
        nearbyDonors.add(donorDoc);
      }
    });

    // Notify nearby donors
    WriteBatch batch = FirebaseFirestore.instance.batch();
    for (final donorDoc in nearbyDonors) {
      final donorId = donorDoc.id;
      batch.update(donors.doc(donorId), {
        'notifications': FieldValue.arrayUnion([requestId]),
      });
    }

    try {
      await batch.commit();
      print('Notifications sent to all nearby donors.');
    } catch (e) {
      print('Error sending notifications: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Blood Request'),
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
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'Name',
                          labelStyle: TextStyle(color: Colors.white),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                        ),
                        style: TextStyle(color: Colors.white),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your name';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 10),
                      TextFormField(
                        controller: _phoneController,
                        decoration: InputDecoration(
                          labelText: 'Phone Number',
                          labelStyle: TextStyle(color: Colors.white),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                        ),
                        style: TextStyle(color: Colors.white),
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your phone number';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 10),
                      TextFormField(
                        controller: _bloodTypeController,
                        decoration: InputDecoration(
                          labelText: 'Blood Type',
                          labelStyle: TextStyle(color: Colors.white),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                        ),
                        style: TextStyle(color: Colors.white),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter blood type';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 10),
                      TextFormField(
                        controller: _amountController,
                        decoration: InputDecoration(
                          labelText: 'Amount (Pints)',
                          labelStyle: TextStyle(color: Colors.white),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                        ),
                        style: TextStyle(color: Colors.white),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the amount needed';
                          }
                          if (int.tryParse(value) == null ||
                              int.parse(value) <= 0) {
                            return 'Please enter a valid amount';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 10),
                      TextFormField(
                        controller: _locationController,
                        decoration: InputDecoration(
                          labelText: 'Hospital',
                          labelStyle: TextStyle(color: Colors.white),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                        ),
                        style: TextStyle(color: Colors.white),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter hospital location';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 20),
                      _isLoading
                          ? CircularProgressIndicator()
                          : ElevatedButton(
                              onPressed: _submitRequest,
                              child: Text('Submit Request'),
                            ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              Image.asset(
                'assets/req.jpg', // Ensure the path to your image is correct
                fit: BoxFit.cover,
              ),
              SizedBox(height: 20),
              Text(
                "After requesting, donors will contact you ASAP",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
