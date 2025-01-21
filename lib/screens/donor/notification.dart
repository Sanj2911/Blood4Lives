import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
//import 'package:savelives/screens/donor/proofForm.dart';
import 'package:intl/intl.dart';
// Import DateFormat for date formatting

class NotificationsScreen extends StatefulWidget {
  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _currentUser;
  List<Map<String, dynamic>> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _currentUser = _auth.currentUser;
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    if (_currentUser == null) return;

    try {
      final donorDoc = await FirebaseFirestore.instance
          .collection('donors')
          .doc(_currentUser!.uid)
          .get();

      final notifications = List<dynamic>.from(donorDoc['notifications'] ?? []);

      List<Map<String, dynamic>> fetchedNotifications = [];

      for (var notification in notifications) {
        if (notification is String) {
          // Treat as request ID for urgent requests
          final requestDoc = await FirebaseFirestore.instance
              .collection('requests')
              .doc(notification)
              .get();

          if (requestDoc.exists) {
            fetchedNotifications.add({
              'type': 'urgentRequest',
              'requestId': notification,
              'name': requestDoc['name'],
              'amount': requestDoc['amount'],
              'bloodType': requestDoc['bloodType'],
              'phone': requestDoc['phone'],
            });
          }
        } else if (notification is Map<String, dynamic>) {
          if (notification['type'] == 'reminder') {
            fetchedNotifications
                .add(notification); // Add reminder notification directly
          } else {
            // Treat as direct message from recipients
            fetchedNotifications.add({
              'type': 'recipientRequest',
              'fullName': notification['fullName'],
              'message': notification['message'],
              'recipientBloodType': notification['recipientBloodType'],
              'contact': notification['contact'],
              'needDate': notification['needDate'],
              'recipientId': notification['recipientId'],
            });
          }
        }
      }

      setState(() {
        _notifications = fetchedNotifications;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error fetching notifications: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load notifications')),
      );
    }
  }

  Future<void> _confirmUrgentRequest(String requestId) async {
    try {
      // Fetch the request document
      final requestDoc = await FirebaseFirestore.instance
          .collection('requests')
          .doc(requestId)
          .get();

      // Check if the request document exists
      if (requestDoc.exists) {
        // Retrieve current status
        final status = requestDoc['status'];

        // Check if the status is 'closed'
        if (status == 'closed') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('This request is already closed!')),
          );
        } else {
          // Handle scenario where request can still accept confirmations
          // For example, show a message or allow user to confirm
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('You confirmed this donation!')),
          );
          _removeNotification(requestId);
          _scheduleReminderNotification(requestId);
        }
        // Optionally, handle UI updates or further actions based on status
      } else {
        // Handle case where request document doesn't exist
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Request not found!')),
        );
      }
    } catch (e) {
      print('Error confirming donation: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to confirm donation')),
      );
    }
  }

  void _scheduleReminderNotification(String requestId) async {
    // Schedule a notification after 5 minutes
    DateTime fiveMinutesLater = DateTime.now().add(Duration(minutes: 5));

    try {
      await FirebaseFirestore.instance
          .collection('donors')
          .doc(_currentUser!.uid)
          .update({
        'notifications': FieldValue.arrayUnion([
          {
            'type': 'reminder',
            'requestId': requestId,
            'message':
                'If you did not donate, click No. Otherwise you will be inactive for 6 months.',
            'timestamp': fiveMinutesLater,
          }
        ]),
      });
    } catch (e) {
      print('Error scheduling reminder notification: $e');
    }
  }

  Future<void> _clearReminderNotification(String requestId) async {
    if (_currentUser == null) return;

    try {
      final donorDoc = await FirebaseFirestore.instance
          .collection('donors')
          .doc(_currentUser!.uid)
          .get();

      final notifications = List<dynamic>.from(donorDoc['notifications'] ?? []);

      notifications.removeWhere((notification) =>
          notification is Map<String, dynamic> &&
          notification['type'] == 'reminder' &&
          notification['requestId'] == requestId);

      await FirebaseFirestore.instance
          .collection('donors')
          .doc(_currentUser!.uid)
          .update({
        'notifications': notifications,
      });

      setState(() {
        _notifications.removeWhere((notification) =>
            notification['type'] == 'reminder' &&
            notification['requestId'] == requestId);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Reminder notification cleared')),
      );
    } catch (e) {
      print('Error clearing reminder notification: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to clear reminder notification')),
      );
    }
  }

  void _showClearConfirmationDialog(String requestId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Are you sure?'),
          content: Text('Do you really want to clear this reminder?'),
          actions: [
            TextButton(
              child: Text('Yes'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                _clearReminderNotification(requestId); // Clear the reminder
              },
            ),
            TextButton(
              child: Text('No'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _rejectUrgentRequest(String requestId) async {
    if (_currentUser == null) return;

    try {
      // Remove the urgent request notification from the donor's notifications list
      await FirebaseFirestore.instance
          .collection('donors')
          .doc(_currentUser!.uid)
          .update({
        'notifications': FieldValue.arrayRemove([requestId])
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Urgent request rejected')),
      );

      // Optional: Update local notifications list
      _fetchNotifications(); // Refresh notifications list if needed
    } catch (e) {
      print('Error rejecting urgent request: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to reject urgent request')),
      );
    }
  }

  Future<void> _rejectRecipientRequest(String recipientId) async {
    try {
      final donorDocRef = FirebaseFirestore.instance
          .collection('donors')
          .doc(_currentUser!.uid);

      final donorDocSnapshot = await donorDocRef.get();
      List<dynamic> notifications =
          List<dynamic>.from(donorDocSnapshot['notifications']);

      notifications.removeWhere((notification) =>
          notification['recipientId'] == recipientId &&
          notification['type'] == 'recipientRequest');

      await donorDocRef.update({
        'notifications': notifications,
      });

      if (mounted) {
        setState(() {
          _notifications.removeWhere((notification) =>
              notification['recipientId'] == recipientId &&
              notification['type'] == 'recipientRequest');
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Recipient Request rejected')),
      );
    } catch (e) {
      print('Error rejecting recipient request: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to reject recipient notification')),
      );
    }
  }

  Future<void> _addToDonationHistory(String requestId) async {
    try {
      // Prepare the data to be stored
      Map<String, dynamic> donationDetails = {
        'requestId': requestId,
        'time': DateTime.now(), // Store the current time
      };

      // Add the data to the Firestore collection 'donation_history'
      await FirebaseFirestore.instance
          .collection('donation_history')
          .add(donationDetails);

      // Format current date without time
      String currentDate = DateTime.now().toIso8601String().split('T')[0];

      // Update user document to set lastDonationDate and isActive
      await FirebaseFirestore.instance
          .collection('donors')
          .doc(_currentUser!.uid)
          .update({
        'lastDonationDate': currentDate,
        'isActive': false,
      });

      // Show success message or navigate to another screen
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Donation recorded successfully!'),
        ),
      );
    } catch (e) {
      print('Error adding to donation history: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error adding to donation history: $e'),
        ),
      );
    }
  }

  Future<void> _removeNotification(String requestId) async {
    if (_currentUser == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('donors')
          .doc(_currentUser!.uid)
          .update({
        'notifications': FieldValue.arrayRemove([requestId]),
      });

      _fetchNotifications(); // Refresh notifications list
    } catch (e) {
      print('Error removing notification: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to remove notification')),
      );
    }
  }

  Future<void> _confirmRecipientRequest(String recipientId) async {
    try {
      DocumentSnapshot recipientDoc = await FirebaseFirestore.instance
          .collection('recipients')
          .doc(recipientId)
          .get();

      if (recipientDoc.exists) {
        Map<String, dynamic> recipientData =
            recipientDoc.data() as Map<String, dynamic>;

        int currentAmountNeeded = recipientData['amountNeeded'] ?? 0;

        if (currentAmountNeeded <= 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('This request has already been completed.')),
          );
          return;
        }

        // Show confirmation dialog
        bool confirm = await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Confirm Request'),
              content: Text('Are you sure you want to confirm this request?'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                  child: Text('No'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                  child: Text('Yes'),
                ),
              ],
            );
          },
        );

        if (confirm == true) {
          int newAmountNeeded = currentAmountNeeded - 1;

          // Update amountNeeded and add confirmation message to notifications
          await FirebaseFirestore.instance
              .collection('recipients')
              .doc(recipientId)
              .update({
            'amountNeeded': newAmountNeeded,
            'notifications': FieldValue.arrayUnion([
              {
                'message': 'Confirmed by a donor. He will contact you now.',
                'timestamp': DateTime.now().toString(),
              }
            ])
          });

          // Check if amountNeeded reaches zero and update status to completed
          if (newAmountNeeded == 0) {
            await FirebaseFirestore.instance
                .collection('recipients')
                .doc(recipientId)
                .update({
              'status': 'completed', // Update status to completed
            });

            // Notify recipient about completion
            await FirebaseFirestore.instance
                .collection('recipients')
                .doc(recipientId)
                .update({
              'notifications': FieldValue.arrayUnion([
                {
                  'message': 'Your request is completed.',
                  'timestamp': DateTime.now().toString(),
                }
              ])
            });
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Recipient request confirmed')),
          );

          // Remove all notifications in the donor's document
          await FirebaseFirestore.instance
              .collection('donors')
              .doc(_currentUser!.uid)
              .update({
            'notifications': [],
          });

          // Update donor's document to set inactive and update lastDonationDate
          String currentDate = DateTime.now().toIso8601String().split('T')[0];
          await FirebaseFirestore.instance
              .collection('donors')
              .doc(_currentUser!.uid)
              .update({
            'isActive': false,
            'lastDonationDate': currentDate,
            'canEditLastDonationDate': false, // Disable further edits
          });

          // Show thank you dialog
          await _showThankYouDialog();

          // Refresh notifications list
          _fetchNotifications();
        }
      }
    } catch (e) {
      print('Error confirming recipient request: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to confirm recipient request')),
      );
    }
  }

  Future<void> _showThankYouDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          backgroundColor: Colors.white,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.favorite, color: Colors.red),
              SizedBox(width: 8),
              Text('Thank You!', style: TextStyle(color: Colors.black)),
            ],
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                    'You have helped save a life. Thank you for your generosity!',
                    style: TextStyle(color: Colors.black)),
                SizedBox(height: 16),
                Text('You can donate blood again after 6 months.',
                    style: TextStyle(color: Colors.black)),
                SizedBox(height: 16),
                Image.asset('assets/thank.gif', width: 200, height: 200),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('OK', style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _notifications.isEmpty
              ? Center(child: Text('No notifications available.'))
              : ListView.builder(
                  itemCount: _notifications.length,
                  itemBuilder: (context, index) {
                    final notification = _notifications[index];
                    if (notification['type'] == 'urgentRequest') {
                      return Card(
                        elevation: 4,
                        margin:
                            EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            ListTile(
                              title: Text(
                                'Emergency: ${notification['name']} needs ${notification['amount']} pints of ${notification['bloodType']} blood',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text('Phone: ${notification['phone']}'),
                            ),
                            ButtonBar(
                              alignment: MainAxisAlignment.end,
                              children: [
                                ElevatedButton(
                                  child: Text('Confirm'),
                                  onPressed: () {
                                    _confirmUrgentRequest(
                                        notification['requestId']);
                                  },
                                ),
                                ElevatedButton(
                                  child: Text('Reject'),
                                  onPressed: () {
                                    final requestId =
                                        notification['requestId'] as String?;
                                    if (requestId != null &&
                                        requestId.isNotEmpty) {
                                      _rejectUrgentRequest(requestId);
                                    } else {
                                      print('Request ID is missing or empty');
                                      print('Notification data: $notification');
                                    }
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    } else if (notification['type'] == 'recipientRequest') {
                      return Card(
                        elevation: 4,
                        margin:
                            EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            ListTile(
                              title: Text(
                                'Blood Donation Needed!',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Name: ${notification['fullName']}'),
                                  Text(
                                      'Blood Type: ${notification['recipientBloodType']}'),
                                  Text('Message: ${notification['message']}'),
                                  Text('Contact: ${notification['contact']}'),
                                  Text(
                                      'Need before: ${notification['needDate']}'),
                                ],
                              ),
                            ),
                            ButtonBar(
                              alignment: MainAxisAlignment.end,
                              children: [
                                ElevatedButton(
                                  child: Text('Confirm'),
                                  onPressed: () {
                                    final recipientId =
                                        notification['recipientId'] as String?;
                                    if (recipientId != null &&
                                        recipientId.isNotEmpty) {
                                      _confirmRecipientRequest(
                                        recipientId,
                                      );
                                    } else {
                                      print('Recipient ID is missing or empty');
                                      print('Notification data: $notification');
                                    }
                                  },
                                ),
                                ElevatedButton(
                                  child: Text('Reject'),
                                  onPressed: () {
                                    final recipientId =
                                        notification['recipientId'] as String?;
                                    if (recipientId != null &&
                                        recipientId.isNotEmpty) {
                                      _rejectRecipientRequest(recipientId);
                                    } else {
                                      print('Recipient ID is missing or empty');
                                      print('Notification data: $notification');
                                    }
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    } else if (notification['type'] == 'reminder') {
                      // Format timestamp to readable date and time
                      DateTime timestamp = notification['timestamp'].toDate();
                      String formattedDateTime =
                          DateFormat('yyyy-MM-dd HH:mm').format(timestamp);

                      return Card(
                        elevation: 4,
                        margin:
                            EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            ListTile(
                              title: Text(
                                'Reminder',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(notification['message']),
                                  Text(
                                      'Confirmed: ${notification['requestId']}'),
                                  Text(
                                      'Time: $formattedDateTime'), // Display formatted date and time
                                ],
                              ),
                            ),
                            ButtonBar(
                              alignment: MainAxisAlignment.end,
                              children: [
                                ElevatedButton(
                                  child: Text('Donated'),
                                  onPressed: () async {
                                    try {
                                      final requestDoc = await FirebaseFirestore
                                          .instance
                                          .collection('requests')
                                          .doc(notification['requestId'])
                                          .get();

                                      if (requestDoc.exists) {
                                        final confirmedAmount =
                                            requestDoc['confirmedAmount'] + 1;
                                        final totalAmount =
                                            requestDoc['amount'];

                                        // Update confirmed amount
                                        await FirebaseFirestore.instance
                                            .collection('requests')
                                            .doc(notification['requestId'])
                                            .update({
                                          'confirmedAmount': confirmedAmount,
                                        });

                                        // Check if request can be closed
                                        if (confirmedAmount >= totalAmount) {
                                          await FirebaseFirestore.instance
                                              .collection('requests')
                                              .doc(notification['requestId'])
                                              .update({
                                            'status': 'closed',
                                          });
                                          
                                        }
                                        // Remove all notifications in the donor's document
                                          await FirebaseFirestore.instance
                                              .collection('donors')
                                              .doc(_currentUser!.uid)
                                              .update({
                                            'notifications': [],
                                          });

                                        // Remove the reminder notification
                                       // _clearReminderNotification(
                                          //  notification['requestId']);

                                        _addToDonationHistory(
                                            notification['requestId']);

                                        _showThankYouDialog(); // Show thank you dialog

                                        // Refresh notifications list
                                        _fetchNotifications();
                                      }
                                    } catch (e) {
                                      print('Error processing donation: $e');
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                            content: Text(
                                                'Failed to process donation')),
                                      );
                                    }
                                  },
                                ),
                                ElevatedButton(
                                  child: Text('No'),
                                  onPressed: () {
                                    _showClearConfirmationDialog(
                                        notification['requestId']);
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }
                    return Container(); // Default return in case of unknown notification type
                  },
                ),
    );
  }
}
