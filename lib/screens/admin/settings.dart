import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('App Settings'),
      ),
      body: ListView(
        padding: EdgeInsets.all(16.0),
        children: [
          ListTile(
            title: Text('Backup & Restore'),
            leading: Icon(Icons.backup),
            onTap: () {
              // Navigate to Backup & Restore screen
            },
          ),
          Divider(),
          ListTile(
            title: Text('Data Privacy'),
            leading: Icon(Icons.privacy_tip),
            onTap: () {
              // Navigate to Data Privacy screen
            },
          ),
          Divider(),
          ListTile(
            title: Text('Theme Settings'),
            leading: Icon(Icons.color_lens),
            onTap: () {
              // Navigate to Theme Settings screen
            },
          ),
          Divider(),
          ListTile(
            title: Text('Language Preferences'),
            leading: Icon(Icons.language),
            onTap: () {
              // Navigate to Language Preferences screen
            },
          ),
        ],
      ),
    );
  }
}
