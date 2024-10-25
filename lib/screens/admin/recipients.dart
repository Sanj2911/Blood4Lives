import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RecipientsScreen extends StatefulWidget {
  @override
  _RecipientsScreenState createState() => _RecipientsScreenState();
}

class _RecipientsScreenState extends State<RecipientsScreen> {
  String? selectedBloodType;
  DateTime? selectedDate;

  void _clearFilters() {
    setState(() {
      selectedBloodType = null;
      selectedDate = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Recipients'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Blood Type',
                      border: OutlineInputBorder(),
                    ),
                    items: ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-']
                        .map((bloodType) => DropdownMenuItem<String>(
                              value: bloodType,
                              child: Text(bloodType),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedBloodType = value;
                      });
                    },
                    value: selectedBloodType,
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2101),
                      );
                      if (picked != null) {
                        setState(() {
                          selectedDate = picked;
                        });
                      }
                    },
                    child: Text(selectedDate == null
                        ? 'Select Date'
                        : '${selectedDate!.toLocal()}'.split(' ')[0]),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: _clearFilters,
                  tooltip: 'Clear Filters',
                ),
              ],
            ),
          ),
          Expanded(
            child: UserList(
              collectionName: 'recipients',
              bloodTypeFilter: selectedBloodType,
              dateBeforeFilter: selectedDate,
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
  final DateTime? dateBeforeFilter;

  UserList({
    required this.collectionName,
    this.bloodTypeFilter,
    this.dateBeforeFilter,
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
          bool dateBefore = dateBeforeFilter == null || DateTime.parse(doc['needDate']).isBefore(dateBeforeFilter!);
          return bloodTypeMatches && dateBefore;
        }).toList();
        if (filteredDocs.isEmpty) {
          return Center(child: Text('No recipients found.'));
        }
        return ListView.builder(
          itemCount: filteredDocs.length,
          itemBuilder: (context, index) {
            var user = filteredDocs[index];
            String name = user['fullName'] ?? 'N/A';
            String email = user['email'] ?? 'N/A';
            String phone = user['phone'] ?? 'N/A';
            return ListTile(
              title: Text(name),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Email: $email'),
                  Text('Phone: $phone'),
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

  void _showDeleteConfirmationDialog(BuildContext context, String userId) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Delete'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Are you sure you want to delete this recipient?'),
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
                _deleteRecipient(userId);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _deleteRecipient(String userId) async {
    try {
      await FirebaseFirestore.instance.collection(collectionName).doc(userId).delete();
    } catch (e) {
      print('Error deleting recipient: $e');
      // Handle error as needed
    }
  }
}
