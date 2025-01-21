import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationsScreen extends StatelessWidget {
  Future<void> _clearNotifications(BuildContext context) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await FirebaseFirestore.instance
            .collection('recipients')
            .doc(user.uid)
            .update({
          'notifications': [],
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Notifications cleared')),
        );
      } catch (e) {
        print('Error clearing notifications: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to clear notifications')),
        );
      }
    } else {
      print('User is not authenticated');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 215, 144, 144),
        title: Text('Notifications'),
        actions: [
          IconButton(
            icon: Icon(Icons.clear_all),
            onPressed: () async {
              bool confirmClear = await showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Clear All Notifications'),
                    content: Text('Are you sure you want to clear all notifications?'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(false);
                        },
                        child: Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(true);
                        },
                        child: Text('Clear'),
                      ),
                    ],
                  );
                },
              );
              if (confirmClear) {
                await _clearNotifications(context);
              }
            },
          ),
        ],
      ),
      body: NotificationsList(),
    );
  }
}

class NotificationsList extends StatelessWidget {
  Future<List<Map<String, dynamic>>> _fetchNotifications() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        DocumentSnapshot<Map<String, dynamic>> userDoc = await FirebaseFirestore
            .instance
            .collection('recipients')
            .doc(user.uid)
            .get();
        if (userDoc.exists) {
          return List<Map<String, dynamic>>.from(
              userDoc.data()?['notifications'] ?? []);
        }
      } catch (e) {
        print('Error fetching notifications: $e');
      }
    } else {
      print('User is not authenticated');
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _fetchNotifications(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error fetching notifications'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No notifications available'));
        } else {
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              var notification = snapshot.data![index];
              return Card(
                color: Colors.lightBlue[50], // Light blue color
                margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                elevation: 5,
                child: ListTile(
                  contentPadding: EdgeInsets.all(15),
                  title: Text(
                    notification['message'] ?? 'No Title',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(notification['timestamp'] ?? 'No Content'),
                  leading: Icon(Icons.notifications, color: Colors.deepPurple),
                ),
              );
            },
          );
        }
      },
    );
  }
}
