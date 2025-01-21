import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DonorsScreen extends StatefulWidget {
  @override
  _DonorsScreenState createState() => _DonorsScreenState();
}

class _DonorsScreenState extends State<DonorsScreen> {
  String selectedBloodType = 'All';
  bool showActiveOnly = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Donors'),
      ),
      body: Column(
        children: [
          // Filter controls
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              DropdownButton<String>(
                value: selectedBloodType,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedBloodType = newValue!;
                  });
                },
                items: <String>['All', 'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
              Checkbox(
                value: showActiveOnly,
                onChanged: (bool? newValue) {
                  setState(() {
                    showActiveOnly = newValue!;
                  });
                },
              ),
              Text('Show Active Only'),
            ],
          ),
          Expanded(
            child: UserList(
              collectionName: 'donors',
              bloodTypeFilter: selectedBloodType != 'All' ? selectedBloodType : null,
              activeOnly: showActiveOnly,
            ),
          ),
        ],
      ),
    );
  }
}

class UserList extends StatelessWidget {
  final String collectionName;
  final String? bloodTypeFilter;
  final bool activeOnly;

  UserList({
    required this.collectionName,
    this.bloodTypeFilter,
    required this.activeOnly,
  });

   @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection(collectionName).snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        var filteredDocs = snapshot.data!.docs.where((doc) {
          bool bloodTypeMatches = bloodTypeFilter == null || doc['bloodType'] == bloodTypeFilter;
          bool isActive = doc['isActive'] ?? false;
          return bloodTypeMatches && (!activeOnly || isActive);
        }).toList();
        return ListView.builder(
          itemCount: filteredDocs.length,
          itemBuilder: (context, index) {
            var user = filteredDocs[index];
            String name = user['fullName'] ?? 'N/A';
            String email = user['email'] ?? 'N/A';
            String phone = user['phone'] ?? 'N/A'; // Add phone number
            return ListTile(
              title: Text(name),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(email),
                  Text(phone), // Display phone number
                ],
              ),
              trailing: IconButton(
                icon: Icon(Icons.delete),
                onPressed: () {
                  _showDeleteConfirmationDialog(context, user.id);
                },
              ),
            );
          },
        );
      },
    );
  }


  Future<void> _showDeleteConfirmationDialog(BuildContext context, String userId) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Delete'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Are you sure you want to delete this donor?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Delete'),
              onPressed: () {
                _deleteDonor(userId);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteDonor(String userId) async {
    try {
      await FirebaseFirestore.instance.collection(collectionName).doc(userId).delete();
    } catch (e) {
      print('Error deleting donor: $e');
    }
  }
}
