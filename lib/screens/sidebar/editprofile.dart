import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditProfilePage extends StatefulWidget {
  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  String? _email;
  String? _username;
  String? _gender;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
   
    String userId = FirebaseAuth.instance.currentUser!.uid;
    DocumentSnapshot<Map<String, dynamic>> userSnapshot =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
    if (userSnapshot.exists) {
      setState(() {
        _email = userSnapshot.data()!['email'];
        _username = userSnapshot.data()!['username'];
        _gender = userSnapshot.data()!['gender'];
      });
    }
  }

  Future<void> _changePassword() async {
//ADD THIS LATER
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Email:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(_email ?? 'Loading...'),
            SizedBox(height: 16),
            Text(
              'Username:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(_username ?? 'Loading...'),
            SizedBox(height: 16),
            Text(
              'Gender:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(_gender ?? 'Loading...'),
            SizedBox(height: 32),
            ElevatedButton(
              onPressed: _changePassword,
              child: Text('Change Password'),
            ),
          ],
        ),
      ),
    );
  }
}